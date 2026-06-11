import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/iam/domain/repositories/iam_repository.dart';
import 'package:fpdart/fpdart.dart';

class SignUpUseCase {
  final IamRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String username,
    required String password,
    required String name,
    required String lastname,
    required String email,
    List<String>? roles,
  }) {
    return repository.signUp(
      username: username,
      password: password,
      name: name,
      lastname: lastname,
      email: email,
      roles: roles,
    );
  }
}
