import 'package:app_mobile/features/chat/domain/entities/message_entity.dart';
import 'package:equatable/equatable.dart';

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

  /// Used to resolve sender display names from company member profiles so
  /// group bubbles can show who sent each message (WhatsApp style). Empty
  /// for DMs (the peer name is already the conversation title).
  final String companyId;

  const LoadConversation(
    this.groupId, {
    this.isDirect = false,
    this.companyId = '',
  });

  @override
  List<Object?> get props => [groupId, isDirect, companyId];
}

class SendChatMessage extends MessageEvent {
  final String groupId;
  final String senderId;
  final String body;
  final bool isDirect;

  const SendChatMessage({
    required this.groupId,
    required this.senderId,
    required this.body,
    required this.isDirect,
  });

  @override
  List<Object?> get props => [groupId, senderId, body, isDirect];
}

/// Edit an existing message authored by the current user.
class EditMessage extends MessageEvent {
  final String messageId;
  final String body;

  const EditMessage({required this.messageId, required this.body});

  @override
  List<Object?> get props => [messageId, body];
}

/// Soft-delete a message authored by the current user.
class DeleteMessage extends MessageEvent {
  final String messageId;

  const DeleteMessage(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

/// Internal: a message arrived on the websocket topic.
class MessageReceived extends MessageEvent {
  final MessageEntity message;

  const MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}
