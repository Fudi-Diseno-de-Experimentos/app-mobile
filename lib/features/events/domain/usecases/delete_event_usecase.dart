import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/event_repository.dart';

class DeleteEventUseCase {
  final EventRepository repository;

  DeleteEventUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String id) {
    return repository.deleteEvent(id);
  }
}
