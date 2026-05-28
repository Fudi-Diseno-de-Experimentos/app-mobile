import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../datasources/chat_socket_datasource.dart';
import '../models/group_model.dart';
import '../models/conversation_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatSocketDataSource socketDataSource;
  final SharedPreferences sharedPreferences;

  List<GroupEntity>? _cachedGroups;
  DateTime? _groupsLastFetchTime;

  List<ConversationEntity>? _cachedConversations;
  DateTime? _conversationsLastFetchTime;

  static const Duration _cacheTtl = Duration(minutes: 1);
  static const String _groupsCacheKey = 'chat_groups_cache';
  static const String _groupsTimeKey = 'chat_groups_cache_time';
  static const String _conversationsCacheKey = 'chat_conversations_cache';
  static const String _conversationsTimeKey = 'chat_conversations_cache_time';

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.socketDataSource,
    required this.sharedPreferences,
  });

  bool _isCacheValid(DateTime? lastFetch) {
    if (lastFetch == null) return false;
    return DateTime.now().difference(lastFetch) < _cacheTtl;
  }

  Future<List<GroupEntity>?> _loadGroupsFromCache() async {
    try {
      final jsonStr = sharedPreferences.getString(_groupsCacheKey);
      final timeStr = sharedPreferences.getString(_groupsTimeKey);
      if (jsonStr != null && timeStr != null) {
        final lastFetch = DateTime.tryParse(timeStr);
        if (_isCacheValid(lastFetch)) {
          final List<dynamic> decoded = jsonDecode(jsonStr);
          final list = decoded.map((item) => GroupModel.fromJson(item)).toList();
          _cachedGroups = list;
          _groupsLastFetchTime = lastFetch;
          return list;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> _saveGroupsToCache(List<GroupEntity> list) async {
    try {
      final now = DateTime.now();
      _cachedGroups = list;
      _groupsLastFetchTime = now;
      
      final jsonList = list.map((item) {
        if (item is GroupModel) {
          return item.toJson();
        } else {
          return GroupModel(
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
          ).toJson();
        }
      }).toList();
      await sharedPreferences.setString(_groupsCacheKey, jsonEncode(jsonList));
      await sharedPreferences.setString(_groupsTimeKey, now.toIso8601String());
    } catch (_) {}
  }

  Future<List<ConversationEntity>?> _loadConversationsFromCache() async {
    try {
      final jsonStr = sharedPreferences.getString(_conversationsCacheKey);
      final timeStr = sharedPreferences.getString(_conversationsTimeKey);
      if (jsonStr != null && timeStr != null) {
        final lastFetch = DateTime.tryParse(timeStr);
        if (_isCacheValid(lastFetch)) {
          final List<dynamic> decoded = jsonDecode(jsonStr);
          final list = decoded.map((item) => ConversationModel.fromJson(item)).toList();
          _cachedConversations = list;
          _conversationsLastFetchTime = lastFetch;
          return list;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> _saveConversationsToCache(List<ConversationEntity> list) async {
    try {
      final now = DateTime.now();
      _cachedConversations = list;
      _conversationsLastFetchTime = now;
      
      final jsonList = list.map((item) {
        if (item is ConversationModel) {
          return item.toJson();
        } else {
          return ConversationModel(
            id: item.id,
            otherUserId: item.otherUserId,
            memberIds: item.memberIds,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt,
          ).toJson();
        }
      }).toList();
      await sharedPreferences.setString(_conversationsCacheKey, jsonEncode(jsonList));
      await sharedPreferences.setString(_conversationsTimeKey, now.toIso8601String());
    } catch (_) {}
  }

  @override
  Future<void> clearCache() async {
    _cachedGroups = null;
    _groupsLastFetchTime = null;
    _cachedConversations = null;
    _conversationsLastFetchTime = null;
    await sharedPreferences.remove(_groupsCacheKey);
    await sharedPreferences.remove(_groupsTimeKey);
    await sharedPreferences.remove(_conversationsCacheKey);
    await sharedPreferences.remove(_conversationsTimeKey);
  }

  @override
  Future<Either<Failure, List<GroupEntity>>> getMyGroups(
    String userId,
  ) async {
    if (_cachedGroups != null && _isCacheValid(_groupsLastFetchTime)) {
      return Right(_cachedGroups!);
    }

    final cached = await _loadGroupsFromCache();
    if (cached != null) {
      return Right(cached);
    }

    try {
      final groups = await remoteDataSource.getMyGroups(userId);
      await _saveGroupsToCache(groups);
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
      await clearCache();
      return Right(group);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ConversationEntity>>>
      getMyConversations() async {
    if (_cachedConversations != null && _isCacheValid(_conversationsLastFetchTime)) {
      return Right(_cachedConversations!);
    }

    final cached = await _loadConversationsFromCache();
    if (cached != null) {
      return Right(cached);
    }

    try {
      final conversations = await remoteDataSource.getMyConversations();
      await _saveConversationsToCache(conversations);
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
      await clearCache();
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
      await clearCache();
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
