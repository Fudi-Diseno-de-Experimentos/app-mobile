import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/comment_entity.dart';
import '../repositories/comment_repository.dart';

class GetCommentsUseCase {
  final CommentRepository repository;

  GetCommentsUseCase(this.repository);

  Future<Either<Failure, List<CommentEntity>>> call(String announcementId) {
    return repository.getComments(announcementId);
  }
}
