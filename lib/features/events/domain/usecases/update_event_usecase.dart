import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/events/domain/entities/event_entity.dart';
import 'package:app_mobile/features/events/domain/repositories/event_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateEventUseCase {
  final EventRepository repository;

  UpdateEventUseCase(this.repository);

  Future<Either<Failure, EventEntity>> call({
    required String id,
    required String title,
    required String description,
    required String date,
    required String location,
    String? spaceId,
    required List<String> recipientIds,
  }) {
    return repository.updateEvent(
      id: id,
      title: title,
      description: description,
      date: date,
      location: location,
      spaceId: spaceId,
      recipientIds: recipientIds,
    );
  }
}
