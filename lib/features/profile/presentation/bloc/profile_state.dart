import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileUpdating extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdateSuccess extends ProfileState {
  final ProfileEntity profile;

  const ProfileUpdateSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

extension ProfileStateX on ProfileState {
  /// The loaded profile, regardless of which "has a profile" state we are in.
  ProfileEntity? get profileOrNull {
    final state = this;
    if (state is ProfileLoaded) return state.profile;
    if (state is ProfileUpdateSuccess) return state.profile;
    return null;
  }
}
