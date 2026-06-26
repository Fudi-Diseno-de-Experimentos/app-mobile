import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteAnnouncementUseCase {
  final AnnouncementRepository repository;
  DeleteAnnouncementUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String id) => repository.deleteAnnouncement(id);
}
