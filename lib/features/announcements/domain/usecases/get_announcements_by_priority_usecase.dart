import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/announcements/domain/entities/announcement_entity.dart';
import 'package:app_mobile/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAnnouncementsByPriorityUseCase {
  final AnnouncementRepository repository;

  GetAnnouncementsByPriorityUseCase(this.repository);

  Future<Either<Failure, List<AnnouncementEntity>>> call(String priority) {
    return repository.getAnnouncementsByPriority(priority);
  }
}
