import 'package:app_mobile/features/announcements/domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.announcementId,
    required super.content,
    required super.authorId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        id: json['id']?.toString() ?? '',
        announcementId: json['announcementId']?.toString() ?? '',
        content: json['content'] ?? '',
        // API field is `employeeId` (CommentResource); map to domain authorId.
        authorId: json['employeeId']?.toString() ?? '',
        createdAt: json['createdAt']?.toString() ?? '',
        updatedAt: json['updatedAt']?.toString() ?? '',
      );
}
