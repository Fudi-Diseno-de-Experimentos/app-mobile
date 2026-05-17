import 'package:equatable/equatable.dart';
import '../../domain/entities/message_entity.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

class LoadConversation extends MessageEvent {
  final String groupId;

  /// DM history comes from `/conversations/{id}/messages`; group history from
  /// `/groups/{id}/messages`. The live WS topic is identical for both.
  final bool isDirect;

  const LoadConversation(this.groupId, {this.isDirect = false});

  @override
  List<Object?> get props => [groupId, isDirect];
}

class SendChatMessage extends MessageEvent {
  final String groupId;
  final String senderId;
  final String body;

  const SendChatMessage({
    required this.groupId,
    required this.senderId,
    required this.body,
  });

  @override
  List<Object?> get props => [groupId, senderId, body];
}

/// Internal: a message arrived on the websocket topic.
class MessageReceived extends MessageEvent {
  final MessageEntity message;

  const MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}
