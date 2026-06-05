import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/iam/domain/entities/user_entity.dart';
import 'package:app_mobile/features/iam/presentation/bloc/iam_bloc.dart';
import 'package:app_mobile/features/iam/presentation/bloc/iam_event.dart';
import 'package:app_mobile/features/iam/presentation/bloc/iam_state.dart';

import '../../../../mocks/generate_mocks.mocks.dart';
import '../../../../mocks/mock_helpers.dart';

void main() {
  late MockSignInUseCase mockSignIn;
  late MockSignUpUseCase mockSignUp;
  late MockSignOutUseCase mockSignOut;
  late MockJoinCompanyUseCase mockJoinCompany;
  late IamBloc bloc;

  const tUser = UserEntity(
    id: 'user-1',
    username: 'admin',
    token: 'jwt-token-123',
    companyId: 'comp-1',
  );

  setUpAll(() => registerFallbackValues());

  setUp(() {
    mockSignIn = MockSignInUseCase();
    mockSignUp = MockSignUpUseCase();
    mockSignOut = MockSignOutUseCase();
    mockJoinCompany = MockJoinCompanyUseCase();
    bloc = IamBloc(
      signInUseCase: mockSignIn,
      signUpUseCase: mockSignUp,
      joinCompanyUseCase: mockJoinCompany,
      signOutUseCase: mockSignOut,
    );
  });

  tearDown(() => bloc.close());

  group('US38 - Autenticación segura con JWT', () {
    blocTest<IamBloc, IamState>(
      'debe emitir [Loading, SignInSuccess] al iniciar sesión exitosamente',
      build: () {
        when(mockSignIn('admin', '123456'))
            .thenAnswer((_) async => const Right(tUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignInSubmitted(
        username: 'admin',
        password: '123456',
      )),
      expect: () => [
        IamLoading(),
        const IamSignInSuccess(tUser),
      ],
    );

    blocTest<IamBloc, IamState>(
      'debe emitir [Loading, Error] con credenciales inválidas',
      build: () {
        when(mockSignIn('admin', 'wrong'))
            .thenAnswer((_) async => const Left(ServerFailure('Credenciales inválidas')));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignInSubmitted(
        username: 'admin',
        password: 'wrong',
      )),
      expect: () => [
        IamLoading(),
        const IamError('Credenciales inválidas'),
      ],
    );
  });

  group('US33 - Validar y almacenar datos de usuario al registrarse', () {
    blocTest<IamBloc, IamState>(
      'debe emitir [Loading, SignUpSuccess] al registrarse exitosamente',
      build: () {
        when(mockSignUp(
          username: anyNamed('username'),
          password: anyNamed('password'),
          name: anyNamed('name'),
          lastname: anyNamed('lastname'),
          email: anyNamed('email'),
          roles: anyNamed('roles'),
        )).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignUpSubmitted(
        username: 'nuevo_usuario',
        password: 'password123',
        name: 'Juan',
        lastname: 'Pérez',
        email: 'juan@empresa.com',
      )),
      expect: () => [
        IamLoading(),
        IamSignUpSuccess(),
      ],
    );

    blocTest<IamBloc, IamState>(
      'debe emitir [Loading, Error] cuando el correo ya está registrado',
      build: () {
        when(mockSignUp(
          username: anyNamed('username'),
          password: anyNamed('password'),
          name: anyNamed('name'),
          lastname: anyNamed('lastname'),
          email: anyNamed('email'),
          roles: anyNamed('roles'),
        )).thenAnswer((_) async => const Left(ServerFailure('El correo ya está en uso')));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignUpSubmitted(
        username: 'duplicado',
        password: 'password123',
        name: 'Test',
        lastname: 'User',
        email: 'existente@empresa.com',
      )),
      expect: () => [
        IamLoading(),
        const IamError('El correo ya está en uso'),
      ],
    );
  });

  group('US36 - Cierre de sesión seguro', () {
    blocTest<IamBloc, IamState>(
      'debe emitir [Loading, SignOutSuccess] al cerrar sesión exitosamente',
      build: () {
        when(mockSignOut())
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignOutSubmitted()),
      expect: () => [
        IamLoading(),
        IamSignOutSuccess(),
      ],
    );

    blocTest<IamBloc, IamState>(
      'debe emitir [Loading, Error] cuando falla el cierre de sesión',
      build: () {
        when(mockSignOut())
            .thenAnswer((_) async => const Left(ServerFailure('Error al cerrar sesión')));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignOutSubmitted()),
      expect: () => [
        IamLoading(),
        const IamError('Error al cerrar sesión'),
      ],
    );
  });

  group('US44 - Unirse a una compañía', () {
    blocTest<IamBloc, IamState>(
      'debe emitir [Loading, JoinCompanySuccess] al unirse exitosamente',
      build: () {
        when(mockJoinCompany('ABC123'))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const JoinCompanySubmitted(joinCode: 'ABC123')),
      expect: () => [
        IamLoading(),
        IamJoinCompanySuccess(),
      ],
    );

    blocTest<IamBloc, IamState>(
      'debe emitir [Loading, Error] con código inválido',
      build: () {
        when(mockJoinCompany('INVALID'))
            .thenAnswer((_) async => const Left(ServerFailure('Código inválido')));
        return bloc;
      },
      act: (bloc) => bloc.add(const JoinCompanySubmitted(joinCode: 'INVALID')),
      expect: () => [
        IamLoading(),
        const IamError('Código inválido'),
      ],
    );
  });
}
