import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/disconnect_chat_usecase.dart';
import '../../domain/usecases/get_conversation_messages_usecase.dart';
import '../../domain/usecases/get_group_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/watch_messages_usecase.dart';
import 'message_event.dart';
import 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final GetGroupMessagesUseCase getGroupMessagesUseCase;
  final GetConversationMessagesUseCase getConversationMessagesUseCase;
  final WatchMessagesUseCase watchMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final DisconnectChatUseCase disconnectChatUseCase;

  final List<MessageEntity> _messages = [];
  StreamSubscription<MessageEntity>? _sub;

  MessageBloc({
    required this.getGroupMessagesUseCase,
    required this.getConversationMessagesUseCase,
    required this.watchMessagesUseCase,
    required this.sendMessageUseCase,
    required this.disconnectChatUseCase,
  }) : super(MessageInitial()) {
    on<LoadConversation>(_onLoadConversation);
    on<MessageReceived>(_onMessageReceived);
    on<SendChatMessage>(_onSendChatMessage);
  }

  DateTime _parse(String iso) =>
      DateTime.tryParse(iso) ?? DateTime.fromMillisecondsSinceEpoch(0);

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
    emit(MessageLoading());
    final result = event.isDirect
        ? await getConversationMessagesUseCase(event.groupId)
        : await getGroupMessagesUseCase(event.groupId);
    result.fold(
      (failure) => emit(MessageError(failure.message)),
      (history) {
        _messages
          ..clear()
          ..addAll(history);
        emit(ConversationLoaded(_ordered()));
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
    emit(ConversationLoaded(_ordered()));
  }

  void _onSendChatMessage(
    SendChatMessage event,
    Emitter<MessageState> emit,
  ) {
    final now = DateTime.now();
    final optimistic = MessageEntity(
      messageId: 'local-${now.microsecondsSinceEpoch}',
      groupId: event.groupId,
      senderId: event.senderId,
      body: event.body,
      status: 'SENT',
      sentAt: now.toIso8601String(),
      isEdited: false,
      isVisible: true,
    );
    _merge(optimistic);
    emit(ConversationLoaded(_ordered()));
    sendMessageUseCase(
      groupId: event.groupId,
      senderId: event.senderId,
      body: event.body,
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await disconnectChatUseCase();
    return super.close();
  }
}
