import '../../domain/entities/group_entity.dart';

class GroupModel extends GroupEntity {
  const GroupModel({
    required super.id,
    required super.name,
    super.description,
    super.imageUrl,
    required super.visibility,
    super.type,
    required super.memberIds,
    required super.memberCount,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['memberIds'];
    final members = rawMembers is List
        ? rawMembers.map((e) => e.toString()).toList()
        : <String>[];
    return GroupModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      visibility: (json['visibility'] ?? 'PRIVATE').toString(),
      type: (json['type'] ?? 'GROUP').toString(),
      memberIds: members,
      memberCount: json['memberCount'] is int
          ? json['memberCount'] as int
          : int.tryParse('${json['memberCount']}') ?? members.length,
      createdBy: (json['createdBy'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? json['createdAt'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'visibility': visibility,
      'type': type,
      'memberIds': memberIds,
      'memberCount': memberCount,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
