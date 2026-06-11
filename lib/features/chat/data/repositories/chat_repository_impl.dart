import 'package:app_mobile/core/cache/ttl_cache.dart';
import 'package:app_mobile/core/error/exceptions.dart';
import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:app_mobile/features/chat/data/datasources/chat_socket_datasource.dart';
import 'package:app_mobile/features/chat/data/models/conversation_model.dart';
import 'package:app_mobile/features/chat/data/models/group_model.dart';
import 'package:app_mobile/features/chat/domain/entities/conversation_entity.dart';
import 'package:app_mobile/features/chat/domain/entities/group_entity.dart';
import 'package:app_mobile/features/chat/domain/entities/message_entity.dart';
import 'package:app_mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatSocketDataSource socketDataSource;

  // Chat moves faster than announcements/events, hence the shorter 1-minute
  // TTL (vs 5 minutes elsewhere).
  static const Duration _cacheTtl = Duration(minutes: 1);

  final TtlCache<List<GroupEntity>> _groupsCache;
  final TtlCache<List<ConversationEntity>> _conversationsCache;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.socketDataSource,
    required SharedPreferences sharedPreferences,
  })  : _groupsCache = TtlCache(
          prefs: sharedPreferences,
          key: 'chat_groups_cache',
          ttl: _cacheTtl,
          fromJson: (json) => (json as List)
              .map<GroupEntity>((item) => GroupModel.fromJson(item))
              .toList(),
          toJson: (list) => list
              .map((item) => item is GroupModel
                  ? item.toJson()
                  : GroupModel(
                      id: item.id,
                      name: item.name,
                      description: item.description,
                      imageUrl: item.imageUrl,
                      visibility: item.visibility,
                      type: item.type,
                      memberIds: item.memberIds,
                      memberCount: item.memberCount,
                      createdBy: item.createdBy,
                      createdAt: item.createdAt,
                      updatedAt: item.updatedAt,
                    ).toJson())
              .toList(),
        ),
        _conversationsCache = TtlCache(
          prefs: sharedPreferences,
          key: 'chat_conversations_cache',
          ttl: _cacheTtl,
          fromJson: (json) => (json as List)
              .map<ConversationEntity>(
                  (item) => ConversationModel.fromJson(item))
              .toList(),
          toJson: (list) => list
              .map((item) => item is ConversationModel
                  ? item.toJson()
                  : ConversationModel(
                      id: item.id,
                      otherUserId: item.otherUserId,
                      memberIds: item.memberIds,
                      createdAt: item.createdAt,
                      updatedAt: item.updatedAt,
                    ).toJson())
              .toList(),
        );

  @override
  Future<void> clearCache() async {
    await _groupsCache.clear();
    await _conversationsCache.clear();
  }

  @override
  Future<Either<Failure, List<GroupEntity>>> getMyGroups(
    String userId,
  ) async {
    final cached = _groupsCache.get();
    if (cached != null) {
      return Right(cached);
    }

    try {
      final groups = await remoteDataSource.getMyGroups(userId);
      await _groupsCache.set(groups);
      return Right(groups);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
      await clearCache();
      return Right(group);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ConversationEntity>>>
      getMyConversations() async {
    final cached = _conversationsCache.get();
    if (cached != null) {
      return Right(cached);
    }

    try {
      final conversations = await remoteDataSource.getMyConversations();
      await _conversationsCache.set(conversations);
      return Right(conversations);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
      await clearCache();
      return Right(conversation);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
      await clearCache();
      return Right(group);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> disconnect() => socketDataSource.disconnect();
}
