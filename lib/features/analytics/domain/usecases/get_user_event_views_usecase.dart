import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/analytics/domain/entities/user_event_view_entity.dart';
import 'package:app_mobile/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetUserEventViewsUseCase {
  final AnalyticsRepository repository;

  GetUserEventViewsUseCase(this.repository);

  Future<Either<Failure, List<UserEventViewEntity>>> call(String userId, {bool forceRefresh = false}) {
    return repository.getUserEventViews(userId, forceRefresh: forceRefresh);
  }
}
