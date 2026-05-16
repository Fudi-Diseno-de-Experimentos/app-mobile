import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/announcement_repository.dart';

class DeleteAnnouncementUseCase {
  final AnnouncementRepository repository;
  DeleteAnnouncementUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) => repository.deleteAnnouncement(id);
}
