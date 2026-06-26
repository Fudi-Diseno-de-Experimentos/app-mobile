import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:app_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetCompanyMembersUseCase {
  final ProfileRepository repository;

  GetCompanyMembersUseCase(this.repository);

  Future<Either<Failure, List<ProfileEntity>>> call(String companyId) {
    return repository.getCompanyMembers(companyId);
  }
}
