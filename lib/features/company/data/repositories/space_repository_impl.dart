import 'package:app_mobile/core/error/exceptions.dart';
import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/company/data/datasources/space_remote_datasource.dart';
import 'package:app_mobile/features/company/domain/entities/space_entity.dart';
import 'package:app_mobile/features/company/domain/repositories/space_repository.dart';
import 'package:fpdart/fpdart.dart';

class SpaceRepositoryImpl implements SpaceRepository {
  final SpaceRemoteDataSource remoteDataSource;

  SpaceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SpaceEntity>>> getSpaces({String? date}) async {
    try {
      final spaces = await remoteDataSource.getSpaces(date: date);
      return Right(spaces);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, SpaceEntity>> createSpace({
    required String name,
    String? description,
  }) async {
    try {
      final space = await remoteDataSource.createSpace(
        name: name,
        description: description,
      );
      return Right(space);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, SpaceEntity>> updateSpace({
    required String id,
    required String name,
    String? description,
  }) async {
    try {
      final space = await remoteDataSource.updateSpace(
        id: id,
        name: name,
        description: description,
      );
      return Right(space);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSpace(String id) async {
    try {
      await remoteDataSource.deleteSpace(id);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
