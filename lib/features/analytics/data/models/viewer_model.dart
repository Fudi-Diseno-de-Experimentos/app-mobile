import '../../domain/entities/viewer_entity.dart';

class ViewerModel extends ViewerEntity {
  const ViewerModel({
    required super.viewId,
    required super.userId,
    required super.userFullName,
    required super.userEmail,
    required super.viewedAt,
    required super.contentId,
    required super.contentTitle,
    super.userImageUrl,
  });

  factory ViewerModel.fromJson(Map<String, dynamic> json) {
    return ViewerModel(
      viewId: json['viewId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userFullName: json['userFullName']?.toString() ?? '',
      userEmail: json['userEmail']?.toString() ?? '',
      viewedAt: json['viewedAt']?.toString() ?? '',
      contentId: json['announcementId']?.toString() ?? json['eventId']?.toString() ?? '',
      contentTitle: json['announcementTitle']?.toString() ?? json['eventTitle']?.toString() ?? '',
      userImageUrl: json['userImageUrl']?.toString(),
    );
  }
}
