import '../../../../core/network/api_client.dart';
import '../models/announcement_model.dart';

abstract class AnnouncementRemoteDataSource {
  Future<List<AnnouncementModel>> getAnnouncements();
  Future<AnnouncementModel> createAnnouncement({
    required String title,
    required String description,
    String? image,
    required String priority,
    required String createdBy,
  });
}

class AnnouncementRemoteDataSourceImpl implements AnnouncementRemoteDataSource {
  final ApiClient apiClient;

  AnnouncementRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<AnnouncementModel>> getAnnouncements() async {
    final response = await apiClient.get('/announcements');
    
    if (response.data != null && response.data is List) {
      return (response.data as List)
          .map((json) => AnnouncementModel.fromJson(json))
          .toList();
    }
    return [];
  }

  @override
  Future<AnnouncementModel> createAnnouncement({
    required String title,
    required String description,
    String? image,
    required String priority,
    required String createdBy,
  }) async {
    final response = await apiClient.post(
      '/announcements',
      data: {
        'title': title,
        'description': description,
        'image': image,
        'priority': priority,
        'createdBy': createdBy,
      },
    );
    return AnnouncementModel.fromJson(response.data);
  }
}
