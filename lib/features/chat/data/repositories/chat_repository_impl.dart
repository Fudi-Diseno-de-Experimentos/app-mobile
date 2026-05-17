import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../datasources/chat_socket_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatSocketDataSource socketDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.socketDataSource,
  });

  @override
  Future<Either<Failure, List<GroupEntity>>> getMyGroups(
    String userId,
  ) async {
    try {
      final groups = await remoteDataSource.getMyGroups(userId);
      return Right(groups);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getGroupMessages(
    String groupId,
  ) async {
    try {
      final messages = await remoteDataSource.getGroupMessages(groupId);
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> createGroup({
    required String name,
    String? description,
    String? imageUrl,
    required String visibility,
    required List<String> memberIds,
    required String createdBy,
  }) async {
    try {
      final group = await remoteDataSource.createGroup(
        name: name,
        description: description,
        imageUrl: imageUrl,
        visibility: visibility,
        memberIds: memberIds,
        createdBy: createdBy,
      );
      return Right(group);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ConversationEntity>>>
      getMyConversations() async {
    try {
      final conversations = await remoteDataSource.getMyConversations();
      return Right(conversations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> startConversation(
    String targetUserId,
  ) async {
    try {
      final conversation =
          await remoteDataSource.startConversation(targetUserId);
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getConversationMessages(
    String conversationId,
  ) async {
    try {
      final messages =
          await remoteDataSource.getConversationMessages(conversationId);
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> updateGroup({
    required String groupId,
    String? name,
    String? description,
    String? imageUrl,
  }) async {
    try {
      final group = await remoteDataSource.updateGroup(
        groupId,
        name: name,
        description: description,
        imageUrl: imageUrl,
      );
      return Right(group);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<MessageEntity> watchMessages(String groupId) {
    return socketDataSource.connect(groupId);
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String chatId,
    required bool isDirect,
    required String body,
  }) async {
    try {
      final message = isDirect
          ? await remoteDataSource.sendConversationMessage(chatId, body)
          : await remoteDataSource.sendGroupMessage(chatId, body);
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> editMessage({
    required String chatId,
    required String messageId,
    required String body,
  }) async {
    try {
      final message =
          await remoteDataSource.editMessage(chatId, messageId, body);
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    try {
      await remoteDataSource.deleteMessage(chatId, messageId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> disconnect() => socketDataSource.disconnect();
}
