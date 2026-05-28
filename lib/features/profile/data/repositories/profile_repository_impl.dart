import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  ProfileEntity? _cachedProfile;
  DateTime? _profileLastFetchTime;

  List<ProfileEntity>? _cachedMembers;
  DateTime? _membersLastFetchTime;

  static const Duration _cacheTtl = Duration(minutes: 5);
  static const String _profileCacheKey = 'profile_cache';
  static const String _profileTimeKey = 'profile_cache_time';
  static const String _membersCacheKey = 'company_members_cache';
  static const String _membersTimeKey = 'company_members_cache_time';

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
  });

  bool _isCacheValid(DateTime? lastFetch) {
    if (lastFetch == null) return false;
    return DateTime.now().difference(lastFetch) < _cacheTtl;
  }

  Future<ProfileEntity?> _loadProfileFromCache() async {
    try {
      final jsonStr = sharedPreferences.getString(_profileCacheKey);
      final timeStr = sharedPreferences.getString(_profileTimeKey);
      if (jsonStr != null && timeStr != null) {
        final lastFetch = DateTime.tryParse(timeStr);
        if (_isCacheValid(lastFetch)) {
          final decoded = jsonDecode(jsonStr);
          final profile = ProfileModel.fromJson(decoded);
          _cachedProfile = profile;
          _profileLastFetchTime = lastFetch;
          return profile;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> _saveProfileToCache(ProfileModel profile) async {
    try {
      final now = DateTime.now();
      _cachedProfile = profile;
      _profileLastFetchTime = now;
      
      await sharedPreferences.setString(_profileCacheKey, jsonEncode(profile.toCacheJson()));
      await sharedPreferences.setString(_profileTimeKey, now.toIso8601String());
    } catch (_) {}
  }

  Future<List<ProfileEntity>?> _loadMembersFromCache() async {
    try {
      final jsonStr = sharedPreferences.getString(_membersCacheKey);
      final timeStr = sharedPreferences.getString(_membersTimeKey);
      if (jsonStr != null && timeStr != null) {
        final lastFetch = DateTime.tryParse(timeStr);
        if (_isCacheValid(lastFetch)) {
          final List<dynamic> decoded = jsonDecode(jsonStr);
          final list = decoded.map<ProfileEntity>((item) => ProfileModel.fromJson(item)).toList();
          _cachedMembers = list;
          _membersLastFetchTime = lastFetch;
          return list;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> _saveMembersToCache(List<ProfileEntity> list) async {
    try {
      final now = DateTime.now();
      _cachedMembers = list;
      _membersLastFetchTime = now;
      
      final jsonList = list.map((item) {
        if (item is ProfileModel) {
          return item.toCacheJson();
        } else {
          return ProfileModel(
            id: item.id,
            userId: item.userId,
            username: item.username,
            name: item.name,
            lastname: item.lastname,
            email: item.email,
            roles: item.roles,
            companyId: item.companyId,
            avatarUrl: item.avatarUrl,
          ).toCacheJson();
        }
      }).toList();
      await sharedPreferences.setString(_membersCacheKey, jsonEncode(jsonList));
      await sharedPreferences.setString(_membersTimeKey, now.toIso8601String());
    } catch (_) {}
  }

  @override
  Future<void> clearCache() async {
    _cachedProfile = null;
    _profileLastFetchTime = null;
    _cachedMembers = null;
    _membersLastFetchTime = null;
    await sharedPreferences.remove(_profileCacheKey);
    await sharedPreferences.remove(_profileTimeKey);
    await sharedPreferences.remove(_membersCacheKey);
    await sharedPreferences.remove(_membersTimeKey);
  }

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    if (_cachedProfile != null && _isCacheValid(_profileLastFetchTime)) {
      return Right(_cachedProfile!);
    }

    final cached = await _loadProfileFromCache();
    if (cached != null) {
      return Right(cached);
    }

    try {
      final profile = await remoteDataSource.getProfile();
      await _saveProfileToCache(profile);
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
      final profileModel = ProfileModel(
        id: profile.id,
        userId: profile.userId,
        username: profile.username,
        name: profile.name,
        lastname: profile.lastname,
        email: profile.email,
        roles: profile.roles,
        companyId: profile.companyId,
        avatarUrl: profile.avatarUrl,
      );
      final updatedProfile = await remoteDataSource.updateProfile(profileModel);
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
    if (_cachedMembers != null && _isCacheValid(_membersLastFetchTime)) {
      return Right(_cachedMembers!);
    }

    final cached = await _loadMembersFromCache();
    if (cached != null) {
      return Right(cached);
    }

    try {
      final members = await remoteDataSource.getCompanyMembers(companyId);
      final List<ProfileEntity> entityList = List<ProfileEntity>.from(members);
      await _saveMembersToCache(entityList);
      return Right(entityList);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
