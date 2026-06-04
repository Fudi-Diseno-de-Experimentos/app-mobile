import '../../../../core/network/api_client.dart';
import '../models/company_model.dart';

abstract class CompanyRemoteDataSource {
  Future<CompanyModel> createCompany({
    required String ruc,
    required String nombre,
    String? iconUrl,
    required bool isActive,
    required String userId,
  });

  Future<CompanyModel> updateCompany({
    required String id,
    required String ruc,
    required String nombre,
    String? iconUrl,
    required bool isActive,
  });

  Future<CompanyModel> getCompanyByUserId(String userId);
  Future<CompanyModel> getCompanyById(String id);
}

class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  final ApiClient apiClient;

  CompanyRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<CompanyModel> createCompany({
    required String ruc,
    required String nombre,
    String? iconUrl,
    required bool isActive,
    required String userId,
  }) async {
    final response = await apiClient.post(
      '/companies',
      data: {
        'ruc': ruc,
        'nombre': nombre,
        'iconUrl': iconUrl,
        'isActive': isActive,
        'userId': userId,
      },
    );
    return CompanyModel.fromJson(response.data);
  }

  @override
  Future<CompanyModel> updateCompany({
    required String id,
    required String ruc,
    required String nombre,
    String? iconUrl,
    required bool isActive,
  }) async {
    final response = await apiClient.put(
      '/companies/$id',
      data: {
        'ruc': ruc,
        'nombre': nombre,
        'iconUrl': iconUrl,
        'isActive': isActive,
      },
    );
    return CompanyModel.fromJson(response.data);
  }

  @override
  Future<CompanyModel> getCompanyByUserId(String userId) async {
    final response = await apiClient.get('/companies/user/$userId');
    return CompanyModel.fromJson(response.data);
  }

  @override
  Future<CompanyModel> getCompanyById(String id) async {
    final response = await apiClient.get('/companies/$id');
    return CompanyModel.fromJson(response.data);
  }
}
