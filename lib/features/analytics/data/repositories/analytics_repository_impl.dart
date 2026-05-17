import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/view_registration_entity.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_datasource.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ViewRegistrationEntity>> registerAnnouncementView({
    required String announcementId,
    required String userId,
  }) async {
    try {
      final result = await remoteDataSource.registerAnnouncementView(
        announcementId: announcementId,
        userId: userId,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ViewRegistrationEntity>> registerEventView({
    required String eventId,
    required String userId,
  }) async {
    try {
      final result = await remoteDataSource.registerEventView(
        eventId: eventId,
        userId: userId,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
