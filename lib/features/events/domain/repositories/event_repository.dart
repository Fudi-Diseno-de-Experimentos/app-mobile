import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/events/domain/entities/event_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class EventRepository {
  Future<Either<Failure, List<EventEntity>>> getEvents(
      {bool forceRefresh = false});
  Future<Either<Failure, EventEntity>> createEvent({
    required String title,
    required String description,
    required String date,
    required String spaceId,
    required String createdBy,
    required List<String> recipientIds,
  });
  Future<Either<Failure, EventEntity>> updateEvent({
    required String id,
    required String title,
    required String description,
    required String date,
    required String spaceId,
    required List<String> recipientIds,
  });
  Future<Either<Failure, Unit>> deleteEvent(String id);
  Future<void> clearCache();
}
