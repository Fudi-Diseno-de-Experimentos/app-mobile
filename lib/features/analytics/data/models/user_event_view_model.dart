import '../../domain/entities/user_event_view_entity.dart';

class UserEventViewModel extends UserEventViewEntity {
  const UserEventViewModel({
    required super.viewId,
    required super.eventId,
    required super.eventTitle,
    required super.eventDescription,
    required super.eventDate,
    super.eventLocation,
    required super.viewedAt,
    required super.userId,
    required super.userFullName,
    super.userImageUrl,
  });

  factory UserEventViewModel.fromJson(Map<String, dynamic> json) {
    return UserEventViewModel(
      viewId: json['viewId']?.toString() ?? '',
      eventId: json['eventId']?.toString() ?? '',
      eventTitle: json['eventTitle']?.toString() ?? '',
      eventDescription: json['eventDescription']?.toString() ?? '',
      eventDate: json['eventDate']?.toString() ?? '',
      eventLocation: json['eventLocation']?.toString(),
      viewedAt: json['viewedAt']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userFullName: json['userFullName']?.toString() ?? '',
      userImageUrl: json['userImageUrl']?.toString(),
    );
  }
}
