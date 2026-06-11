import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class AssignCompanyToUserUseCase {
  final ProfileRepository repository;

  AssignCompanyToUserUseCase(this.repository);

  Future<Either<Failure, void>> call(String userId, String companyId) {
    return repository.assignCompanyToUser(userId, companyId);
  }
}
