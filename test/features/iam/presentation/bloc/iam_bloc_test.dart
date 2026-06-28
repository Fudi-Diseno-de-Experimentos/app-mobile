import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/core/network/notification_service.dart';
import 'package:app_mobile/features/iam/domain/entities/user_entity.dart';
import 'package:app_mobile/features/iam/presentation/bloc/iam_bloc.dart';
import 'package:app_mobile/features/iam/presentation/bloc/iam_event.dart';
import 'package:app_mobile/features/iam/presentation/bloc/iam_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/generate_mocks.mocks.dart';
import '../../../../mocks/mock_helpers.dart';

void main() {
  late MockSignInUseCase mockSignIn;
  late MockSignUpUseCase mockSignUp;
  late MockSignOutUseCase mockSignOut;
  late MockJoinCompanyUseCase mockJoinCompany;
  late MockNotificationService mockNotificationService;
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
    mockNotificationService = MockNotificationService();

    // Register NotificationService mock in GetIt (sl)
    if (sl.isRegistered<NotificationService>()) {
      sl.unregister<NotificationService>();
    }
    sl.registerSingleton<NotificationService>(mockNotificationService);

    // Mock NotificationService methods to avoid unhandled exceptions
    when(mockNotificationService.initialize()).thenAnswer((_) async {});
    when(mockNotificationService.unregisterToken(any)).thenAnswer((_) async {});

    bloc = IamBloc(
      signInUseCase: mockSignIn,
      signUpUseCase: mockSignUp,
      joinCompanyUseCase: mockJoinCompany,
      signOutUseCase: mockSignOut,
    );
  });

  tearDown(() async {
    await bloc.close();
    if (sl.isRegistered<NotificationService>()) {
      await sl.unregister<NotificationService>();
    }
  });

  group('US38 - Secure JWT authentication', () {
    blocTest<IamBloc, IamState>(
      'should emit [Loading, SignInSuccess] when signing in successfully',
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
      'should emit [Loading, Error] with invalid credentials',
      build: () {
        when(mockSignIn('admin', 'wrong'))
            .thenAnswer((_) async => const Left(ServerFailure('Invalid credentials')));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignInSubmitted(
        username: 'admin',
        password: 'wrong',
      )),
      expect: () => [
        IamLoading(),
        const IamError('Invalid credentials'),
      ],
    );
  });

  group('US33 - Validate and store user data on registration', () {
    blocTest<IamBloc, IamState>(
      'should emit [Loading, SignUpSuccess] when registering successfully',
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
      'should emit [Loading, Error] when the email is already registered',
      build: () {
        when(mockSignUp(
          username: anyNamed('username'),
          password: anyNamed('password'),
          name: anyNamed('name'),
          lastname: anyNamed('lastname'),
          email: anyNamed('email'),
          roles: anyNamed('roles'),
        )).thenAnswer((_) async => const Left(ServerFailure('The email is already in use')));
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
        const IamError('The email is already in use'),
      ],
    );
  });

  group('US36 - Secure sign-out', () {
    blocTest<IamBloc, IamState>(
      'should emit [Loading, SignOutSuccess] when signing out successfully',
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
      'should emit [Loading, Error] when sign-out fails',
      build: () {
        when(mockSignOut())
            .thenAnswer((_) async => const Left(ServerFailure('Sign-out failed')));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignOutSubmitted()),
      expect: () => [
        IamLoading(),
        const IamError('Sign-out failed'),
      ],
    );
  });

  group('US44 - Join a company', () {
    blocTest<IamBloc, IamState>(
      'should emit [Loading, JoinCompanySuccess] when joining successfully',
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
      'should emit [Loading, Error] with an invalid code',
      build: () {
        when(mockJoinCompany('INVALID'))
            .thenAnswer((_) async => const Left(ServerFailure('Invalid code')));
        return bloc;
      },
      act: (bloc) => bloc.add(const JoinCompanySubmitted(joinCode: 'INVALID')),
      expect: () => [
        IamLoading(),
        const IamError('Invalid code'),
      ],
    );
  });
}
