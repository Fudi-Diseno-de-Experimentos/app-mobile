import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/view_registration_entity.dart';
import '../entities/content_stats_entity.dart';
import '../entities/viewer_entity.dart';
import '../entities/user_announcement_view_entity.dart';
import '../entities/user_event_view_entity.dart';

abstract class AnalyticsRepository {
  Future<Either<Failure, ViewRegistrationEntity>> registerAnnouncementView({
    required String announcementId,
    required String userId,
  });
  Future<Either<Failure, ViewRegistrationEntity>> registerEventView({
    required String eventId,
    required String userId,
  });
  Future<Either<Failure, ContentStatsEntity>> getAnnouncementStats(String id, {bool forceRefresh = false});
  Future<Either<Failure, ContentStatsEntity>> getEventStats(String id, {bool forceRefresh = false});
  Future<Either<Failure, List<ViewerEntity>>> getAnnouncementViewers(String id, {bool forceRefresh = false});
  Future<Either<Failure, List<ViewerEntity>>> getEventViewers(String id, {bool forceRefresh = false});
  Future<Either<Failure, List<UserAnnouncementViewEntity>>> getUserAnnouncementViews(String userId, {bool forceRefresh = false});
  Future<Either<Failure, List<UserEventViewEntity>>> getUserEventViews(String userId, {bool forceRefresh = false});
  Future<void> clearCache();
}

