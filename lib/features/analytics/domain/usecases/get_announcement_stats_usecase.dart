import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/content_stats_entity.dart';
import '../repositories/analytics_repository.dart';

class GetAnnouncementStatsUseCase {
  final AnalyticsRepository repository;

  GetAnnouncementStatsUseCase(this.repository);

  Future<Either<Failure, ContentStatsEntity>> call(String id, {bool forceRefresh = false}) {
    return repository.getAnnouncementStats(id, forceRefresh: forceRefresh);
  }
}
