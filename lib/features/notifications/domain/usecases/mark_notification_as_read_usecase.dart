import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/notifications/domain/repositories/notification_repository.dart';
import 'package:fpdart/fpdart.dart';

class MarkNotificationAsReadUseCase {
  final NotificationRepository repository;

  MarkNotificationAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.markAsRead(id);
  }
}
