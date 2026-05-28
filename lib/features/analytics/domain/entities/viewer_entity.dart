import 'package:equatable/equatable.dart';

class ViewerEntity extends Equatable {
  final String viewId;
  final String userId;
  final String userFullName;
  final String userEmail;
  final String viewedAt;
  final String contentId;
  final String contentTitle;
  final String? userImageUrl;

  const ViewerEntity({
    required this.viewId,
    required this.userId,
    required this.userFullName,
    required this.userEmail,
    required this.viewedAt,
    required this.contentId,
    required this.contentTitle,
    this.userImageUrl,
  });

  @override
  List<Object?> get props => [
        viewId,
        userId,
        userFullName,
        userEmail,
        viewedAt,
        contentId,
        contentTitle,
        userImageUrl,
      ];
}
