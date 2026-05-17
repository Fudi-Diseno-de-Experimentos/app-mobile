import 'package:equatable/equatable.dart';

/// A single chat message (`MessageResource`). Delivered either by the REST
/// history endpoint or live over the STOMP websocket topic.
class MessageEntity extends Equatable {
  final String messageId;
  final String groupId;
  final String senderId;
  final String body;
  final String status; // SENT | EDITED | DELETED
  final String sentAt;
  final String? editedAt;
  final bool isEdited;
  final bool isVisible;

  const MessageEntity({
    required this.messageId,
    required this.groupId,
    required this.senderId,
    required this.body,
    required this.status,
    required this.sentAt,
    this.editedAt,
    required this.isEdited,
    required this.isVisible,
  });

  /// Optimistic messages get a `local-` id until the server echo replaces them.
  bool get isPending => messageId.startsWith('local-');

  @override
  List<Object?> get props => [
        messageId,
        groupId,
        senderId,
        body,
        status,
        sentAt,
        editedAt,
        isEdited,
        isVisible,
      ];
}
