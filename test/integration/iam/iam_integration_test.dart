import 'package:app_mobile/core/error/exceptions.dart';
import 'package:app_mobile/features/iam/data/models/user_model.dart';
import 'package:app_mobile/features/iam/data/repositories/iam_repository_impl.dart';
import 'package:app_mobile/features/iam/domain/usecases/sign_in_usecase.dart';
import 'package:app_mobile/features/iam/domain/usecases/sign_out_usecase.dart';
import 'package:app_mobile/features/iam/domain/usecases/sign_up_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/generate_mocks.mocks.dart';

void main() {
  late MockIamRemoteDataSource mockDataSource;
  late MockTokenStore mockTokenStore;
  late IamRepositoryImpl repository;

  const tUserModel = UserModel(
    id: 'user-1',
    username: 'admin',
    token: 'jwt-token-valid',
    companyId: 'comp-1',
  );

  setUp(() {
    mockDataSource = MockIamRemoteDataSource();
    mockTokenStore = MockTokenStore();
    when(mockTokenStore.save(any, userId: anyNamed('userId'))).thenAnswer((_) async {});
    when(mockTokenStore.clear()).thenAnswer((_) async {});
    repository = IamRepositoryImpl(
      remoteDataSource: mockDataSource,
      tokenStore: mockTokenStore,
    );
  });

  group('US38 - Integration: Secure JWT authentication', () {
    test('should authenticate the user and store the token', () async {
      // Arrange
      when(mockDataSource.signIn('admin', '123456'))
          .thenAnswer((_) async => tUserModel);
      final useCase = SignInUseCase(repository);

      // Act
      final result = await useCase('admin', '123456');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should be Right'),
        (user) {
          expect(user.token, 'jwt-token-valid');
          expect(user.username, 'admin');
          expect(user.companyId, 'comp-1');
        },
      );
      verify(mockTokenStore.save('jwt-token-valid', userId: 'user-1')).called(1);
    });

    test('should return ServerFailure with invalid credentials', () async {
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
        (_) => fail('Should be Left'),
      );
    });
  });

  group('US33 - Integration: User registration', () {
    test('should register a user through all layers', () async {
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

    test('should return ServerFailure when the email already exists', () async {
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

  group('US36 - Integration: Secure sign-out', () {
    test('should remove the token on sign-out', () async {
      // Arrange
      final useCase = SignOutUseCase(repository);

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      verify(mockTokenStore.clear()).called(1);
    });
  });
}
