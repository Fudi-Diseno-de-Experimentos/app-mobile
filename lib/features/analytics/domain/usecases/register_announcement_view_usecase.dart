import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/analytics/domain/entities/view_registration_entity.dart';
import 'package:app_mobile/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:fpdart/fpdart.dart';

class RegisterAnnouncementViewUseCase {
  final AnalyticsRepository repository;

  RegisterAnnouncementViewUseCase(this.repository);

  Future<Either<Failure, ViewRegistrationEntity>> call({
    required String announcementId,
    required String userId,
  }) {
    return repository.registerAnnouncementView(
      announcementId: announcementId,
      userId: userId,
    );
  }
}
