import 'package:app_mobile/features/iam/domain/usecases/join_company_usecase.dart';
import 'package:app_mobile/features/iam/domain/usecases/sign_in_usecase.dart';
import 'package:app_mobile/features/iam/domain/usecases/sign_out_usecase.dart';
import 'package:app_mobile/features/iam/domain/usecases/sign_up_usecase.dart';
import 'package:app_mobile/features/iam/presentation/bloc/iam_event.dart';
import 'package:app_mobile/features/iam/presentation/bloc/iam_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IamBloc extends Bloc<IamEvent, IamState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final JoinCompanyUseCase joinCompanyUseCase;
  final SignOutUseCase signOutUseCase;

  IamBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.joinCompanyUseCase,
    required this.signOutUseCase,
  }) : super(IamInitial()) {
    on<SignInSubmitted>(_onSignInSubmitted);
    on<SignUpSubmitted>(_onSignUpSubmitted);
    on<JoinCompanySubmitted>(_onJoinCompanySubmitted);
    on<SignOutSubmitted>(_onSignOutSubmitted);
  }

  Future<void> _onSignInSubmitted(
    SignInSubmitted event,
    Emitter<IamState> emit,
  ) async {
    emit(IamLoading());
    final result = await signInUseCase(event.username, event.password);
    result.fold(
      (failure) => emit(IamError(failure.message)),
      (user) => emit(IamSignInSuccess(user)),
    );
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<IamState> emit,
  ) async {
    emit(IamLoading());
    final result = await signUpUseCase(
      username: event.username,
      password: event.password,
      name: event.name,
      lastname: event.lastname,
      email: event.email,
      roles: event.roles,
    );
    result.fold(
      (failure) => emit(IamError(failure.message)),
      (_) => emit(IamSignUpSuccess()),
    );
  }

  Future<void> _onJoinCompanySubmitted(
    JoinCompanySubmitted event,
    Emitter<IamState> emit,
  ) async {
    emit(IamLoading());
    final result = await joinCompanyUseCase(event.joinCode);
    result.fold(
      (failure) => emit(IamError(failure.message)),
      (_) => emit(IamJoinCompanySuccess()),
    );
  }

  Future<void> _onSignOutSubmitted(
    SignOutSubmitted event,
    Emitter<IamState> emit,
  ) async {
    emit(IamLoading());
    final result = await signOutUseCase();
    result.fold(
      (failure) => emit(IamError(failure.message)),
      (_) => emit(IamSignOutSuccess()),
    );
  }
}
