import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class CreateEventUseCase {
  final EventRepository repository;

  CreateEventUseCase(this.repository);

  Future<Either<Failure, EventEntity>> call({
    required String title,
    required String description,
    required String date,
    required String location,
    required String createdBy,
    required List<String> recipientIds,
  }) {
    return repository.createEvent(
      title: title,
      description: description,
      date: date,
      location: location,
      createdBy: createdBy,
      recipientIds: recipientIds,
    );
  }
}
