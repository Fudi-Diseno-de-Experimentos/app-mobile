import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../models/message_model.dart';

/// Live chat transport over the backend STOMP endpoint.
///
/// - Endpoint: `{URL_SERVICE}/ws-chat` (SockJS).
/// - Subscribe: `/topic/group.{groupId}` -> incoming [MessageModel].
/// - Publish:   `/app/chat.send/{groupId}` with `{senderId, body}`.
/// - Auth:      JWT passed in the STOMP `CONNECT` frame.
abstract class ChatSocketDataSource {
  Stream<MessageModel> connect(String groupId);
  void sendMessage({
    required String groupId,
    required String senderId,
    required String body,
  });
  Future<void> disconnect();
}

class ChatSocketDataSourceImpl implements ChatSocketDataSource {
  final SharedPreferences sharedPreferences;

  ChatSocketDataSourceImpl(this.sharedPreferences);

  StompClient? _client;
  StreamController<MessageModel>? _controller;
  bool _connected = false;

  String get _socketUrl {
    final base = dotenv.env['URL_SERVICE'] ?? '';
    return '$base/ws-chat';
  }

  @override
  Stream<MessageModel> connect(String groupId) {
    // Tear down any previous conversation before opening a new one.
    _client?.deactivate();
    _controller?.close();

    _connected = false;
    final controller = StreamController<MessageModel>.broadcast();
    _controller = controller;

    final token = sharedPreferences.getString('auth_token');
    final authHeaders = <String, String>{
      if (token != null) 'Authorization': 'Bearer $token',
    };

    late final StompClient client;
    client = StompClient(
      config: StompConfig.sockJS(
        url: _socketUrl,
        reconnectDelay: const Duration(seconds: 5),
        stompConnectHeaders: authHeaders,
        webSocketConnectHeaders: authHeaders,
        onConnect: (StompFrame frame) {
          _connected = true;
          client.subscribe(
            destination: '/topic/group.$groupId',
            callback: (StompFrame message) {
              final raw = message.body;
              if (raw == null || raw.isEmpty) return;
              try {
                final decoded = jsonDecode(raw);
                if (decoded is Map<String, dynamic>) {
                  controller.add(
                    MessageModel.fromJson(decoded, fallbackGroupId: groupId),
                  );
                }
              } catch (_) {
                // Ignore malformed frames; REST history remains the source of truth.
              }
            },
          );
        },
        onWebSocketError: (dynamic error) {
          if (!controller.isClosed) controller.addError(error);
        },
        onStompError: (StompFrame frame) {
          if (!controller.isClosed) {
            controller.addError(frame.body ?? 'STOMP error');
          }
        },
        onDisconnect: (_) => _connected = false,
      ),
    );

    _client = client;
    client.activate();
    return controller.stream;
  }

  @override
  void sendMessage({
    required String groupId,
    required String senderId,
    required String body,
  }) {
    final client = _client;
    if (client == null || !_connected) return;
    client.send(
      destination: '/app/chat.send/$groupId',
      body: jsonEncode({'senderId': senderId, 'body': body}),
    );
  }

  @override
  Future<void> disconnect() async {
    _client?.deactivate();
    await _controller?.close();
    _client = null;
    _controller = null;
    _connected = false;
  }
}
