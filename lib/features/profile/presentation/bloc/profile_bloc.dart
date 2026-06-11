import 'package:app_mobile/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:app_mobile/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileReset>(_onProfileReset);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  void _onProfileReset(
    ProfileReset event,
    Emitter<ProfileState> emit,
  ) {
    emit(ProfileInitial());
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await getProfileUseCase();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdating());
    final result = await updateProfileUseCase(event.profile);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) {
        // Momentary state for success listeners (snackbars), then settle on
        // ProfileLoaded so consumers only ever branch on one loaded state.
        emit(ProfileUpdateSuccess(profile));
        emit(ProfileLoaded(profile));
      },
    );
  }
}
