import 'package:app_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<NotificationEntity> notifications;

  const NotificationsLoaded(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

extension NotificationStateX on NotificationState {
  List<NotificationEntity> get notificationsOrEmpty {
    final state = this;
    if (state is NotificationsLoaded) return state.notifications;
    return const [];
  }

  int get unreadCount {
    final state = this;
    if (state is NotificationsLoaded) {
      return state.notifications.where((n) => !n.isRead).length;
    }
    return 0;
  }
}
