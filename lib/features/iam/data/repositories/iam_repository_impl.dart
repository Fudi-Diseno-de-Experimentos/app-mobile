import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/iam_repository.dart';
import '../datasources/iam_remote_datasource.dart';

class IamRepositoryImpl implements IamRepository {
  final IamRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  IamRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, UserEntity>> signIn(
    String username,
    String password,
  ) async {
    try {
      final userModel = await remoteDataSource.signIn(username, password);
      // Save token locally
      await sharedPreferences.setString('auth_token', userModel.token);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> signUp({
    required String username,
    required String password,
    required String name,
    required String lastname,
    required String email,
  }) async {
    try {
      await remoteDataSource.signUp(
        username: username,
        password: password,
        name: name,
        lastname: lastname,
        email: email,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> joinCompany(String joinCode) async {
    try {
      await remoteDataSource.joinCompany(joinCode);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await sharedPreferences.remove('auth_token');
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to sign out'));
    }
  }
}
