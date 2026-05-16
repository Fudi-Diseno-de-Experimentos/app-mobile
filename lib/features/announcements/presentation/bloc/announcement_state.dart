import 'package:equatable/equatable.dart';
import '../../domain/entities/announcement_entity.dart';

abstract class AnnouncementState extends Equatable {
  const AnnouncementState();

  @override
  List<Object> get props => [];
}

class AnnouncementInitial extends AnnouncementState {}

class AnnouncementLoading extends AnnouncementState {}

class AnnouncementLoaded extends AnnouncementState {
  final List<AnnouncementEntity> announcements;

  const AnnouncementLoaded(this.announcements);

  @override
  List<Object> get props => [announcements];
}

class AnnouncementDetailLoaded extends AnnouncementState {
  final AnnouncementEntity announcement;

  const AnnouncementDetailLoaded(this.announcement);

  @override
  List<Object> get props => [announcement];
}

class AnnouncementCreateSuccess extends AnnouncementState {}

class AnnouncementUpdateSuccess extends AnnouncementState {
  final AnnouncementEntity announcement;

  const AnnouncementUpdateSuccess(this.announcement);

  @override
  List<Object> get props => [announcement];
}

class AnnouncementDeleteSuccess extends AnnouncementState {
  final String id;

  const AnnouncementDeleteSuccess(this.id);

  @override
  List<Object> get props => [id];
}

class AnnouncementError extends AnnouncementState {
  final String message;

  const AnnouncementError(this.message);

  @override
  List<Object> get props => [message];
}
