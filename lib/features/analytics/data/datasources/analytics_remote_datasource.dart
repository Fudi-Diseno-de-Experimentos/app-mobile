import '../../../../core/network/api_client.dart';
import '../models/view_registration_model.dart';
import '../models/content_stats_model.dart';
import '../models/viewer_model.dart';
import '../models/user_announcement_view_model.dart';
import '../models/user_event_view_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<ViewRegistrationModel> registerAnnouncementView({
    required String announcementId,
    required String userId,
  });
  Future<ViewRegistrationModel> registerEventView({
    required String eventId,
    required String userId,
  });
  Future<ContentStatsModel> getAnnouncementStats(String announcementId);
  Future<ContentStatsModel> getEventStats(String eventId);
  Future<List<ViewerModel>> getAnnouncementViewers(String announcementId);
  Future<List<ViewerModel>> getEventViewers(String eventId);
  Future<List<UserAnnouncementViewModel>> getUserAnnouncementViews(String userId);
  Future<List<UserEventViewModel>> getUserEventViews(String userId);
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

  @override
  Future<ContentStatsModel> getAnnouncementStats(String announcementId) async {
    final response = await apiClient.get(
      '/dashboard/announcements/$announcementId/stats',
    );
    return ContentStatsModel.fromJson(response.data);
  }

  @override
  Future<ContentStatsModel> getEventStats(String eventId) async {
    final response = await apiClient.get(
      '/dashboard/events/$eventId/stats',
    );
    return ContentStatsModel.fromJson(response.data);
  }

  @override
  Future<List<ViewerModel>> getAnnouncementViewers(String announcementId) async {
    final response = await apiClient.get(
      '/dashboard/announcements/$announcementId/users/views',
    );
    final List list = response.data ?? [];
    return list.map((json) => ViewerModel.fromJson(json)).toList();
  }

  @override
  Future<List<ViewerModel>> getEventViewers(String eventId) async {
    final response = await apiClient.get(
      '/dashboard/events/$eventId/users/views',
    );
    final List list = response.data ?? [];
    return list.map((json) => ViewerModel.fromJson(json)).toList();
  }

  @override
  Future<List<UserAnnouncementViewModel>> getUserAnnouncementViews(String userId) async {
    final response = await apiClient.get(
      '/dashboard/users/$userId/announcements/views',
    );
    final List list = response.data ?? [];
    return list.map((json) => UserAnnouncementViewModel.fromJson(json)).toList();
  }

  @override
  Future<List<UserEventViewModel>> getUserEventViews(String userId) async {
    final response = await apiClient.get(
      '/dashboard/users/$userId/events/views',
    );
    final List list = response.data ?? [];
    return list.map((json) => UserEventViewModel.fromJson(json)).toList();
  }
}

