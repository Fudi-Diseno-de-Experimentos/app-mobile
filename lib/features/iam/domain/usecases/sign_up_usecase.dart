import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/iam_repository.dart';

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
