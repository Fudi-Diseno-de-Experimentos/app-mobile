import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/announcement_entity.dart';
import '../repositories/announcement_repository.dart';

class UpdateAnnouncementUseCase {
  final AnnouncementRepository repository;
  UpdateAnnouncementUseCase(this.repository);

  Future<Either<Failure, AnnouncementEntity>> call({
    required String id,
    required String title,
    required String description,
    String? image,
    required String priority,
  }) =>
      repository.updateAnnouncement(
        id: id,
        title: title,
        description: description,
        image: image,
        priority: priority,
      );
}
