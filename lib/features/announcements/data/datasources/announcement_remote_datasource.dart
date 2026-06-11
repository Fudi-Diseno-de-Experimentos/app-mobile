import 'package:app_mobile/core/network/api_client.dart';
import 'package:app_mobile/features/announcements/data/models/announcement_model.dart';

abstract class AnnouncementRemoteDataSource {
  Future<List<AnnouncementModel>> getAnnouncements();
  Future<AnnouncementModel> getAnnouncementById(String id);
  Future<List<AnnouncementModel>> getAnnouncementsByPriority(String priority);
  Future<List<AnnouncementModel>> getAnnouncementsByCreator(String createdBy);
  Future<AnnouncementModel> createAnnouncement({
    required String title,
    required String description,
    String? image,
    required String priority,
    required String createdBy,
  });
  Future<AnnouncementModel> updateAnnouncement({
    required String id,
    required String title,
    required String description,
    String? image,
    required String priority,
  });
  Future<void> deleteAnnouncement(String id);
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
  Future<AnnouncementModel> getAnnouncementById(String id) async {
    final response = await apiClient.get('/announcements/$id');
    return AnnouncementModel.fromJson(response.data);
  }

  @override
  Future<List<AnnouncementModel>> getAnnouncementsByPriority(
      String priority) async {
    final response = await apiClient.get('/announcements/priority/$priority');
    if (response.data != null && response.data is List) {
      return (response.data as List)
          .map((json) => AnnouncementModel.fromJson(json))
          .toList();
    }
    return [];
  }

  @override
  Future<List<AnnouncementModel>> getAnnouncementsByCreator(
      String createdBy) async {
    final response = await apiClient.get('/announcements/creator/$createdBy');
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

  @override
  Future<AnnouncementModel> updateAnnouncement({
    required String id,
    required String title,
    required String description,
    String? image,
    required String priority,
  }) async {
    final response = await apiClient.put(
      '/announcements/$id',
      data: {
        'title': title,
        'description': description,
        'image': image,
        'priority': priority,
      },
    );
    return AnnouncementModel.fromJson(response.data);
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    await apiClient.delete('/announcements/$id');
  }
}
