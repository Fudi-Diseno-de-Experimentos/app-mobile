import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/comment_entity.dart';

abstract class CommentRepository {
  Future<Either<Failure, List<CommentEntity>>> getComments(String announcementId);
  Future<Either<Failure, CommentEntity>> createComment({
    required String announcementId,
    required String content,
    required String authorId,
  });
  Future<Either<Failure, void>> deleteComment(String commentId);
}
