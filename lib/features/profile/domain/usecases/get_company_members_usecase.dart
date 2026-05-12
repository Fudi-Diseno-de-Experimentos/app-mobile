import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetCompanyMembersUseCase {
  final ProfileRepository repository;

  GetCompanyMembersUseCase(this.repository);

  Future<Either<Failure, List<ProfileEntity>>> call(String companyId) {
    return repository.getCompanyMembers(companyId);
  }
}
