import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications(String userId);
  Future<Either<Failure, void>> markAsRead(String id);
}
