import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/iam/domain/entities/user_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class IamRepository {
  Future<Either<Failure, UserEntity>> signIn(String username, String password);
  Future<Either<Failure, void>> signUp({
    required String username,
    required String password,
    required String name,
    required String lastname,
    required String email,
    List<String>? roles,
  });
  Future<Either<Failure, void>> joinCompany(String joinCode);
  Future<Either<Failure, void>> signOut();
}
