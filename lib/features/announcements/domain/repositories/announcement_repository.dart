import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/announcements/domain/entities/announcement_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class AnnouncementRepository {
  Future<Either<Failure, List<AnnouncementEntity>>> getAnnouncements(
      {bool forceRefresh = false});
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
  Future<Either<Failure, Unit>> deleteAnnouncement(String id);
  Future<void> clearCache();
}
