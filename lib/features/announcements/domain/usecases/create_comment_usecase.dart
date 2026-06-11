import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/announcements/domain/entities/comment_entity.dart';
import 'package:app_mobile/features/announcements/domain/repositories/comment_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateCommentUseCase {
  final CommentRepository repository;

  CreateCommentUseCase(this.repository);

  Future<Either<Failure, CommentEntity>> call({
    required String announcementId,
    required String content,
    required String authorId,
  }) {
    return repository.createComment(
      announcementId: announcementId,
      content: content,
      authorId: authorId,
    );
  }
}
