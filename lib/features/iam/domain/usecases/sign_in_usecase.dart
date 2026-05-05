import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/iam_repository.dart';

class SignInUseCase {
  final IamRepository repository;

  SignInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String username, String password) {
    return repository.signIn(username, password);
  }
}
