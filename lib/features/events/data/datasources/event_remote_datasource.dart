import 'package:app_mobile/core/network/api_client.dart';
import 'package:app_mobile/features/events/data/models/event_model.dart';

abstract class EventRemoteDataSource {
  Future<List<EventModel>> getEvents();
  Future<EventModel> createEvent({
    required String title,
    required String description,
    required String date,
    required String location,
    required String createdBy,
    required List<String> recipientIds,
  });
  Future<EventModel> updateEvent({
    required String id,
    required String title,
    required String description,
    required String date,
    required String location,
    required List<String> recipientIds,
  });
  Future<void> deleteEvent(String id);
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

  @override
  Future<EventModel> createEvent({
    required String title,
    required String description,
    required String date,
    required String location,
    required String createdBy,
    required List<String> recipientIds,
  }) async {
    final response = await apiClient.post(
      '/events',
      data: {
        'title': title,
        'description': description,
        'date': date,
        'location': location,
        'createdBy': createdBy,
        'recipientIds': recipientIds,
      },
    );
    return EventModel.fromJson(response.data);
  }

  @override
  Future<EventModel> updateEvent({
    required String id,
    required String title,
    required String description,
    required String date,
    required String location,
    required List<String> recipientIds,
  }) async {
    final response = await apiClient.put(
      '/events/$id',
      data: {
        'title': title,
        'description': description,
        'date': date,
        'location': location,
        'recipientIds': recipientIds,
      },
    );
    return EventModel.fromJson(response.data);
  }

  @override
  Future<void> deleteEvent(String id) async {
    await apiClient.delete('/events/$id');
  }
}
