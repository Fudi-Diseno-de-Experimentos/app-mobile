import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/iam_repository.dart';

class SignOutUseCase {
  final IamRepository repository;

  SignOutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.signOut();
  }
}
