import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final List<String> recipientIds;
  final String priority;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.recipientIds,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isRead => status.toUpperCase() == 'READ';

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        recipientIds,
        priority,
        status,
        createdAt,
        updatedAt,
      ];
}
