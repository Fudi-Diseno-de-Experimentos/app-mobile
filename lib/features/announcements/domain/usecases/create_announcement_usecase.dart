import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/announcement_entity.dart';
import '../repositories/announcement_repository.dart';

class CreateAnnouncementUseCase {
  final AnnouncementRepository repository;

  CreateAnnouncementUseCase(this.repository);

  Future<Either<Failure, AnnouncementEntity>> call({
    required String title,
    required String description,
    String? image,
    required String priority,
    required String createdBy,
  }) {
    return repository.createAnnouncement(
      title: title,
      description: description,
      image: image,
      priority: priority,
      createdBy: createdBy,
    );
  }
}
