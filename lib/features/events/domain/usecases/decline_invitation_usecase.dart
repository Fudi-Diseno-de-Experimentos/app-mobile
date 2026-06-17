import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/events/domain/entities/event_entity.dart';
import 'package:app_mobile/features/events/domain/repositories/event_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeclineInvitationUseCase {
  final EventRepository repository;

  DeclineInvitationUseCase(this.repository);

  Future<Either<Failure, EventEntity>> call(String eventId) {
    return repository.declineInvitation(eventId);
  }
}
