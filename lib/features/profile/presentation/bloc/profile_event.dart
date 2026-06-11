import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {}

class ProfileReset extends ProfileEvent {}

class ProfileUpdateRequested extends ProfileEvent {
  final ProfileEntity profile;

  const ProfileUpdateRequested(this.profile);

  @override
  List<Object?> get props => [profile];
}
