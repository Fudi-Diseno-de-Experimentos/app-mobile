import '../../../../core/network/api_client.dart';
import '../models/conversation_model.dart';
import '../models/group_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<GroupModel>> getMyGroups(String userId);
  Future<List<MessageModel>> getGroupMessages(String groupId);
  Future<GroupModel> createGroup({
    required String name,
    String? description,
    String? imageUrl,
    required String visibility,
    required List<String> memberIds,
    required String createdBy,
  });

  /// `PUT /api/v1/groups/{id}` — update group name/description/image
  /// (`UpdateGroupResource`).
  Future<GroupModel> updateGroup(
    String groupId, {
    String? name,
    String? description,
    String? imageUrl,
  });

  /// `GET /api/v1/conversations` — my direct conversations (DMs).
  Future<List<ConversationModel>> getMyConversations();

  /// `POST /api/v1/conversations` — idempotent get-or-create against
  /// [targetUserId]. The initiator is derived from the JWT.
  Future<ConversationModel> startConversation(String targetUserId);

  /// `GET /api/v1/conversations/{id}/messages` — DM history.
  Future<List<MessageModel>> getConversationMessages(String conversationId);

  /// `POST /api/v1/groups/{id}/messages` — persist a group message.
  /// `senderId` is ignored server-side (derived from the JWT).
  Future<MessageModel> sendGroupMessage(String groupId, String body);

  /// `POST /api/v1/conversations/{id}/messages` — persist a DM message.
  Future<MessageModel> sendConversationMessage(
    String conversationId,
    String body,
  );

  /// `PUT /api/v1/groups/{id}/messages/{messageId}` — edit body.
  /// DM ids are DIRECT-group ids, so this serves both.
  Future<MessageModel> editMessage(
    String groupId,
    String messageId,
    String body,
  );

  /// `DELETE /api/v1/groups/{id}/messages/{messageId}` — soft delete.
  Future<void> deleteMessage(String groupId, String messageId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient apiClient;

  ChatRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<GroupModel>> getMyGroups(String userId) async {
    final response = await apiClient.get(
      '/groups',
      queryParameters: {'userId': userId},
    );
    if (response.data is List) {
      return (response.data as List)
          .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<List<MessageModel>> getGroupMessages(String groupId) async {
    final response = await apiClient.get('/groups/$groupId/messages');
    if (response.data is List) {
      return (response.data as List)
          .map((json) => MessageModel.fromJson(
                json as Map<String, dynamic>,
                fallbackGroupId: groupId,
              ))
          .toList();
    }
    return [];
  }

  @override
  Future<GroupModel> createGroup({
    required String name,
    String? description,
    String? imageUrl,
    required String visibility,
    required List<String> memberIds,
    required String createdBy,
  }) async {
    final response = await apiClient.post(
      '/groups',
      data: {
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'visibility': visibility,
        'memberIds': memberIds,
        'createdBy': createdBy,
      },
    );
    return GroupModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  @override
  Future<GroupModel> updateGroup(
    String groupId, {
    String? name,
    String? description,
    String? imageUrl,
  }) async {
    final response = await apiClient.put(
      '/groups/$groupId',
      data: {
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
      },
    );
    return GroupModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  @override
  Future<List<ConversationModel>> getMyConversations() async {
    final response = await apiClient.get('/conversations');
    if (response.data is List) {
      return (response.data as List)
          .map((json) =>
              ConversationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<ConversationModel> startConversation(String targetUserId) async {
    final response = await apiClient.post(
      '/conversations',
      data: {'targetUserId': targetUserId},
    );
    return ConversationModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  @override
  Future<List<MessageModel>> getConversationMessages(
    String conversationId,
  ) async {
    final response =
        await apiClient.get('/conversations/$conversationId/messages');
    if (response.data is List) {
      return (response.data as List)
          .map((json) => MessageModel.fromJson(
                json as Map<String, dynamic>,
                fallbackGroupId: conversationId,
              ))
          .toList();
    }
    return [];
  }

  @override
  Future<MessageModel> sendGroupMessage(String groupId, String body) async {
    final response = await apiClient.post(
      '/groups/$groupId/messages',
      data: {'body': body},
    );
    return MessageModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
      fallbackGroupId: groupId,
    );
  }

  @override
  Future<MessageModel> sendConversationMessage(
    String conversationId,
    String body,
  ) async {
    final response = await apiClient.post(
      '/conversations/$conversationId/messages',
      data: {'body': body},
    );
    return MessageModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
      fallbackGroupId: conversationId,
    );
  }

  @override
  Future<MessageModel> editMessage(
    String groupId,
    String messageId,
    String body,
  ) async {
    final response = await apiClient.put(
      '/groups/$groupId/messages/$messageId',
      data: {'body': body},
    );
    return MessageModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
      fallbackGroupId: groupId,
    );
  }

  @override
  Future<void> deleteMessage(String groupId, String messageId) async {
    await apiClient.delete('/groups/$groupId/messages/$messageId');
  }
}
