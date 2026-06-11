import 'package:app_mobile/core/network/api_client.dart';
import 'package:app_mobile/features/profile/data/models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(ProfileModel profile);
  Future<List<ProfileModel>> getCompanyMembers(String companyId);
  Future<List<ProfileModel>> getProfilesWithoutCompany();
  Future<void> assignCompanyToUser(String userId, String companyId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ProfileModel> getProfile() async {
    final response = await apiClient.get('/profiles/me');
    final profileData = Map<String, dynamic>.from(response.data);
    final userId = profileData['userId'];

    if (userId != null) {
      try {
        final userResponse = await apiClient.get('/users/$userId');
        if (userResponse.data != null && userResponse.data is Map) {
          final userData = userResponse.data as Map<String, dynamic>;
          profileData['roles'] = userData['roles'];
          // ProfileResource has no `username`; UserResource does. Merge it
          // so ProfileEntity.username is populated.
          profileData['username'] = userData['username'];
        }
      } catch (e) {
        // Fallback if user details endpoint fails
      }
    }

    return ProfileModel.fromJson(profileData);
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    final response = await apiClient.put(
      '/profiles/${profile.id}',
      data: profile.toJson(),
    );
    return ProfileModel.fromJson(response.data);
  }

  @override
  Future<List<ProfileModel>> getCompanyMembers(String companyId) async {
    final response = await apiClient.get('/profiles/company/$companyId');
    if (response.data != null && response.data is List) {
      return (response.data as List)
          .map((json) => ProfileModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<List<ProfileModel>> getProfilesWithoutCompany() async {
    final response = await apiClient.get('/profiles/no-company');
    if (response.data != null && response.data is List) {
      return (response.data as List)
          .map((json) => ProfileModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<void> assignCompanyToUser(String userId, String companyId) async {
    await apiClient.put(
      '/users/$userId/company',
      data: {'companyId': companyId},
    );
  }
}
