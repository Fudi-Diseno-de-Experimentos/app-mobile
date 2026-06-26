import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/analytics/domain/entities/view_registration_entity.dart';
import 'package:app_mobile/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:fpdart/fpdart.dart';

class RegisterEventViewUseCase {
  final AnalyticsRepository repository;

  RegisterEventViewUseCase(this.repository);

  Future<Either<Failure, ViewRegistrationEntity>> call({
    required String eventId,
    required String userId,
  }) {
    return repository.registerEventView(
      eventId: eventId,
      userId: userId,
    );
  }
}
