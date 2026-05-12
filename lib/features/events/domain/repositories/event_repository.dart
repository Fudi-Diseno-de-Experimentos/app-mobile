import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/event_entity.dart';

abstract class EventRepository {
  Future<Either<Failure, List<EventEntity>>> getEvents();
  Future<Either<Failure, EventEntity>> createEvent({
    required String title,
    required String description,
    required String date,
    required String location,
    required String createdBy,
    required List<String> recipientIds,
  });
}
