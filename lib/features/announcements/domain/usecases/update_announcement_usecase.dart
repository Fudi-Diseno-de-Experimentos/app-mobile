import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/announcements/domain/entities/announcement_entity.dart';
import 'package:app_mobile/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:fpdart/fpdart.dart';

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
