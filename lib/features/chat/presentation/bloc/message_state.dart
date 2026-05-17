import 'package:equatable/equatable.dart';
import '../../domain/entities/message_entity.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object?> get props => [];
}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessageError extends MessageState {
  final String message;

  const MessageError(this.message);

  @override
  List<Object?> get props => [message];
}

class ConversationLoaded extends MessageState {
  final List<MessageEntity> messages;

  /// senderId → "Name Lastname" for group chats. Empty for DMs.
  final Map<String, String> senderNames;

  const ConversationLoaded(
    this.messages, {
    this.senderNames = const {},
  });

  @override
  List<Object?> get props => [messages, senderNames];
}

/// A send/edit/delete failed. Transient — the thread stays rendered; the page
/// surfaces this as a snackbar, not a full-screen error.
class MessageActionFailed extends MessageState {
  final String message;
  final List<MessageEntity> messages;
  final Map<String, String> senderNames;

  const MessageActionFailed(
    this.message,
    this.messages, {
    this.senderNames = const {},
  });

  @override
  List<Object?> get props => [message, messages, senderNames];
}
