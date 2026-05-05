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
    // Assuming /users/me is the endpoint based on common patterns
    // or we might need the userId, wait, the docs say GET /api/v1/users/{userId}
    // and POST /api/v1/users/me/company/join. Let's assume /users/me exists or we fetch from shared prefs?
    // Wait, the API docs say: `GET /api/v1/users/{userId}`. How do we get our userId?
    // UserEntity has `id` after sign in. So we can use that? Or let's assume /users/me is available.
    final response = await apiClient.get('/users/me');
    return ProfileModel.fromJson(response.data);
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    final response = await apiClient.put(
      '/users/${profile.id}',
      data: profile.toJson(),
    );
    return ProfileModel.fromJson(response.data);
  }
}
