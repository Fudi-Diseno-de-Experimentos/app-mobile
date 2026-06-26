import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/announcements/domain/repositories/comment_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteCommentUseCase {
  final CommentRepository repository;

  DeleteCommentUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String commentId) {
    return repository.deleteComment(commentId);
  }
}
