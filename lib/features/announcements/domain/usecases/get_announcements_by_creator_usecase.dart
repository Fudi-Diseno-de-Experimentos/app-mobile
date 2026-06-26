import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/announcements/domain/entities/announcement_entity.dart';
import 'package:app_mobile/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAnnouncementsByCreatorUseCase {
  final AnnouncementRepository repository;

  GetAnnouncementsByCreatorUseCase(this.repository);

  Future<Either<Failure, List<AnnouncementEntity>>> call(String createdBy) {
    return repository.getAnnouncementsByCreator(createdBy);
  }
}
