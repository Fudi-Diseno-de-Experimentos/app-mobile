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

  /// Live message stream for [groupId] over the STOMP websocket.
  Stream<MessageEntity> watchMessages(String groupId);

  void sendMessage({
    required String groupId,
    required String senderId,
    required String body,
  });

  Future<void> disconnect();
}
