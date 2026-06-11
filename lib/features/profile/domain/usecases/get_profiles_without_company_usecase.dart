import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:app_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetProfilesWithoutCompanyUseCase {
  final ProfileRepository repository;

  GetProfilesWithoutCompanyUseCase(this.repository);

  Future<Either<Failure, List<ProfileEntity>>> call({bool forceRefresh = false}) {
    return repository.getProfilesWithoutCompany(forceRefresh: forceRefresh);
  }
}
