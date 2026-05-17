import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object> get props => [];
}

class RegisterAnnouncementView extends AnalyticsEvent {
  final String announcementId;
  final String userId;

  const RegisterAnnouncementView({
    required this.announcementId,
    required this.userId,
  });

  @override
  List<Object> get props => [announcementId, userId];
}

class RegisterEventView extends AnalyticsEvent {
  final String eventId;
  final String userId;

  const RegisterEventView({
    required this.eventId,
    required this.userId,
  });

  @override
  List<Object> get props => [eventId, userId];
}
