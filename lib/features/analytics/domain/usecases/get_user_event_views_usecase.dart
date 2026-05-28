import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_event_view_entity.dart';
import '../repositories/analytics_repository.dart';

class GetUserEventViewsUseCase {
  final AnalyticsRepository repository;

  GetUserEventViewsUseCase(this.repository);

  Future<Either<Failure, List<UserEventViewEntity>>> call(String userId, {bool forceRefresh = false}) {
    return repository.getUserEventViews(userId, forceRefresh: forceRefresh);
  }
}
