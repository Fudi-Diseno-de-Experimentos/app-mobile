import 'package:app_mobile/features/analytics/domain/entities/user_announcement_view_entity.dart';

class UserAnnouncementViewModel extends UserAnnouncementViewEntity {
  const UserAnnouncementViewModel({
    required super.viewId,
    required super.announcementId,
    required super.announcementTitle,
    required super.announcementContent,
    required super.viewedAt,
    required super.userId,
    required super.userFullName,
    super.userImageUrl,
  });

  factory UserAnnouncementViewModel.fromJson(Map<String, dynamic> json) {
    return UserAnnouncementViewModel(
      viewId: json['viewId']?.toString() ?? '',
      announcementId: json['announcementId']?.toString() ?? '',
      announcementTitle: json['announcementTitle']?.toString() ?? '',
      announcementContent: json['announcementContent']?.toString() ?? json['announcementDescription']?.toString() ?? '',
      viewedAt: json['viewedAt']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userFullName: json['userFullName']?.toString() ?? '',
      userImageUrl: json['userImageUrl']?.toString(),
    );
  }
}
