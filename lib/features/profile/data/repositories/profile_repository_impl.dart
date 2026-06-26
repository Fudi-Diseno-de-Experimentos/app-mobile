import 'package:app_mobile/core/cache/ttl_cache.dart';
import 'package:app_mobile/core/error/exceptions.dart';
import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:app_mobile/features/profile/data/models/profile_model.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:app_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  static const Duration _cacheTtl = Duration(minutes: 5);

  final TtlCache<ProfileEntity> _profileCache;

  /// Members are stored together with their companyId; a hit for another
  /// company is stale (e.g. the user switched companies within the TTL).
  final TtlCache<({String companyId, List<ProfileEntity> members})>
      _membersCache;

  final TtlCache<List<ProfileEntity>> _noCompanyCache;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required SharedPreferences sharedPreferences,
  })  : _profileCache = TtlCache(
          prefs: sharedPreferences,
          key: 'profile_cache',
          ttl: _cacheTtl,
          fromJson: (json) => ProfileModel.fromJson(json),
          toJson: (profile) => _toModel(profile).toCacheJson(),
        ),
        _membersCache = TtlCache(
          prefs: sharedPreferences,
          key: 'company_members_cache',
          ttl: _cacheTtl,
          fromJson: (json) => (
            companyId: json['companyId'] as String,
            members: (json['members'] as List)
                .map<ProfileEntity>((item) => ProfileModel.fromJson(item))
                .toList(),
          ),
          toJson: (value) => {
            'companyId': value.companyId,
            'members':
                value.members.map((item) => _toModel(item).toCacheJson()).toList(),
          },
        ),
        _noCompanyCache = TtlCache(
          prefs: sharedPreferences,
          key: 'no_company_cache',
          ttl: _cacheTtl,
          fromJson: (json) => (json as List)
              .map<ProfileEntity>((item) => ProfileModel.fromJson(item))
              .toList(),
          toJson: (list) =>
              list.map((item) => _toModel(item).toCacheJson()).toList(),
        );

  static ProfileModel _toModel(ProfileEntity item) {
    return item is ProfileModel
        ? item
        : ProfileModel(
            id: item.id,
            userId: item.userId,
            username: item.username,
            name: item.name,
            lastname: item.lastname,
            email: item.email,
            roles: item.roles,
            companyId: item.companyId,
            avatarUrl: item.avatarUrl,
          );
  }

  @override
  Future<void> clearCache() async {
    await _profileCache.clear();
    await _membersCache.clear();
    await _noCompanyCache.clear();
  }

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    final cached = _profileCache.get();
    if (cached != null) {
      return Right(cached);
    }

    try {
      final profile = await remoteDataSource.getProfile();
      await _profileCache.set(profile);
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile(
    ProfileEntity profile,
  ) async {
    try {
      final updatedProfile =
          await remoteDataSource.updateProfile(_toModel(profile));
      await clearCache();
      return Right(updatedProfile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<ProfileEntity>>> getCompanyMembers(
    String companyId,
  ) async {
    final cached = _membersCache.get();
    if (cached != null && cached.companyId == companyId) {
      return Right(cached.members);
    }

    try {
      final members = await remoteDataSource.getCompanyMembers(companyId);
      final List<ProfileEntity> entityList = List<ProfileEntity>.from(members);
      await _membersCache.set((companyId: companyId, members: entityList));
      return Right(entityList);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<ProfileEntity>>> getProfilesWithoutCompany(
      {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _noCompanyCache.get();
      if (cached != null) {
        return Right(cached);
      }
    }

    try {
      final profiles = await remoteDataSource.getProfilesWithoutCompany();
      final List<ProfileEntity> entityList = List<ProfileEntity>.from(profiles);
      await _noCompanyCache.set(entityList);
      return Right(entityList);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> assignCompanyToUser(
      String userId, String companyId) async {
    try {
      await remoteDataSource.assignCompanyToUser(userId, companyId);
      // Remove the assigned user from the cached no-company list, if any.
      final cached = _noCompanyCache.get();
      if (cached != null) {
        await _noCompanyCache.set(
          cached.where((profile) => profile.userId != userId).toList(),
        );
      }
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
