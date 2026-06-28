import 'package:app_mobile/core/network/api_client.dart';
import 'package:app_mobile/features/notifications/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> fetchNotifications(String userId);
  Future<void> markAsRead(String id);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    final response = await apiClient.get('/notifications/$userId');
    if (response.data != null && response.data is List) {
      return (response.data as List)
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }

  @override
  Future<void> markAsRead(String id) async {
    await apiClient.put(
      '/notifications/$id/status',
      data: {'status': 'READ'},
    );
  }
}
