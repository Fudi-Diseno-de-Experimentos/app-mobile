import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

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
