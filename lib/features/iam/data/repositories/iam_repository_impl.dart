import 'package:app_mobile/core/auth/token_store.dart';
import 'package:app_mobile/core/error/exceptions.dart';
import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:app_mobile/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:app_mobile/features/announcements/domain/repositories/comment_repository.dart';
import 'package:app_mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:app_mobile/features/events/domain/repositories/event_repository.dart';
import 'package:app_mobile/features/iam/data/datasources/iam_remote_datasource.dart';
import 'package:app_mobile/features/iam/domain/entities/user_entity.dart';
import 'package:app_mobile/features/iam/domain/repositories/iam_repository.dart';
import 'package:app_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';

class IamRepositoryImpl implements IamRepository {
  final IamRemoteDataSource remoteDataSource;
  final TokenStore tokenStore;

  IamRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStore,
  });

  Future<void> _clearAllCaches() async {
    final sl = GetIt.instance;
    try {
      if (sl.isRegistered<AnnouncementRepository>()) {
        await sl<AnnouncementRepository>().clearCache();
      }
    } catch (_) {}
    try {
      if (sl.isRegistered<EventRepository>()) {
        await sl<EventRepository>().clearCache();
      }
    } catch (_) {}
    try {
      if (sl.isRegistered<ProfileRepository>()) {
        await sl<ProfileRepository>().clearCache();
      }
    } catch (_) {}
    try {
      if (sl.isRegistered<ChatRepository>()) {
        await sl<ChatRepository>().clearCache();
      }
    } catch (_) {}
    try {
      if (sl.isRegistered<AnalyticsRepository>()) {
        await sl<AnalyticsRepository>().clearCache();
      }
    } catch (_) {}
    try {
      if (sl.isRegistered<CommentRepository>()) {
        await sl<CommentRepository>().clearCache();
      }
    } catch (_) {}
  }


  @override
  Future<Either<Failure, UserEntity>> signIn(
    String username,
    String password,
  ) async {
    try {
      final userModel = await remoteDataSource.signIn(username, password);
      // Save token locally
      await tokenStore.save(userModel.token, userId: userModel.id);
      
      // Clear all caches on login to avoid user leaks
      await _clearAllCaches();
      
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> signUp({
    required String username,
    required String password,
    required String name,
    required String lastname,
    required String email,
    List<String>? roles,
  }) async {
    try {
      await remoteDataSource.signUp(
        username: username,
        password: password,
        name: name,
        lastname: lastname,
        email: email,
        roles: roles,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> joinCompany(String joinCode) async {
    try {
      await remoteDataSource.joinCompany(joinCode);
      // Caches built while the user had no company are stale now.
      await _clearAllCaches();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await tokenStore.clear();
      // Clear all caches on logout to avoid user leaks
      await _clearAllCaches();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to sign out'));
    }
  }
}
