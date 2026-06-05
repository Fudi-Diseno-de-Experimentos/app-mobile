import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:app_mobile/core/error/exceptions.dart';
import 'package:app_mobile/features/profile/data/models/profile_model.dart';
import 'package:app_mobile/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:app_mobile/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_company_members_usecase.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';

import '../../mocks/generate_mocks.mocks.dart';
import '../../mocks/mock_helpers.dart';

void main() {
  late MockProfileRemoteDataSource mockDataSource;
  late MockSharedPreferences mockPrefs;
  late ProfileRepositoryImpl repository;

  const tProfileModel = ProfileModel(
    id: 'profile-1',
    userId: 'user-1',
    username: 'jperez',
    name: 'Juan',
    lastname: 'Pérez',
    email: 'juan@empresa.com',
    roles: ['ROLE_USER', 'ROLE_MANAGER'],
    companyId: 'comp-1',
    avatarUrl: 'avatar.png',
  );

  const tMemberModel = ProfileModel(
    id: 'profile-2',
    userId: 'user-2',
    username: 'mgarcia',
    name: 'María',
    lastname: 'García',
    email: 'maria@empresa.com',
    roles: ['ROLE_USER'],
    companyId: 'comp-1',
  );

  setUp(() {
    mockDataSource = MockProfileRemoteDataSource();
    mockPrefs = MockSharedPreferences();
    when(mockPrefs.getString(any)).thenReturn(null);
    when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
    when(mockPrefs.remove(any)).thenAnswer((_) async => true);
    repository = ProfileRepositoryImpl(
      remoteDataSource: mockDataSource,
      sharedPreferences: mockPrefs,
    );
  });

  group('US39 - Integración: Carga de perfil con roles', () {
    test('debe obtener perfil desde el datasource a través del repositorio y use case', () async {
      // Arrange
      when(mockDataSource.getProfile())
          .thenAnswer((_) async => tProfileModel);
      final useCase = GetProfileUseCase(repository);

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Debería ser Right'),
        (profile) {
          expect(profile.username, 'jperez');
          expect(profile.roles, contains('ROLE_MANAGER'));
          expect(profile.companyId, 'comp-1');
        },
      );
    });

    test('debe retornar ServerFailure cuando falla la carga del perfil', () async {
      // Arrange
      when(mockDataSource.getProfile())
          .thenThrow(ServerException(message: 'Unauthorized'));
      final useCase = GetProfileUseCase(repository);

      // Act
      final result = await useCase();

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('US42 - Integración: Actualización de perfil', () {
    test('debe actualizar perfil y limpiar caché', () async {
      // Arrange
      const updatedModel = ProfileModel(
        id: 'profile-1',
        userId: 'user-1',
        username: 'jperez',
        name: 'Juan Carlos',
        lastname: 'Pérez García',
        email: 'juancarlos@empresa.com',
        avatarUrl: 'new_avatar.png',
      );
      when(mockDataSource.updateProfile(any))
          .thenAnswer((_) async => updatedModel);
      final useCase = UpdateProfileUseCase(repository);

      // Act
      final result = await useCase(const ProfileEntity(
        id: 'profile-1',
        userId: 'user-1',
        username: 'jperez',
        name: 'Juan Carlos',
        lastname: 'Pérez García',
        email: 'juancarlos@empresa.com',
        avatarUrl: 'new_avatar.png',
      ));

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Debería ser Right'),
        (profile) => expect(profile.name, 'Juan Carlos'),
      );
    });
  });

  group('US44 - Integración: Miembros de la compañía', () {
    test('debe obtener miembros de la compañía pasando por todas las capas', () async {
      // Arrange
      when(mockDataSource.getCompanyMembers('comp-1'))
          .thenAnswer((_) async => [tProfileModel, tMemberModel]);
      final useCase = GetCompanyMembersUseCase(repository);

      // Act
      final result = await useCase('comp-1');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Debería ser Right'),
        (members) {
          expect(members.length, 2);
          expect(members.first.name, 'Juan');
          expect(members.last.name, 'María');
        },
      );
    });

    test('debe usar caché de miembros para la segunda llamada', () async {
      // Arrange
      when(mockDataSource.getCompanyMembers('comp-1'))
          .thenAnswer((_) async => [tProfileModel]);

      // Act
      await repository.getCompanyMembers('comp-1');
      final result = await repository.getCompanyMembers('comp-1');

      // Assert
      expect(result.isRight(), true);
      verify(mockDataSource.getCompanyMembers('comp-1')).called(1);
    });
  });

  group('US39 - Integración: Caché de perfil', () {
    test('debe usar caché en memoria para la segunda llamada de perfil', () async {
      // Arrange
      when(mockDataSource.getProfile())
          .thenAnswer((_) async => tProfileModel);

      // Act
      await repository.getProfile();
      final result = await repository.getProfile();

      // Assert
      expect(result.isRight(), true);
      verify(mockDataSource.getProfile()).called(1);
    });

    test('debe refrescar datos después de limpiar caché', () async {
      // Arrange
      when(mockDataSource.getProfile())
          .thenAnswer((_) async => tProfileModel);

      // Act
      await repository.getProfile();
      await repository.clearCache();
      await repository.getProfile();

      // Assert
      verify(mockDataSource.getProfile()).called(2);
    });
  });
}
