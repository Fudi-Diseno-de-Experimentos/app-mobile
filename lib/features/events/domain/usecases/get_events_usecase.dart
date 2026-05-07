import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class GetEventsUseCase {
  final EventRepository repository;

  GetEventsUseCase(this.repository);

  Future<Either<Failure, List<EventEntity>>> call() {
    return repository.getEvents();
  }
}
