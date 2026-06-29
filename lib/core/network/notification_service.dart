import 'dart:io';
import 'dart:math';
import 'package:app_mobile/core/auth/token_store.dart';
import 'package:app_mobile/core/network/api_client.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final ApiClient _apiClient;
  final TokenStore _tokenStore;
  final SharedPreferences _sharedPreferences;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  NotificationService({
    required ApiClient apiClient,
    required TokenStore tokenStore,
    required SharedPreferences sharedPreferences,
  })  : _apiClient = apiClient,
        _tokenStore = tokenStore,
        _sharedPreferences = sharedPreferences;

  static const String _deviceIdKey = 'fcm_device_id';

  /// Generates a random device ID if one doesn't exist yet, and stores it in SharedPreferences.
  String _getOrCreateDeviceId() {
    String? deviceId = _sharedPreferences.getString(_deviceIdKey);
    if (deviceId == null) {
      final random = Random.secure();
      final values = List<int>.generate(16, (i) => random.nextInt(256));
      deviceId = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      _sharedPreferences.setString(_deviceIdKey, deviceId);
    }
    return deviceId;
  }

  /// Initialise notifications: request permission, fetch token, register on backend.
  Future<void> initialize() async {
    try {
      // Request permission
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('🔔 User granted notification permission');
        }
        
        // Get token
        String? token = await _fcm.getToken();
        if (token != null) {
          await _registerToken(token);
        }

        // Listen for token refreshes
        _fcm.onTokenRefresh.listen((newToken) {
          _registerToken(newToken);
        });

        // Setup message handlers
        _setupMessageHandlers();
      } else {
        if (kDebugMode) {
          print('🔔 User declined or has not accepted notification permission');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing NotificationService: $e');
      }
    }
  }

  /// Register the FCM token to the backend.
  Future<void> _registerToken(String token) async {
    final userId = _tokenStore.userId;
    if (userId == null) {
      if (kDebugMode) {
        print('🔔 Cannot register token: User is not authenticated');
      }
      return;
    }

    final deviceId = _getOrCreateDeviceId();
    final deviceType = Platform.isAndroid ? 'Android' : 'iOS';

    try {
      if (kDebugMode) {
        print('📡 Registering FCM token to backend for user: $userId');
      }
      
      await _apiClient.post(
        '/api/v1/users/$userId/fcm-token',
        data: {
          'fcmToken': token,
          'deviceType': deviceType,
          'deviceId': deviceId,
        },
      );
      
      if (kDebugMode) {
        print('✅ FCM token registered successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to register FCM token to backend: $e');
      }
    }
  }

  /// Unregister the token from the backend (e.g. on logout)
  Future<void> unregisterToken(String token) async {
    final userId = _tokenStore.userId;
    if (userId == null) return;
    try {
      await _apiClient.delete(
        '/api/v1/users/$userId/fcm-token',
        queryParameters: {'fcmToken': token},
      );
      if (kDebugMode) {
        print('✅ FCM token unregistered successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to unregister FCM token: $e');
      }
    }
  }

  /// Setup foreground and background message handlers.
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('🔔 Received a foreground message: ${message.notification?.title}');
      }
    });

    // Background/Terminated click messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('🔔 Notification clicked, app opened: ${message.data}');
      }
    });
  }
}
