import 'package:equatable/equatable.dart';

class UserAnnouncementViewEntity extends Equatable {
  final String viewId;
  final String announcementId;
  final String announcementTitle;
  final String announcementContent;
  final String viewedAt;
  final String userId;
  final String userFullName;

  const UserAnnouncementViewEntity({
    required this.viewId,
    required this.announcementId,
    required this.announcementTitle,
    required this.announcementContent,
    required this.viewedAt,
    required this.userId,
    required this.userFullName,
  });

  @override
  List<Object?> get props => [
        viewId,
        announcementId,
        announcementTitle,
        announcementContent,
        viewedAt,
        userId,
        userFullName,
      ];
}
