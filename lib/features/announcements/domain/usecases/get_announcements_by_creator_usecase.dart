import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/announcement_entity.dart';
import '../repositories/announcement_repository.dart';

class GetAnnouncementsByCreatorUseCase {
  final AnnouncementRepository repository;

  GetAnnouncementsByCreatorUseCase(this.repository);

  Future<Either<Failure, List<AnnouncementEntity>>> call(String createdBy) {
    return repository.getAnnouncementsByCreator(createdBy);
  }
}
