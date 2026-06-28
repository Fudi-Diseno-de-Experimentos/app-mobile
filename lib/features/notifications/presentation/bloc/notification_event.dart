import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotificationsList extends NotificationEvent {
  final String userId;

  const FetchNotificationsList(this.userId);

  @override
  List<Object?> get props => [userId];
}

class MarkNotificationRead extends NotificationEvent {
  final String id;

  const MarkNotificationRead(this.id);

  @override
  List<Object?> get props => [id];
}
