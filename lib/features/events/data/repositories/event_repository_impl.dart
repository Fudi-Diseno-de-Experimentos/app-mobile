import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_datasource.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  EventRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<EventEntity>>> getEvents() async {
    try {
      final remoteEvents = await remoteDataSource.getEvents();
      return Right(remoteEvents);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> createEvent({
    required String title,
    required String description,
    required String date,
    required String location,
    required String createdBy,
    required List<String> recipientIds,
  }) async {
    try {
      final event = await remoteDataSource.createEvent(
        title: title,
        description: description,
        date: date,
        location: location,
        createdBy: createdBy,
        recipientIds: recipientIds,
      );
      return Right(event);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> updateEvent({
    required String id,
    required String title,
    required String description,
    required String date,
    required String location,
    required List<String> recipientIds,
  }) async {
    try {
      final event = await remoteDataSource.updateEvent(
        id: id,
        title: title,
        description: description,
        date: date,
        location: location,
        recipientIds: recipientIds,
      );
      return Right(event);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteEvent(String id) async {
    try {
      await remoteDataSource.deleteEvent(id);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
