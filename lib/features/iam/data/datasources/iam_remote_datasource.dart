import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class IamRemoteDataSource {
  Future<UserModel> signIn(String username, String password);
  Future<void> signUp({
    required String username,
    required String password,
    required String name,
    required String lastname,
    required String email,
    List<String>? roles,
  });
  Future<void> joinCompany(String joinCode);
}

class IamRemoteDataSourceImpl implements IamRemoteDataSource {
  final ApiClient apiClient;

  IamRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> signIn(String username, String password) async {
    final response = await apiClient.post(
      '/auth/sign-in',
      data: {'username': username, 'password': password},
    );
    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> signUp({
    required String username,
    required String password,
    required String name,
    required String lastname,
    required String email,
    List<String>? roles,
  }) async {
    await apiClient.post(
      '/auth/sign-up',
      data: {
        'username': username,
        'password': password,
        'name': name,
        'lastname': lastname,
        'email': email,
        'roles': roles ?? ['ROLE_USER'],
      },
    );
  }

  @override
  Future<void> joinCompany(String joinCode) async {
    await apiClient.post(
      '/users/me/company/join',
      data: {'joinCode': joinCode},
    );
  }
}
