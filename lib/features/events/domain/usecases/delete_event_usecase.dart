import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/events/domain/repositories/event_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteEventUseCase {
  final EventRepository repository;

  DeleteEventUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String id) {
    return repository.deleteEvent(id);
  }
}
