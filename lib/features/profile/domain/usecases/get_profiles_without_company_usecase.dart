import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfilesWithoutCompanyUseCase {
  final ProfileRepository repository;

  GetProfilesWithoutCompanyUseCase(this.repository);

  Future<Either<Failure, List<ProfileEntity>>> call({bool forceRefresh = false}) {
    return repository.getProfilesWithoutCompany(forceRefresh: forceRefresh);
  }
}
