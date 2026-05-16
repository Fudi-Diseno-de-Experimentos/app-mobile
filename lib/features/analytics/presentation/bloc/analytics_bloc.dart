import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/register_announcement_view_usecase.dart';
import '../../domain/usecases/register_event_view_usecase.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

/// Fire-and-forget view telemetry. Failures are intentionally swallowed: a
/// failed analytics ping must never surface an error to the user.
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final RegisterAnnouncementViewUseCase registerAnnouncementViewUseCase;
  final RegisterEventViewUseCase registerEventViewUseCase;

  AnalyticsBloc({
    required this.registerAnnouncementViewUseCase,
    required this.registerEventViewUseCase,
  }) : super(AnalyticsInitial()) {
    on<RegisterAnnouncementView>(_onRegisterAnnouncementView);
    on<RegisterEventView>(_onRegisterEventView);
  }

  Future<void> _onRegisterAnnouncementView(
    RegisterAnnouncementView event,
    Emitter<AnalyticsState> emit,
  ) async {
    final result = await registerAnnouncementViewUseCase(
      announcementId: event.announcementId,
      userId: event.userId,
    );
    result.fold(
      (_) {},
      (view) => emit(AnalyticsViewRegistered(
        contentId: view.contentId,
        isNewView: view.isNewView,
      )),
    );
  }

  Future<void> _onRegisterEventView(
    RegisterEventView event,
    Emitter<AnalyticsState> emit,
  ) async {
    final result = await registerEventViewUseCase(
      eventId: event.eventId,
      userId: event.userId,
    );
    result.fold(
      (_) {},
      (view) => emit(AnalyticsViewRegistered(
        contentId: view.contentId,
        isNewView: view.isNewView,
      )),
    );
  }
}
