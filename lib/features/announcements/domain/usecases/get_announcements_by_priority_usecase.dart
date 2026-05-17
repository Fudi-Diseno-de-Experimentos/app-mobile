import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/announcement_entity.dart';
import '../repositories/announcement_repository.dart';

class GetAnnouncementsByPriorityUseCase {
  final AnnouncementRepository repository;

  GetAnnouncementsByPriorityUseCase(this.repository);

  Future<Either<Failure, List<AnnouncementEntity>>> call(String priority) {
    return repository.getAnnouncementsByPriority(priority);
  }
}
