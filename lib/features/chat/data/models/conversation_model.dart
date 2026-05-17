import '../../domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.otherUserId,
    required super.memberIds,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['memberIds'];
    final members = rawMembers is List
        ? rawMembers.map((e) => e.toString()).toList()
        : <String>[];
    return ConversationModel(
      id: (json['id'] ?? '').toString(),
      otherUserId: (json['otherUserId'] ?? '').toString(),
      memberIds: members,
      createdAt: (json['createdAt'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? json['createdAt'] ?? '').toString(),
    );
  }
}
