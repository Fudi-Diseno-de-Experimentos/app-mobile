import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_datasource.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource;

  final Map<String, List<CommentEntity>> _inMemoryCache = {};
  final Map<String, DateTime> _lastFetchTimes = {};
  static const Duration _cacheTtl = Duration(minutes: 5);

  CommentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CommentEntity>>> getComments(
    String announcementId,
  ) async {
    final cached = _inMemoryCache[announcementId];
    final lastFetch = _lastFetchTimes[announcementId];
    if (cached != null && lastFetch != null && DateTime.now().difference(lastFetch) < _cacheTtl) {
      return Right(cached);
    }

    try {
      final comments = await remoteDataSource.getComments(announcementId);
      final List<CommentEntity> entityList = List<CommentEntity>.from(comments);
      _inMemoryCache[announcementId] = entityList;
      _lastFetchTimes[announcementId] = DateTime.now();
      return Right(entityList);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> createComment({
    required String announcementId,
    required String content,
    required String authorId,
  }) async {
    try {
      final comment = await remoteDataSource.createComment(
        announcementId: announcementId,
        content: content,
        authorId: authorId,
      );
      // Invalidate cache for this announcement
      _inMemoryCache.remove(announcementId);
      _lastFetchTimes.remove(announcementId);
      return Right(comment);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      await remoteDataSource.deleteComment(commentId);
      // Invalidate the cache entry containing this commentId
      final keysToRemove = <String>[];
      for (final entry in _inMemoryCache.entries) {
        if (entry.value.any((c) => c.id == commentId)) {
          keysToRemove.add(entry.key);
        }
      }
      for (final key in keysToRemove) {
        _inMemoryCache.remove(key);
        _lastFetchTimes.remove(key);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> clearCache() async {
    _inMemoryCache.clear();
    _lastFetchTimes.clear();
  }
}
