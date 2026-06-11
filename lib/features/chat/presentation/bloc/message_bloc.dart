import 'dart:async';

import 'package:app_mobile/features/chat/domain/entities/message_entity.dart';
import 'package:app_mobile/features/chat/domain/usecases/delete_message_usecase.dart';
import 'package:app_mobile/features/chat/domain/usecases/disconnect_chat_usecase.dart';
import 'package:app_mobile/features/chat/domain/usecases/edit_message_usecase.dart';
import 'package:app_mobile/features/chat/domain/usecases/get_conversation_messages_usecase.dart';
import 'package:app_mobile/features/chat/domain/usecases/get_group_messages_usecase.dart';
import 'package:app_mobile/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:app_mobile/features/chat/domain/usecases/watch_messages_usecase.dart';
import 'package:app_mobile/features/chat/presentation/bloc/message_event.dart';
import 'package:app_mobile/features/chat/presentation/bloc/message_state.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_company_members_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final GetGroupMessagesUseCase getGroupMessagesUseCase;
  final GetConversationMessagesUseCase getConversationMessagesUseCase;
  final WatchMessagesUseCase watchMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final EditMessageUseCase editMessageUseCase;
  final DeleteMessageUseCase deleteMessageUseCase;
  final GetCompanyMembersUseCase getCompanyMembersUseCase;
  final DisconnectChatUseCase disconnectChatUseCase;

  final List<MessageEntity> _messages = [];
  StreamSubscription<MessageEntity>? _sub;

  // Captured on load so edit/delete know which chat to target.
  String _chatId = '';

  // senderId → "Name Lastname" for group bubbles. Empty for DMs.
  Map<String, String> _senderNames = const {};

  MessageBloc({
    required this.getGroupMessagesUseCase,
    required this.getConversationMessagesUseCase,
    required this.watchMessagesUseCase,
    required this.sendMessageUseCase,
    required this.editMessageUseCase,
    required this.deleteMessageUseCase,
    required this.getCompanyMembersUseCase,
    required this.disconnectChatUseCase,
  }) : super(MessageInitial()) {
    on<LoadConversation>(_onLoadConversation);
    on<MessageReceived>(_onMessageReceived);
    on<SendChatMessage>(_onSendChatMessage);
    on<EditMessage>(_onEditMessage);
    on<DeleteMessage>(_onDeleteMessage);
  }

  DateTime _parse(String iso) =>
      DateTime.tryParse(iso) ?? DateTime.fromMillisecondsSinceEpoch(0);

  /// Chronological order. Deleted messages stay as tombstones (Teams-style),
  /// the bubble renders the "message was deleted" placeholder.
  List<MessageEntity> _ordered() {
    final list = [..._messages]
      ..sort((a, b) => _parse(a.sentAt).compareTo(_parse(b.sentAt)));
    return list;
  }

  void _merge(MessageEntity incoming) {
    // A real (non-pending) echo replaces the optimistic local copy.
    if (!incoming.isPending) {
      _messages.removeWhere((m) =>
          m.isPending &&
          m.senderId == incoming.senderId &&
          m.body == incoming.body);
    }
    final idx =
        _messages.indexWhere((m) => m.messageId == incoming.messageId);
    if (idx >= 0) {
      _messages[idx] = incoming;
    } else {
      _messages.add(incoming);
    }
  }

  Future<void> _onLoadConversation(
    LoadConversation event,
    Emitter<MessageState> emit,
  ) async {
    _chatId = event.groupId;
    emit(MessageLoading());

    // Group chats show the sender name per bubble — resolve it from the
    // company directory. DMs don't need it (the title is the peer's name).
    if (!event.isDirect && event.companyId.isNotEmpty) {
      final members = await getCompanyMembersUseCase(event.companyId);
      members.fold(
        (_) {},
        (list) {
          _senderNames = {
            for (final m in list)
              m.userId: '${m.name} ${m.lastname}'.trim(),
          };
        },
      );
    }

    final result = event.isDirect
        ? await getConversationMessagesUseCase(event.groupId)
        : await getGroupMessagesUseCase(event.groupId);
    result.fold(
      (failure) => emit(MessageError(failure.message)),
      (history) {
        _messages
          ..clear()
          ..addAll(history);
        emit(ConversationLoaded(_ordered(), senderNames: _senderNames));
        _sub?.cancel();
        _sub = watchMessagesUseCase(event.groupId).listen(
          (message) => add(MessageReceived(message)),
          onError: (_) {},
        );
      },
    );
  }

  void _onMessageReceived(
    MessageReceived event,
    Emitter<MessageState> emit,
  ) {
    _merge(event.message);
    emit(ConversationLoaded(_ordered(), senderNames: _senderNames));
  }

  Future<void> _onSendChatMessage(
    SendChatMessage event,
    Emitter<MessageState> emit,
  ) async {
    final now = DateTime.now();
    final localId = 'local-${now.microsecondsSinceEpoch}';
    final optimistic = MessageEntity(
      messageId: localId,
      groupId: event.groupId,
      senderId: event.senderId,
      body: event.body,
      status: 'SENT',
      sentAt: now.toIso8601String(),
      isEdited: false,
      isVisible: true,
    );
    _merge(optimistic);
    emit(ConversationLoaded(_ordered(), senderNames: _senderNames));

    final result = await sendMessageUseCase(
      chatId: event.groupId,
      isDirect: event.isDirect,
      body: event.body,
    );
    result.fold(
      (failure) {
        // Drop the optimistic bubble; keep the thread intact.
        _messages.removeWhere((m) => m.messageId == localId);
        emit(MessageActionFailed(
          'Message not sent: ${failure.message}',
          _ordered(),
          senderNames: _senderNames,
        ));
        emit(ConversationLoaded(_ordered(), senderNames: _senderNames));
      },
      (saved) {
        _merge(saved);
        emit(ConversationLoaded(_ordered(), senderNames: _senderNames));
      },
    );
  }

  Future<void> _onEditMessage(
    EditMessage event,
    Emitter<MessageState> emit,
  ) async {
    if (_chatId.isEmpty) return;
    final result = await editMessageUseCase(
      chatId: _chatId,
      messageId: event.messageId,
      body: event.body,
    );
    result.fold(
      (failure) {
        emit(MessageActionFailed(
          'Edit failed: ${failure.message}',
          _ordered(),
          senderNames: _senderNames,
        ));
        emit(ConversationLoaded(_ordered(), senderNames: _senderNames));
      },
      (updated) {
        _merge(updated);
        emit(ConversationLoaded(_ordered(), senderNames: _senderNames));
      },
    );
  }

  Future<void> _onDeleteMessage(
    DeleteMessage event,
    Emitter<MessageState> emit,
  ) async {
    if (_chatId.isEmpty) return;
    final result = await deleteMessageUseCase(
      chatId: _chatId,
      messageId: event.messageId,
    );
    result.fold(
      (failure) {
        emit(MessageActionFailed(
          'Delete failed: ${failure.message}',
          _ordered(),
          senderNames: _senderNames,
        ));
        emit(ConversationLoaded(_ordered(), senderNames: _senderNames));
      },
      (_) {
        final idx = _messages
            .indexWhere((m) => m.messageId == event.messageId);
        if (idx >= 0) {
          final m = _messages[idx];
          _messages[idx] = MessageEntity(
            messageId: m.messageId,
            groupId: m.groupId,
            senderId: m.senderId,
            body: '',
            status: 'DELETED',
            sentAt: m.sentAt,
            editedAt: m.editedAt,
            isEdited: m.isEdited,
            isVisible: false,
          );
        }
        emit(ConversationLoaded(_ordered(), senderNames: _senderNames));
      },
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await disconnectChatUseCase();
    return super.close();
  }
}
