import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/announcement_entity.dart';
import '../repositories/announcement_repository.dart';

class GetAnnouncementByIdUseCase {
  final AnnouncementRepository repository;

  GetAnnouncementByIdUseCase(this.repository);

  Future<Either<Failure, AnnouncementEntity>> call(String id) {
    return repository.getAnnouncementById(id);
  }
}
