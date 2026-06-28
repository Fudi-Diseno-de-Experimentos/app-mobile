import 'package:app_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:app_mobile/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:app_mobile/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:app_mobile/features/notifications/presentation/bloc/notification_event.dart';
import 'package:app_mobile/features/notifications/presentation/bloc/notification_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationAsReadUseCase,
  }) : super(NotificationInitial()) {
    on<FetchNotificationsList>(_onFetchNotificationsList);
    on<MarkNotificationRead>(_onMarkNotificationRead);
  }

  Future<void> _onFetchNotificationsList(
    FetchNotificationsList event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final result = await getNotificationsUseCase(event.userId);
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notifications) {
        // Sort notifications: most recent first (createdAt descending)
        final sorted = List<NotificationEntity>.from(notifications)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        emit(NotificationsLoaded(sorted));
      },
    );
  }

  Future<void> _onMarkNotificationRead(
    MarkNotificationRead event,
    Emitter<NotificationState> emit,
  ) async {
    // Optimistic local update
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final updatedList = currentState.notifications.map((n) {
        if (n.id == event.id) {
          // Return new instance with READ status
          return NotificationEntity(
            id: n.id,
            title: n.title,
            message: n.message,
            recipientIds: n.recipientIds,
            priority: n.priority,
            status: 'READ',
            createdAt: n.createdAt,
            updatedAt: n.updatedAt,
          );
        }
        return n;
      }).toList();
      emit(NotificationsLoaded(updatedList));
    }

    // Call server API
    await markNotificationAsReadUseCase(event.id);
  }
}
