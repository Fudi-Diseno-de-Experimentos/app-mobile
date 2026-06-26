import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/analytics/domain/entities/content_stats_entity.dart';
import 'package:app_mobile/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetEventStatsUseCase {
  final AnalyticsRepository repository;

  GetEventStatsUseCase(this.repository);

  Future<Either<Failure, ContentStatsEntity>> call(String id, {bool forceRefresh = false}) {
    return repository.getEventStats(id, forceRefresh: forceRefresh);
  }
}
