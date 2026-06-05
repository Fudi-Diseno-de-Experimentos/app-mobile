import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_state.dart';

import '../../../../mocks/generate_mocks.mocks.dart';
import '../../../../mocks/mock_helpers.dart';

void main() {
  late MockGetProfileUseCase mockGetProfile;
  late MockUpdateProfileUseCase mockUpdateProfile;
  late ProfileBloc bloc;

  const tProfile = ProfileEntity(
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

  setUpAll(() => registerFallbackValues());

  setUp(() {
    mockGetProfile = MockGetProfileUseCase();
    mockUpdateProfile = MockUpdateProfileUseCase();
    bloc = ProfileBloc(
      getProfileUseCase: mockGetProfile,
      updateProfileUseCase: mockUpdateProfile,
    );
  });

  tearDown(() => bloc.close());

  group('US39 - Navegación basada en roles (carga de perfil)', () {
    blocTest<ProfileBloc, ProfileState>(
      'debe emitir [Loading, Loaded] al cargar perfil exitosamente',
      build: () {
        when(mockGetProfile())
            .thenAnswer((_) async => const Right(tProfile));
        return bloc;
      },
      act: (bloc) => bloc.add(ProfileLoadRequested()),
      expect: () => [
        ProfileLoading(),
        const ProfileLoaded(tProfile),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'debe emitir [Loading, Error] cuando falla la carga del perfil',
      build: () {
        when(mockGetProfile())
            .thenAnswer((_) async => const Left(ServerFailure('Token expirado')));
        return bloc;
      },
      act: (bloc) => bloc.add(ProfileLoadRequested()),
      expect: () => [
        ProfileLoading(),
        const ProfileError('Token expirado'),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'debe emitir ProfileInitial al hacer reset del perfil',
      seed: () => const ProfileLoaded(tProfile),
      build: () => bloc,
      act: (bloc) => bloc.add(ProfileReset()),
      expect: () => [
        ProfileInitial(),
      ],
    );
  });

  group('US42 - Actualización de perfil', () {
    blocTest<ProfileBloc, ProfileState>(
      'debe emitir [Updating, UpdateSuccess] al actualizar perfil exitosamente',
      build: () {
        const updatedProfile = ProfileEntity(
          id: 'profile-1',
          userId: 'user-1',
          username: 'jperez',
          name: 'Juan Carlos',
          lastname: 'Pérez García',
          email: 'juancarlos@empresa.com',
          roles: ['ROLE_USER', 'ROLE_MANAGER'],
          companyId: 'comp-1',
          avatarUrl: 'new_avatar.png',
        );
        when(mockUpdateProfile(any))
            .thenAnswer((_) async => const Right(updatedProfile));
        return bloc;
      },
      act: (bloc) => bloc.add(const ProfileUpdateRequested(ProfileEntity(
        id: 'profile-1',
        userId: 'user-1',
        username: 'jperez',
        name: 'Juan Carlos',
        lastname: 'Pérez García',
        email: 'juancarlos@empresa.com',
        avatarUrl: 'new_avatar.png',
      ))),
      expect: () => [
        ProfileUpdating(),
        isA<ProfileUpdateSuccess>(),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'debe emitir [Updating, Error] cuando falla la actualización del perfil',
      build: () {
        when(mockUpdateProfile(any))
            .thenAnswer((_) async => const Left(ServerFailure('Error al actualizar')));
        return bloc;
      },
      act: (bloc) => bloc.add(const ProfileUpdateRequested(tProfile)),
      expect: () => [
        ProfileUpdating(),
        const ProfileError('Error al actualizar'),
      ],
    );
  });
}
