import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/iam/domain/repositories/iam_repository.dart';
import 'package:fpdart/fpdart.dart';

class JoinCompanyUseCase {
  final IamRepository repository;

  JoinCompanyUseCase(this.repository);

  Future<Either<Failure, void>> call(String joinCode) {
    return repository.joinCompany(joinCode);
  }
}
