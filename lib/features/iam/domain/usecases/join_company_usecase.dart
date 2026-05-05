import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/iam_repository.dart';

class JoinCompanyUseCase {
  final IamRepository repository;

  JoinCompanyUseCase(this.repository);

  Future<Either<Failure, void>> call(String joinCode) {
    return repository.joinCompany(joinCode);
  }
}
