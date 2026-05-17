import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/view_registration_entity.dart';
import '../repositories/analytics_repository.dart';

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
