import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/analytics/domain/entities/analytics_update_entity.dart';
import 'package:app_mobile/features/analytics/domain/entities/user_announcement_view_entity.dart';
import 'package:app_mobile/features/analytics/domain/entities/user_event_view_entity.dart';
import 'package:app_mobile/features/analytics/domain/usecases/get_announcement_stats_usecase.dart';
import 'package:app_mobile/features/analytics/domain/usecases/get_announcement_viewers_usecase.dart';
import 'package:app_mobile/features/analytics/domain/usecases/get_event_stats_usecase.dart';
import 'package:app_mobile/features/analytics/domain/usecases/get_event_viewers_usecase.dart';
import 'package:app_mobile/features/analytics/domain/usecases/get_user_announcement_views_usecase.dart';
import 'package:app_mobile/features/analytics/domain/usecases/get_user_event_views_usecase.dart';
import 'package:app_mobile/features/analytics/domain/usecases/register_announcement_view_usecase.dart';
import 'package:app_mobile/features/analytics/domain/usecases/register_event_view_usecase.dart';
import 'package:app_mobile/features/analytics/domain/usecases/watch_analytics_updates_usecase.dart';
import 'package:app_mobile/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:app_mobile/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final RegisterAnnouncementViewUseCase registerAnnouncementViewUseCase;
  final RegisterEventViewUseCase registerEventViewUseCase;
  final GetAnnouncementStatsUseCase getAnnouncementStatsUseCase;
  final GetEventStatsUseCase getEventStatsUseCase;
  final GetAnnouncementViewersUseCase getAnnouncementViewersUseCase;
  final GetEventViewersUseCase getEventViewersUseCase;
  final GetUserAnnouncementViewsUseCase getUserAnnouncementViewsUseCase;
  final GetUserEventViewsUseCase getUserEventViewsUseCase;
  final WatchAnalyticsUpdatesUseCase watchAnalyticsUpdatesUseCase;

  AnalyticsBloc({
    required this.registerAnnouncementViewUseCase,
    required this.registerEventViewUseCase,
    required this.getAnnouncementStatsUseCase,
    required this.getEventStatsUseCase,
    required this.getAnnouncementViewersUseCase,
    required this.getEventViewersUseCase,
    required this.getUserAnnouncementViewsUseCase,
    required this.getUserEventViewsUseCase,
    required this.watchAnalyticsUpdatesUseCase,
  }) : super(AnalyticsInitial()) {
    on<RegisterAnnouncementView>(_onRegisterAnnouncementView);
    on<RegisterEventView>(_onRegisterEventView);
    on<FetchStatsAndViewersRequested>(_onFetchStatsAndViewers);
    on<FetchUserViewHistoryRequested>(_onFetchUserViewHistory);
  }

  Future<void> _onRegisterAnnouncementView(
    RegisterAnnouncementView event,
    Emitter<AnalyticsState> emit,
  ) async {
    await registerAnnouncementViewUseCase(
      announcementId: event.announcementId,
      userId: event.userId,
    );
  }

  Future<void> _onRegisterEventView(
    RegisterEventView event,
    Emitter<AnalyticsState> emit,
  ) async {
    await registerEventViewUseCase(
      eventId: event.eventId,
      userId: event.userId,
    );
  }

  Future<void> _onFetchStatsAndViewers(
    FetchStatsAndViewersRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsStatsAndViewersLoading());
    
    // 1. Initial REST load
    bool initialLoadSuccess = false;
    if (event.isEvent) {
      final statsResult = await getEventStatsUseCase(event.contentId, forceRefresh: event.forceRefresh);
      final viewersResult = await getEventViewersUseCase(event.contentId, forceRefresh: event.forceRefresh);

      statsResult.fold(
        (failure) => emit(AnalyticsStatsAndViewersError(message: failure.message)),
        (stats) {
          viewersResult.fold(
            (failure) => emit(AnalyticsStatsAndViewersError(message: failure.message)),
            (viewers) {
              emit(AnalyticsStatsAndViewersLoaded(stats: stats, viewers: viewers));
              initialLoadSuccess = true;
            },
          );
        },
      );
    } else {
      final statsResult = await getAnnouncementStatsUseCase(event.contentId, forceRefresh: event.forceRefresh);
      final viewersResult = await getAnnouncementViewersUseCase(event.contentId, forceRefresh: event.forceRefresh);

      statsResult.fold(
        (failure) => emit(AnalyticsStatsAndViewersError(message: failure.message)),
        (stats) {
          viewersResult.fold(
            (failure) => emit(AnalyticsStatsAndViewersError(message: failure.message)),
            (viewers) {
              emit(AnalyticsStatsAndViewersLoaded(stats: stats, viewers: viewers));
              initialLoadSuccess = true;
            },
          );
        },
      );
    }

    if (!initialLoadSuccess) return;

    // 2. Subscribe to real-time SSE updates
    await emit.forEach<Either<Failure, AnalyticsUpdateEntity>>(
      watchAnalyticsUpdatesUseCase(contentId: event.contentId, isEvent: event.isEvent),
      onData: (eitherResult) {
        return eitherResult.fold(
          (failure) => AnalyticsStatsAndViewersError(message: failure.message),
          (update) => AnalyticsStatsAndViewersLoaded(
            stats: update.stats,
            viewers: update.viewers,
          ),
        );
      },
      onError: (error, stackTrace) {
        return AnalyticsStatsAndViewersError(message: error.toString());
      },
    );
  }

  Future<void> _onFetchUserViewHistory(
    FetchUserViewHistoryRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsUserHistoryLoading());
    final results = await Future.wait([
      getUserAnnouncementViewsUseCase(event.userId, forceRefresh: event.forceRefresh),
      getUserEventViewsUseCase(event.userId, forceRefresh: event.forceRefresh),
    ]);

    final announcementsRes = results[0];
    final eventsRes = results[1];

    announcementsRes.fold(
      (failure) => emit(AnalyticsUserHistoryError(message: failure.message)),
      (announcements) {
        eventsRes.fold(
          (failure) => emit(AnalyticsUserHistoryError(message: failure.message)),
          (events) => emit(AnalyticsUserHistoryLoaded(
            announcementViews: announcements as List<UserAnnouncementViewEntity>,
            eventViews: events as List<UserEventViewEntity>,
          )),
        );
      },
    );
  }
}

