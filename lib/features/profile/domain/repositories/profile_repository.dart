import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
  Future<Either<Failure, ProfileEntity>> updateProfile(ProfileEntity profile);
  Future<Either<Failure, List<ProfileEntity>>> getCompanyMembers(String companyId);
  Future<Either<Failure, List<ProfileEntity>>> getProfilesWithoutCompany({bool forceRefresh = false});
  Future<Either<Failure, void>> assignCompanyToUser(String userId, String companyId);
  Future<void> clearCache();
}
