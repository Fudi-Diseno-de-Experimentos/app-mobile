import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
  Future<Either<Failure, ProfileEntity>> updateProfile(ProfileEntity profile);
  Future<Either<Failure, List<ProfileEntity>>> getCompanyMembers(String companyId);
  Future<Either<Failure, List<ProfileEntity>>> getProfilesWithoutCompany({bool forceRefresh = false});
  Future<Either<Failure, void>> assignCompanyToUser(String userId, String companyId);
  Future<void> clearCache();
}
