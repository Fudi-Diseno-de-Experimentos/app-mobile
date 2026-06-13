import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/events/domain/entities/event_entity.dart';
import 'package:app_mobile/features/events/domain/repositories/event_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateEventUseCase {
  final EventRepository repository;

  CreateEventUseCase(this.repository);

  Future<Either<Failure, EventEntity>> call({
    required String title,
    required String description,
    required String date,
    required String spaceId,
    required String createdBy,
    required List<String> recipientIds,
  }) {
    return repository.createEvent(
      title: title,
      description: description,
      date: date,
      spaceId: spaceId,
      createdBy: createdBy,
      recipientIds: recipientIds,
    );
  }
}
