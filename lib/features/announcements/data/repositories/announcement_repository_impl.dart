import 'package:app_mobile/core/cache/ttl_cache.dart';
import 'package:app_mobile/core/error/exceptions.dart';
import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/announcements/data/datasources/announcement_remote_datasource.dart';
import 'package:app_mobile/features/announcements/data/models/announcement_model.dart';
import 'package:app_mobile/features/announcements/domain/entities/announcement_entity.dart';
import 'package:app_mobile/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final AnnouncementRemoteDataSource remoteDataSource;

  final TtlCache<List<AnnouncementEntity>> _cache;

  AnnouncementRepositoryImpl({
    required this.remoteDataSource,
    required SharedPreferences sharedPreferences,
  }) : _cache = TtlCache(
          prefs: sharedPreferences,
          key: 'announcements_cache',
          ttl: const Duration(minutes: 5),
          fromJson: (json) => (json as List)
              .map<AnnouncementEntity>(
                  (item) => AnnouncementModel.fromJson(item))
              .toList(),
          // The cached list always comes from the remote datasource, whose
          // elements are AnnouncementModel instances.
          toJson: (list) => list
              .map((item) => (item as AnnouncementModel).toJson())
              .toList(),
        );

  @override
  Future<void> clearCache() => _cache.clear();

  @override
  Future<Either<Failure, List<AnnouncementEntity>>> getAnnouncements(
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
      final remoteAnnouncements = await remoteDataSource.getAnnouncements();
      await _cache.set(remoteAnnouncements);
      return Right(remoteAnnouncements);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnnouncementEntity>> getAnnouncementById(
      String id) async {
    final cached = _cache.get();
    if (cached != null) {
      try {
        final announcement = cached.firstWhere((a) => a.id == id);
        return Right(announcement);
      } catch (_) {}
    }
    try {
      final announcement = await remoteDataSource.getAnnouncementById(id);
      return Right(announcement);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AnnouncementEntity>>> getAnnouncementsByPriority(
      String priority) async {
    final cached = _cache.get();
    if (cached != null) {
      return Right(cached.where((a) => a.priority == priority).toList());
    }
    try {
      final announcements =
          await remoteDataSource.getAnnouncementsByPriority(priority);
      return Right(announcements);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AnnouncementEntity>>> getAnnouncementsByCreator(
      String createdBy) async {
    final cached = _cache.get();
    if (cached != null) {
      return Right(cached.where((a) => a.createdBy == createdBy).toList());
    }
    try {
      final announcements =
          await remoteDataSource.getAnnouncementsByCreator(createdBy);
      return Right(announcements);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAnnouncement(String id) async {
    try {
      await remoteDataSource.deleteAnnouncement(id);
      await clearCache();
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
