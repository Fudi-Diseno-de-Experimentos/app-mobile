import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_remote_datasource.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource remoteDataSource;

  CompanyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CompanyEntity>> createCompany({
    required String ruc,
    required String nombre,
    String? iconUrl,
    required bool isActive,
    required String userId,
  }) async {
    try {
      final model = await remoteDataSource.createCompany(
        ruc: ruc,
        nombre: nombre,
        iconUrl: iconUrl,
        isActive: isActive,
        userId: userId,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, CompanyEntity>> updateCompany({
    required String id,
    required String ruc,
    required String nombre,
    String? iconUrl,
    required bool isActive,
  }) async {
    try {
      final model = await remoteDataSource.updateCompany(
        id: id,
        ruc: ruc,
        nombre: nombre,
        iconUrl: iconUrl,
        isActive: isActive,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, CompanyEntity>> getCompanyByUserId(String userId) async {
    try {
      final model = await remoteDataSource.getCompanyByUserId(userId);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, CompanyEntity>> getCompanyById(String id) async {
    try {
      final model = await remoteDataSource.getCompanyById(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
