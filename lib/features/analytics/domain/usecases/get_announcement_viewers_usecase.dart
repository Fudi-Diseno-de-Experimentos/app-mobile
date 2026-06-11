import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/analytics/domain/entities/viewer_entity.dart';
import 'package:app_mobile/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAnnouncementViewersUseCase {
  final AnalyticsRepository repository;

  GetAnnouncementViewersUseCase(this.repository);

  Future<Either<Failure, List<ViewerEntity>>> call(String id, {bool forceRefresh = false}) {
    return repository.getAnnouncementViewers(id, forceRefresh: forceRefresh);
  }
}
