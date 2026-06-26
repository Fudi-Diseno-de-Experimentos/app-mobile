import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/events/domain/entities/event_entity.dart';
import 'package:app_mobile/features/events/domain/repositories/event_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetEventsUseCase {
  final EventRepository repository;

  GetEventsUseCase(this.repository);

  Future<Either<Failure, List<EventEntity>>> call({
    bool forceRefresh = false,
    String? userId,
    String? filterType,
  }) {
    return repository.getEvents(
      forceRefresh: forceRefresh,
      userId: userId,
      filterType: filterType,
    );
  }
}
