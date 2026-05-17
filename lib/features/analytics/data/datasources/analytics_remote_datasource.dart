import '../../../../core/network/api_client.dart';
import '../models/view_registration_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<ViewRegistrationModel> registerAnnouncementView({
    required String announcementId,
    required String userId,
  });
  Future<ViewRegistrationModel> registerEventView({
    required String eventId,
    required String userId,
  });
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final ApiClient apiClient;

  AnalyticsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ViewRegistrationModel> registerAnnouncementView({
    required String announcementId,
    required String userId,
  }) async {
    final response = await apiClient.post(
      '/analytics/announcements/$announcementId/views',
      // RegisterViewResource = { userId }
      data: {'userId': userId},
    );
    return ViewRegistrationModel.fromJson(response.data);
  }

  @override
  Future<ViewRegistrationModel> registerEventView({
    required String eventId,
    required String userId,
  }) async {
    final response = await apiClient.post(
      '/analytics/events/$eventId/views',
      data: {'userId': userId},
    );
    return ViewRegistrationModel.fromJson(response.data);
  }
}
