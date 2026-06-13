import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_mobile/core/auth/token_store.dart';
import 'package:app_mobile/core/network/api_client.dart';
import 'package:app_mobile/features/analytics/data/models/analytics_update_model.dart';
import 'package:app_mobile/features/analytics/data/models/content_stats_model.dart';
import 'package:app_mobile/features/analytics/data/models/user_announcement_view_model.dart';
import 'package:app_mobile/features/analytics/data/models/user_event_view_model.dart';
import 'package:app_mobile/features/analytics/data/models/view_registration_model.dart';
import 'package:app_mobile/features/analytics/data/models/viewer_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  Stream<AnalyticsUpdateModel> watchAnalyticsUpdates(String contentId, bool isEvent);
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final ApiClient apiClient;
  final TokenStore tokenStore;

  AnalyticsRemoteDataSourceImpl(this.apiClient, this.tokenStore);

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

  @override
  Stream<AnalyticsUpdateModel> watchAnalyticsUpdates(String contentId, bool isEvent) {
    final controller = StreamController<AnalyticsUpdateModel>();
    bool isCancelled = false;
    HttpClient? client;

    Future<void> connect() async {
      while (!isCancelled) {
        try {
          client = HttpClient();
          // We set connection timeouts
          client!.connectionTimeout = const Duration(seconds: 15);

          final type = isEvent ? 'EVENT' : 'ANNOUNCEMENT';
          final url = '${dotenv.env['URL_SERVICE']}/api/v1/analytics/stream/$type/$contentId';
          
          final request = await client!.getUrl(Uri.parse(url));
          
          // Add JWT authorization header
          final token = tokenStore.token;
          if (token != null) {
            request.headers.set('Authorization', 'Bearer $token');
          }
          
          final response = await request.close();
          if (response.statusCode != 200) {
            throw HttpException('Failed to connect: ${response.statusCode}');
          }
          
          String? currentEvent;
          String currentData = '';
          
          final lineStream = response
              .transform(utf8.decoder)
              .transform(const LineSplitter());
              
          await for (final line in lineStream) {
            if (isCancelled) break;
            
            if (line.isEmpty) {
              if (currentData.isNotEmpty) {
                if (currentEvent == 'analytics-update') {
                  final Map<String, dynamic> json = jsonDecode(currentData);
                  controller.add(AnalyticsUpdateModel.fromJson(json));
                }
                currentEvent = null;
                currentData = '';
              }
            } else if (line.startsWith('event:')) {
              currentEvent = line.substring(6).trim();
            } else if (line.startsWith('data:')) {
              currentData += line.substring(5).trim();
            }
          }
        } catch (e) {
          if (isCancelled) break;
          // Log error and wait 5 seconds before retrying
          print("SSE Analytics connection failed: $e. Retrying in 5 seconds...");
        } finally {
          client?.close();
          client = null;
        }
        
        if (!isCancelled) {
          await Future.delayed(const Duration(seconds: 5));
        }
      }
    }

    controller.onListen = () {
      connect();
    };

    controller.onCancel = () {
      isCancelled = true;
      client?.close();
    };

    return controller.stream;
  }
}

