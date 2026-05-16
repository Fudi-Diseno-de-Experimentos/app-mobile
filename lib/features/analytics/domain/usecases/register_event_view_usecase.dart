import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/view_registration_entity.dart';
import '../repositories/analytics_repository.dart';

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
