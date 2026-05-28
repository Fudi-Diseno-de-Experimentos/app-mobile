import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_datasource.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  List<EventEntity>? _inMemoryCache;
  DateTime? _lastFetchTime;

  static const Duration _cacheTtl = Duration(minutes: 5);
  static const String _cacheKey = 'events_cache';
  static const String _cacheTimeKey = 'events_cache_time';

  EventRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
  });

  bool _isCacheValid(DateTime? lastFetch) {
    if (lastFetch == null) return false;
    return DateTime.now().difference(lastFetch) < _cacheTtl;
  }

  Future<List<EventEntity>?> _loadFromPersistentCache() async {
    try {
      final jsonStr = sharedPreferences.getString(_cacheKey);
      final timeStr = sharedPreferences.getString(_cacheTimeKey);
      if (jsonStr != null && timeStr != null) {
        final lastFetch = DateTime.tryParse(timeStr);
        if (_isCacheValid(lastFetch)) {
          final List<dynamic> decoded = jsonDecode(jsonStr);
          final list = decoded.map((item) => EventModel.fromJson(item)).toList();
          _inMemoryCache = list;
          _lastFetchTime = lastFetch;
          return list;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> _saveToCache(List<EventModel> list) async {
    try {
      final now = DateTime.now();
      _inMemoryCache = list;
      _lastFetchTime = now;
      
      final jsonList = list.map((item) => item.toJson()).toList();
      await sharedPreferences.setString(_cacheKey, jsonEncode(jsonList));
      await sharedPreferences.setString(_cacheTimeKey, now.toIso8601String());
    } catch (_) {}
  }

  @override
  Future<void> clearCache() async {
    _inMemoryCache = null;
    _lastFetchTime = null;
    await sharedPreferences.remove(_cacheKey);
    await sharedPreferences.remove(_cacheTimeKey);
  }

  @override
  Future<Either<Failure, List<EventEntity>>> getEvents() async {
    if (_inMemoryCache != null && _isCacheValid(_lastFetchTime)) {
      return Right(_inMemoryCache!);
    }

    final persistent = await _loadFromPersistentCache();
    if (persistent != null) {
      return Right(persistent);
    }

    try {
      final remoteEvents = await remoteDataSource.getEvents();
      await _saveToCache(remoteEvents);
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
      await clearCache();
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
      await clearCache();
      return Right(event);
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
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
