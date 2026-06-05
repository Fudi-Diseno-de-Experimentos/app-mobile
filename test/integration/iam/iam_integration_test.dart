import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:app_mobile/core/error/exceptions.dart';
import 'package:app_mobile/features/iam/data/models/user_model.dart';
import 'package:app_mobile/features/iam/data/repositories/iam_repository_impl.dart';
import 'package:app_mobile/features/iam/domain/usecases/sign_in_usecase.dart';
import 'package:app_mobile/features/iam/domain/usecases/sign_up_usecase.dart';
import 'package:app_mobile/features/iam/domain/usecases/sign_out_usecase.dart';

import '../../mocks/generate_mocks.mocks.dart';

void main() {
  late MockIamRemoteDataSource mockDataSource;
  late MockSharedPreferences mockPrefs;
  late IamRepositoryImpl repository;

  const tUserModel = UserModel(
    id: 'user-1',
    username: 'admin',
    token: 'jwt-token-valid',
    companyId: 'comp-1',
  );

  setUp(() {
    mockDataSource = MockIamRemoteDataSource();
    mockPrefs = MockSharedPreferences();
    when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
    when(mockPrefs.remove(any)).thenAnswer((_) async => true);
    repository = IamRepositoryImpl(
      remoteDataSource: mockDataSource,
      sharedPreferences: mockPrefs,
    );
  });

  group('US38 - Integración: Autenticación segura con JWT', () {
    test('debe autenticar usuario y guardar token en SharedPreferences', () async {
      // Arrange
      when(mockDataSource.signIn('admin', '123456'))
          .thenAnswer((_) async => tUserModel);
      final useCase = SignInUseCase(repository);

      // Act
      final result = await useCase('admin', '123456');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Debería ser Right'),
        (user) {
          expect(user.token, 'jwt-token-valid');
          expect(user.username, 'admin');
          expect(user.companyId, 'comp-1');
        },
      );
      verify(mockPrefs.setString('auth_token', 'jwt-token-valid')).called(1);
    });

    test('debe retornar ServerFailure con credenciales inválidas', () async {
      // Arrange
      when(mockDataSource.signIn('admin', 'wrong'))
          .thenThrow(ServerException(message: 'Bad credentials'));
      final useCase = SignInUseCase(repository);

      // Act
      final result = await useCase('admin', 'wrong');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'Bad credentials'),
        (_) => fail('Debería ser Left'),
      );
    });
  });

  group('US33 - Integración: Registro de usuario', () {
    test('debe registrar usuario pasando por todas las capas', () async {
      // Arrange
      when(mockDataSource.signUp(
        username: anyNamed('username'),
        password: anyNamed('password'),
        name: anyNamed('name'),
        lastname: anyNamed('lastname'),
        email: anyNamed('email'),
        roles: anyNamed('roles'),
      )).thenAnswer((_) async {});
      final useCase = SignUpUseCase(repository);

      // Act
      final result = await useCase(
        username: 'nuevo',
        password: 'pass123',
        name: 'Juan',
        lastname: 'Pérez',
        email: 'juan@test.com',
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockDataSource.signUp(
        username: 'nuevo',
        password: 'pass123',
        name: 'Juan',
        lastname: 'Pérez',
        email: 'juan@test.com',
        roles: null,
      )).called(1);
    });

    test('debe retornar ServerFailure cuando el email ya existe', () async {
      // Arrange
      when(mockDataSource.signUp(
        username: anyNamed('username'),
        password: anyNamed('password'),
        name: anyNamed('name'),
        lastname: anyNamed('lastname'),
        email: anyNamed('email'),
        roles: anyNamed('roles'),
      )).thenThrow(ServerException(message: 'Email already exists'));
      final useCase = SignUpUseCase(repository);

      // Act
      final result = await useCase(
        username: 'dup',
        password: 'pass',
        name: 'Test',
        lastname: 'User',
        email: 'dup@test.com',
      );

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('US36 - Integración: Cierre de sesión seguro', () {
    test('debe eliminar token de SharedPreferences al cerrar sesión', () async {
      // Arrange
      final useCase = SignOutUseCase(repository);

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      verify(mockPrefs.remove('auth_token')).called(1);
    });
  });
}
