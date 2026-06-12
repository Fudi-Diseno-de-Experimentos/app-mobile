import 'package:app_mobile/core/network/api_client.dart';
import 'package:app_mobile/features/company/data/models/space_model.dart';

abstract class SpaceRemoteDataSource {
  /// Lists the caller's company spaces. When [date] (`YYYY-MM-DD`) is given,
  /// each space's `available` flag is computed for that day.
  Future<List<SpaceModel>> getSpaces({String? date});
  Future<SpaceModel> createSpace({required String name, String? description});
  Future<SpaceModel> updateSpace({
    required String id,
    required String name,
    String? description,
  });
  Future<void> deleteSpace(String id);
}

class SpaceRemoteDataSourceImpl implements SpaceRemoteDataSource {
  final ApiClient apiClient;

  SpaceRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<SpaceModel>> getSpaces({String? date}) async {
    final response = await apiClient.get(
      '/spaces',
      queryParameters: date != null ? {'date': date} : null,
    );
    if (response.data is List) {
      return (response.data as List)
          .map((json) => SpaceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<SpaceModel> createSpace({
    required String name,
    String? description,
  }) async {
    final response = await apiClient.post(
      '/spaces',
      data: {'name': name, 'description': description},
    );
    return SpaceModel.fromJson(response.data);
  }

  @override
  Future<SpaceModel> updateSpace({
    required String id,
    required String name,
    String? description,
  }) async {
    final response = await apiClient.put(
      '/spaces/$id',
      data: {'name': name, 'description': description},
    );
    return SpaceModel.fromJson(response.data);
  }

  @override
  Future<void> deleteSpace(String id) async {
    await apiClient.delete('/spaces/$id');
  }
}
