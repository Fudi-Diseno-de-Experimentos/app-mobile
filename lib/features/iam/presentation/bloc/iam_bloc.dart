import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/join_company_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import 'iam_event.dart';
import 'iam_state.dart';

class IamBloc extends Bloc<IamEvent, IamState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final JoinCompanyUseCase joinCompanyUseCase;

  IamBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.joinCompanyUseCase,
  }) : super(IamInitial()) {
    on<SignInSubmitted>(_onSignInSubmitted);
    on<SignUpSubmitted>(_onSignUpSubmitted);
    on<JoinCompanySubmitted>(_onJoinCompanySubmitted);
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
}
