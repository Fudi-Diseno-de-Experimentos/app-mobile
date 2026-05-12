import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class UpdateEventUseCase {
  final EventRepository repository;

  UpdateEventUseCase(this.repository);

  Future<Either<Failure, EventEntity>> call({
    required String id,
    required String title,
    required String description,
    required String date,
    required String location,
    required List<String> recipientIds,
  }) {
    return repository.updateEvent(
      id: id,
      title: title,
      description: description,
      date: date,
      location: location,
      recipientIds: recipientIds,
    );
  }
}
