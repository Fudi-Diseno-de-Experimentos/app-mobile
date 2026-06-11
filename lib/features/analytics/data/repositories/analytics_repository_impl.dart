import 'package:app_mobile/core/error/exceptions.dart';
import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:app_mobile/features/analytics/domain/entities/content_stats_entity.dart';
import 'package:app_mobile/features/analytics/domain/entities/user_announcement_view_entity.dart';
import 'package:app_mobile/features/analytics/domain/entities/user_event_view_entity.dart';
import 'package:app_mobile/features/analytics/domain/entities/view_registration_entity.dart';
import 'package:app_mobile/features/analytics/domain/entities/viewer_entity.dart';
import 'package:app_mobile/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:fpdart/fpdart.dart';

class _CacheEntry<T> {
  final T data;
  final DateTime timestamp;

  _CacheEntry(this.data) : timestamp = DateTime.now();

  bool get isValid => DateTime.now().difference(timestamp).inMinutes < 5;
}

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  final Map<String, _CacheEntry<ContentStatsEntity>> _statsCache = {};
  final Map<String, _CacheEntry<List<ViewerEntity>>> _viewersCache = {};
  final Map<String, _CacheEntry<List<UserAnnouncementViewEntity>>> _userAnnouncementsCache = {};
  final Map<String, _CacheEntry<List<UserEventViewEntity>>> _userEventsCache = {};

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ViewRegistrationEntity>> registerAnnouncementView({
    required String announcementId,
    required String userId,
  }) async {
    try {
      final result = await remoteDataSource.registerAnnouncementView(
        announcementId: announcementId,
        userId: userId,
      );
      _statsCache.remove(announcementId);
      _viewersCache.remove(announcementId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ViewRegistrationEntity>> registerEventView({
    required String eventId,
    required String userId,
  }) async {
    try {
      final result = await remoteDataSource.registerEventView(
        eventId: eventId,
        userId: userId,
      );
      _statsCache.remove(eventId);
      _viewersCache.remove(eventId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ContentStatsEntity>> getAnnouncementStats(String id, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _statsCache[id];
      if (cached != null && cached.isValid) {
        return Right(cached.data);
      }
    }
    try {
      final result = await remoteDataSource.getAnnouncementStats(id);
      _statsCache[id] = _CacheEntry(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ContentStatsEntity>> getEventStats(String id, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _statsCache[id];
      if (cached != null && cached.isValid) {
        return Right(cached.data);
      }
    }
    try {
      final result = await remoteDataSource.getEventStats(id);
      _statsCache[id] = _CacheEntry(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ViewerEntity>>> getAnnouncementViewers(String id, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _viewersCache[id];
      if (cached != null && cached.isValid) {
        return Right(cached.data);
      }
    }
    try {
      final result = await remoteDataSource.getAnnouncementViewers(id);
      _viewersCache[id] = _CacheEntry(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ViewerEntity>>> getEventViewers(String id, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _viewersCache[id];
      if (cached != null && cached.isValid) {
        return Right(cached.data);
      }
    }
    try {
      final result = await remoteDataSource.getEventViewers(id);
      _viewersCache[id] = _CacheEntry(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserAnnouncementViewEntity>>> getUserAnnouncementViews(String userId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _userAnnouncementsCache[userId];
      if (cached != null && cached.isValid) {
        return Right(cached.data);
      }
    }
    try {
      final result = await remoteDataSource.getUserAnnouncementViews(userId);
      _userAnnouncementsCache[userId] = _CacheEntry(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserEventViewEntity>>> getUserEventViews(String userId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _userEventsCache[userId];
      if (cached != null && cached.isValid) {
        return Right(cached.data);
      }
    }
    try {
      final result = await remoteDataSource.getUserEventViews(userId);
      _userEventsCache[userId] = _CacheEntry(result);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> clearCache() async {
    _statsCache.clear();
    _viewersCache.clear();
    _userAnnouncementsCache.clear();
    _userEventsCache.clear();
  }
}

