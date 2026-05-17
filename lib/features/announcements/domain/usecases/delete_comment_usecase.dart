import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/comment_repository.dart';

class DeleteCommentUseCase {
  final CommentRepository repository;

  DeleteCommentUseCase(this.repository);

  Future<Either<Failure, void>> call(String commentId) {
    return repository.deleteComment(commentId);
  }
}
