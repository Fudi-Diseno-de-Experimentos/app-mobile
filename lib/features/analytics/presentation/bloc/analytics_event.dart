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

class FetchStatsAndViewersRequested extends AnalyticsEvent {
  final String contentId;
  final bool isEvent;
  final bool forceRefresh;

  const FetchStatsAndViewersRequested({
    required this.contentId,
    required this.isEvent,
    this.forceRefresh = false,
  });

  @override
  List<Object> get props => [contentId, isEvent, forceRefresh];
}

class FetchUserViewHistoryRequested extends AnalyticsEvent {
  final String userId;
  final bool forceRefresh;

  const FetchUserViewHistoryRequested({
    required this.userId,
    this.forceRefresh = false,
  });

  @override
  List<Object> get props => [userId, forceRefresh];
}

