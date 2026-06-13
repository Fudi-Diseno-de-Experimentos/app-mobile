import 'package:app_mobile/core/cache/ttl_cache.dart';
import 'package:app_mobile/core/error/exceptions.dart';
import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/events/data/datasources/event_remote_datasource.dart';
import 'package:app_mobile/features/events/data/models/event_model.dart';
import 'package:app_mobile/features/events/domain/entities/event_entity.dart';
import 'package:app_mobile/features/events/domain/repositories/event_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  final TtlCache<List<EventEntity>> _cache;

  EventRepositoryImpl({
    required this.remoteDataSource,
    required SharedPreferences sharedPreferences,
  }) : _cache = TtlCache(
          prefs: sharedPreferences,
          key: 'events_cache',
          ttl: const Duration(minutes: 5),
          fromJson: (json) => (json as List)
              .map<EventEntity>((item) => EventModel.fromJson(item))
              .toList(),
          // The cached list always comes from the remote datasource, whose
          // elements are EventModel instances.
          toJson: (list) =>
              list.map((item) => (item as EventModel).toJson()).toList(),
        );

  @override
  Future<void> clearCache() => _cache.clear();

  @override
  Future<Either<Failure, List<EventEntity>>> getEvents(
      {bool forceRefresh = false}) async {
    if (forceRefresh) {
      await clearCache();
    } else {
      final cached = _cache.get();
      if (cached != null) {
        return Right(cached);
      }
    }

    try {
      final remoteEvents = await remoteDataSource.getEvents();
      await _cache.set(remoteEvents);
      return Right(remoteEvents);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> createEvent({
    required String title,
    required String description,
    required String date,
    required String spaceId,
    required String createdBy,
    required List<String> recipientIds,
  }) async {
    try {
      final event = await remoteDataSource.createEvent(
        title: title,
        description: description,
        date: date,
        spaceId: spaceId,
        createdBy: createdBy,
        recipientIds: recipientIds,
      );
      await clearCache();
      return Right(event);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
    required String spaceId,
    required List<String> recipientIds,
  }) async {
    try {
      final event = await remoteDataSource.updateEvent(
        id: id,
        title: title,
        description: description,
        date: date,
        spaceId: spaceId,
        recipientIds: recipientIds,
      );
      await clearCache();
      return Right(event);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteEvent(String id) async {
    try {
      await remoteDataSource.deleteEvent(id);
      await clearCache();
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
