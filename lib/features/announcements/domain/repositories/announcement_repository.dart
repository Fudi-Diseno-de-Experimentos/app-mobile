import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/announcement_entity.dart';

abstract class AnnouncementRepository {
  Future<Either<Failure, List<AnnouncementEntity>>> getAnnouncements();
  Future<Either<Failure, AnnouncementEntity>> createAnnouncement({
    required String title,
    required String description,
    String? image,
    required String priority,
    required String createdBy,
  });
}
