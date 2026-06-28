import 'package:app_mobile/core/error/exceptions.dart';
import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:app_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:app_mobile/features/notifications/domain/repositories/notification_repository.dart';
import 'package:fpdart/fpdart.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications(
    String userId,
  ) async {
    try {
      final notifications = await remoteDataSource.fetchNotifications(userId);
      return Right(notifications);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String id) async {
    try {
      await remoteDataSource.markAsRead(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
