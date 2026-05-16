import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String announcementId;
  final String content;
  final String authorId;
  final String createdAt;
  final String updatedAt;

  const CommentEntity({
    required this.id,
    required this.announcementId,
    required this.content,
    required this.authorId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object> get props => [id, announcementId, content, authorId, createdAt, updatedAt];
}
