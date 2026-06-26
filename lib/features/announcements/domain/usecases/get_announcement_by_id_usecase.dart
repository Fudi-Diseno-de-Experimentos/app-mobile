import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/announcements/domain/entities/announcement_entity.dart';
import 'package:app_mobile/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAnnouncementByIdUseCase {
  final AnnouncementRepository repository;

  GetAnnouncementByIdUseCase(this.repository);

  Future<Either<Failure, AnnouncementEntity>> call(String id) {
    return repository.getAnnouncementById(id);
  }
}
