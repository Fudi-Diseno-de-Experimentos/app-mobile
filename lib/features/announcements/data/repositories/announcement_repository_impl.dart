import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../datasources/announcement_remote_datasource.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final AnnouncementRemoteDataSource remoteDataSource;

  AnnouncementRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AnnouncementEntity>>> getAnnouncements() async {
    try {
      final remoteAnnouncements = await remoteDataSource.getAnnouncements();
      return Right(remoteAnnouncements);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnnouncementEntity>> createAnnouncement({
    required String title,
    required String description,
    String? image,
    required String priority,
    required String createdBy,
  }) async {
    try {
      final announcement = await remoteDataSource.createAnnouncement(
        title: title,
        description: description,
        image: image,
        priority: priority,
        createdBy: createdBy,
      );
      return Right(announcement);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
