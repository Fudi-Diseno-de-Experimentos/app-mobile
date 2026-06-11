import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/iam/domain/repositories/iam_repository.dart';
import 'package:fpdart/fpdart.dart';

class SignOutUseCase {
  final IamRepository repository;

  SignOutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.signOut();
  }
}
