import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/iam/domain/entities/user_entity.dart';
import 'package:app_mobile/features/iam/domain/repositories/iam_repository.dart';
import 'package:fpdart/fpdart.dart';

class SignInUseCase {
  final IamRepository repository;

  SignInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String username, String password) {
    return repository.signIn(username, password);
  }
}
