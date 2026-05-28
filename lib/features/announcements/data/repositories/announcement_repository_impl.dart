import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../datasources/announcement_remote_datasource.dart';
import '../models/announcement_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final AnnouncementRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  List<AnnouncementEntity>? _inMemoryCache;
  DateTime? _lastFetchTime;

  static const Duration _cacheTtl = Duration(minutes: 5);
  static const String _cacheKey = 'announcements_cache';
  static const String _cacheTimeKey = 'announcements_cache_time';

  AnnouncementRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
  });

  bool _isCacheValid(DateTime? lastFetch) {
    if (lastFetch == null) return false;
    return DateTime.now().difference(lastFetch) < _cacheTtl;
  }

  Future<List<AnnouncementEntity>?> _loadFromPersistentCache() async {
    try {
      final jsonStr = sharedPreferences.getString(_cacheKey);
      final timeStr = sharedPreferences.getString(_cacheTimeKey);
      if (jsonStr != null && timeStr != null) {
        final lastFetch = DateTime.tryParse(timeStr);
        if (_isCacheValid(lastFetch)) {
          final List<dynamic> decoded = jsonDecode(jsonStr);
          final list = decoded.map((item) => AnnouncementModel.fromJson(item)).toList();
          _inMemoryCache = list;
          _lastFetchTime = lastFetch;
          return list;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> _saveToCache(List<AnnouncementModel> list) async {
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
  Future<Either<Failure, List<AnnouncementEntity>>> getAnnouncements() async {
    if (_inMemoryCache != null && _isCacheValid(_lastFetchTime)) {
      return Right(_inMemoryCache!);
    }

    final persistent = await _loadFromPersistentCache();
    if (persistent != null) {
      return Right(persistent);
    }

    try {
      final remoteAnnouncements = await remoteDataSource.getAnnouncements();
      await _saveToCache(remoteAnnouncements);
      return Right(remoteAnnouncements);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnnouncementEntity>> getAnnouncementById(
      String id) async {
    if (_inMemoryCache != null && _isCacheValid(_lastFetchTime)) {
      try {
        final announcement = _inMemoryCache!.firstWhere((a) => a.id == id);
        return Right(announcement);
      } catch (_) {}
    }
    try {
      final announcement = await remoteDataSource.getAnnouncementById(id);
      return Right(announcement);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AnnouncementEntity>>> getAnnouncementsByPriority(
      String priority) async {
    if (_inMemoryCache != null && _isCacheValid(_lastFetchTime)) {
      final filtered =
          _inMemoryCache!.where((a) => a.priority == priority).toList();
      return Right(filtered);
    }
    try {
      final announcements =
          await remoteDataSource.getAnnouncementsByPriority(priority);
      return Right(announcements);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AnnouncementEntity>>> getAnnouncementsByCreator(
      String createdBy) async {
    if (_inMemoryCache != null && _isCacheValid(_lastFetchTime)) {
      final filtered =
          _inMemoryCache!.where((a) => a.createdBy == createdBy).toList();
      return Right(filtered);
    }
    try {
      final announcements =
          await remoteDataSource.getAnnouncementsByCreator(createdBy);
      return Right(announcements);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnnouncementEntity>> createAnnouncement({
    required String title,
    required String description,
    String? image,
    required String priority,
    required String createdBy,
  }) async {
    try {
      final announcement = await remoteDataSource.createAnnouncement(
        title: title,
        description: description,
        image: image,
        priority: priority,
        createdBy: createdBy,
      );
      await clearCache();
      return Right(announcement);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnnouncementEntity>> updateAnnouncement({
    required String id,
    required String title,
    required String description,
    String? image,
    required String priority,
  }) async {
    try {
      final announcement = await remoteDataSource.updateAnnouncement(
        id: id,
        title: title,
        description: description,
        image: image,
        priority: priority,
      );
      await clearCache();
      return Right(announcement);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAnnouncement(String id) async {
    try {
      await remoteDataSource.deleteAnnouncement(id);
      await clearCache();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
