import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_announcement_view_entity.dart';
import '../repositories/analytics_repository.dart';

class GetUserAnnouncementViewsUseCase {
  final AnalyticsRepository repository;

  GetUserAnnouncementViewsUseCase(this.repository);

  Future<Either<Failure, List<UserAnnouncementViewEntity>>> call(String userId, {bool forceRefresh = false}) {
    return repository.getUserAnnouncementViews(userId, forceRefresh: forceRefresh);
  }
}
