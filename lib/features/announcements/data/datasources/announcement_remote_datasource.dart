import '../../../../core/network/api_client.dart';
import '../models/announcement_model.dart';

abstract class AnnouncementRemoteDataSource {
  Future<List<AnnouncementModel>> getAnnouncements();
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
}
