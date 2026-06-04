import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class AssignCompanyToUserUseCase {
  final ProfileRepository repository;

  AssignCompanyToUserUseCase(this.repository);

  Future<Either<Failure, void>> call(String userId, String companyId) {
    return repository.assignCompanyToUser(userId, companyId);
  }
}
