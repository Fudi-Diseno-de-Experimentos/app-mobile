import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/announcements/domain/entities/comment_entity.dart';
import 'package:app_mobile/features/announcements/domain/repositories/comment_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetCommentsUseCase {
  final CommentRepository repository;

  GetCommentsUseCase(this.repository);

  Future<Either<Failure, List<CommentEntity>>> call(String announcementId,
      {bool forceRefresh = false}) {
    return repository.getComments(announcementId, forceRefresh: forceRefresh);
  }
}
