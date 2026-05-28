import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/announcement_entity.dart';

abstract class AnnouncementRepository {
  Future<Either<Failure, List<AnnouncementEntity>>> getAnnouncements();
  Future<Either<Failure, AnnouncementEntity>> getAnnouncementById(String id);
  Future<Either<Failure, List<AnnouncementEntity>>> getAnnouncementsByPriority(
    String priority,
  );
  Future<Either<Failure, List<AnnouncementEntity>>> getAnnouncementsByCreator(
    String createdBy,
  );
  Future<Either<Failure, AnnouncementEntity>> createAnnouncement({
    required String title,
    required String description,
    String? image,
    required String priority,
    required String createdBy,
  });
  Future<Either<Failure, AnnouncementEntity>> updateAnnouncement({
    required String id,
    required String title,
    required String description,
    String? image,
    required String priority,
  });
  Future<Either<Failure, void>> deleteAnnouncement(String id);
  Future<void> clearCache();
}
