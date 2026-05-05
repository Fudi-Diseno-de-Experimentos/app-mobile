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
    return ProfileModel.fromJson(response.data);
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
