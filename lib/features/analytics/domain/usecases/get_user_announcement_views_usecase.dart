import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/analytics/domain/entities/user_announcement_view_entity.dart';
import 'package:app_mobile/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetUserAnnouncementViewsUseCase {
  final AnalyticsRepository repository;

  GetUserAnnouncementViewsUseCase(this.repository);

  Future<Either<Failure, List<UserAnnouncementViewEntity>>> call(String userId, {bool forceRefresh = false}) {
    return repository.getUserAnnouncementViews(userId, forceRefresh: forceRefresh);
  }
}
