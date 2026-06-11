import 'package:app_mobile/features/chat/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.messageId,
    required super.groupId,
    required super.senderId,
    required super.body,
    required super.status,
    required super.sentAt,
    super.editedAt,
    required super.isEdited,
    required super.isVisible,
  });

  /// Handles both the REST `MessageResource` and the websocket topic payload,
  /// which share the same shape but may omit `groupId` on the live channel.
  factory MessageModel.fromJson(
    Map<String, dynamic> json, {
    String? fallbackGroupId,
  }) {
    return MessageModel(
      messageId: (json['messageId'] ?? json['id'] ?? '').toString(),
      groupId: (json['groupId'] ?? fallbackGroupId ?? '').toString(),
      senderId: (json['senderId'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      status: (json['status'] ?? 'SENT').toString(),
      sentAt: (json['sentAt'] ?? '').toString(),
      editedAt: json['editedAt']?.toString(),
      isEdited: json['isEdited'] == true,
      isVisible: json['isVisible'] != false,
    );
  }
}
