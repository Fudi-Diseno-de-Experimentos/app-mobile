import 'package:equatable/equatable.dart';

class UserEventViewEntity extends Equatable {
  final String viewId;
  final String eventId;
  final String eventTitle;
  final String eventDescription;
  final String eventDate;
  final String? eventLocation;
  final String viewedAt;
  final String userId;
  final String userFullName;
  final String? userImageUrl;

  const UserEventViewEntity({
    required this.viewId,
    required this.eventId,
    required this.eventTitle,
    required this.eventDescription,
    required this.eventDate,
    this.eventLocation,
    required this.viewedAt,
    required this.userId,
    required this.userFullName,
    this.userImageUrl,
  });

  @override
  List<Object?> get props => [
        viewId,
        eventId,
        eventTitle,
        eventDescription,
        eventDate,
        eventLocation,
        viewedAt,
        userId,
        userFullName,
        userImageUrl,
      ];
}
