import '../../../../core/network/api_client.dart';
import '../models/event_model.dart';

abstract class EventRemoteDataSource {
  Future<List<EventModel>> getEvents();
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final ApiClient apiClient;

  EventRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<EventModel>> getEvents() async {
    final response = await apiClient.get('/events');
    if (response.data != null && response.data is List) {
      return (response.data as List).map((json) => EventModel.fromJson(json)).toList();
    }
    return [];
  }
}
