import 'package:app_mobile/features/analytics/domain/entities/content_stats_entity.dart';
import 'package:app_mobile/features/analytics/domain/entities/user_announcement_view_entity.dart';
import 'package:app_mobile/features/analytics/domain/entities/user_event_view_entity.dart';
import 'package:app_mobile/features/analytics/domain/entities/viewer_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsViewRegistered extends AnalyticsState {
  final String contentId;
  final bool isNewView;

  const AnalyticsViewRegistered({
    required this.contentId,
    required this.isNewView,
  });

  @override
  List<Object> get props => [contentId, isNewView];
}

class AnalyticsStatsAndViewersLoading extends AnalyticsState {}

class AnalyticsStatsAndViewersLoaded extends AnalyticsState {
  final ContentStatsEntity stats;
  final List<ViewerEntity> viewers;

  const AnalyticsStatsAndViewersLoaded({
    required this.stats,
    required this.viewers,
  });

  @override
  List<Object> get props => [stats, viewers];
}

class AnalyticsStatsAndViewersError extends AnalyticsState {
  final String message;

  const AnalyticsStatsAndViewersError({required this.message});

  @override
  List<Object> get props => [message];
}

class AnalyticsUserHistoryLoading extends AnalyticsState {}

class AnalyticsUserHistoryLoaded extends AnalyticsState {
  final List<UserAnnouncementViewEntity> announcementViews;
  final List<UserEventViewEntity> eventViews;

  const AnalyticsUserHistoryLoaded({
    required this.announcementViews,
    required this.eventViews,
  });

  @override
  List<Object> get props => [announcementViews, eventViews];
}

class AnalyticsUserHistoryError extends AnalyticsState {
  final String message;

  const AnalyticsUserHistoryError({required this.message});

  @override
  List<Object> get props => [message];
}

