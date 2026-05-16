import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/view_registration_entity.dart';

abstract class AnalyticsRepository {
  Future<Either<Failure, ViewRegistrationEntity>> registerAnnouncementView({
    required String announcementId,
    required String userId,
  });
  Future<Either<Failure, ViewRegistrationEntity>> registerEventView({
    required String eventId,
    required String userId,
  });
}
