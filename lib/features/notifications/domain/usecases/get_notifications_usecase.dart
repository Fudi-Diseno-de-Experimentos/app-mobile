import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:app_mobile/features/notifications/domain/repositories/notification_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, List<NotificationEntity>>> call(String userId) {
    return repository.getNotifications(userId);
  }
}
