import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/comment_entity.dart';
import '../repositories/comment_repository.dart';

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
