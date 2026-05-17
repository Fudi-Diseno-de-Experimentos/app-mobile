import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversation_entity.dart';
import '../entities/group_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<GroupEntity>>> getMyGroups(String userId);

  Future<Either<Failure, List<MessageEntity>>> getGroupMessages(
    String groupId,
  );

  /// DM list (`GET /api/v1/conversations`).
  Future<Either<Failure, List<ConversationEntity>>> getMyConversations();

  /// Idempotent get-or-create DM (`POST /api/v1/conversations`).
  Future<Either<Failure, ConversationEntity>> startConversation(
    String targetUserId,
  );

  /// DM history (`GET /api/v1/conversations/{id}/messages`).
  Future<Either<Failure, List<MessageEntity>>> getConversationMessages(
    String conversationId,
  );

  Future<Either<Failure, GroupEntity>> createGroup({
    required String name,
    String? description,
    String? imageUrl,
    required String visibility,
    required List<String> memberIds,
    required String createdBy,
  });

  /// Updates group name/description/image (`PUT /api/v1/groups/{id}`).
  Future<Either<Failure, GroupEntity>> updateGroup({
    required String groupId,
    String? name,
    String? description,
    String? imageUrl,
  });

  /// Live message stream for [groupId] over the STOMP websocket.
  Stream<MessageEntity> watchMessages(String groupId);

  /// Persists a message over REST (reliable, returns the stored
  /// [MessageEntity]). Groups hit `/groups/{id}/messages`; DMs hit
  /// `/conversations/{id}/messages`. The live WS echo is a bonus, not the
  /// source of truth.
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String chatId,
    required bool isDirect,
    required String body,
  });

  /// Edits a message body (`PUT /groups/{id}/messages/{messageId}`).
  Future<Either<Failure, MessageEntity>> editMessage({
    required String chatId,
    required String messageId,
    required String body,
  });

  /// Soft-deletes a message (`DELETE /groups/{id}/messages/{messageId}`).
  Future<Either<Failure, Unit>> deleteMessage({
    required String chatId,
    required String messageId,
  });

  Future<void> disconnect();
}
