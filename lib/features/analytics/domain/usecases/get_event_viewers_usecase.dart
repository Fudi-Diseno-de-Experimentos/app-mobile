import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/viewer_entity.dart';
import '../repositories/analytics_repository.dart';

class GetEventViewersUseCase {
  final AnalyticsRepository repository;

  GetEventViewersUseCase(this.repository);

  Future<Either<Failure, List<ViewerEntity>>> call(String id, {bool forceRefresh = false}) {
    return repository.getEventViewers(id, forceRefresh: forceRefresh);
  }
}
