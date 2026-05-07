import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/announcement_entity.dart';
import '../repositories/announcement_repository.dart';

class GetAnnouncementsUseCase {
  final AnnouncementRepository repository;

  GetAnnouncementsUseCase(this.repository);

  Future<Either<Failure, List<AnnouncementEntity>>> call() {
    return repository.getAnnouncements();
  }
}
