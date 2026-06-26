import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/announcements/domain/entities/comment_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class CommentRepository {
  Future<Either<Failure, List<CommentEntity>>> getComments(
      String announcementId, {bool forceRefresh = false});
  Future<Either<Failure, CommentEntity>> createComment({
    required String announcementId,
    required String content,
    required String authorId,
  });
  Future<Either<Failure, Unit>> deleteComment(String commentId);
  Future<void> clearCache();
}
