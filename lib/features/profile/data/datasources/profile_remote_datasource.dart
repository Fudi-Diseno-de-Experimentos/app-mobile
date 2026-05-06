import '../../../../core/network/api_client.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(ProfileModel profile);
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
}
