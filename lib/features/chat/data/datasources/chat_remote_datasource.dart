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

  /// `GET /api/v1/conversations` — my direct conversations (DMs).
  Future<List<ConversationModel>> getMyConversations();

  /// `POST /api/v1/conversations` — idempotent get-or-create against
  /// [targetUserId]. The initiator is derived from the JWT.
  Future<ConversationModel> startConversation(String targetUserId);

  /// `GET /api/v1/conversations/{id}/messages` — DM history.
  Future<List<MessageModel>> getConversationMessages(String conversationId);
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
}
