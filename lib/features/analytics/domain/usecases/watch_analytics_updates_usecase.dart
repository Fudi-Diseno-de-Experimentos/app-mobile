import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/analytics/domain/entities/analytics_update_entity.dart';
import 'package:app_mobile/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:fpdart/fpdart.dart';

class WatchAnalyticsUpdatesUseCase {
  final AnalyticsRepository repository;

  WatchAnalyticsUpdatesUseCase(this.repository);

  Stream<Either<Failure, AnalyticsUpdateEntity>> call({
    required String contentId,
    required bool isEvent,
  }) {
    return repository.watchAnalyticsUpdates(contentId, isEvent);
  }
}
