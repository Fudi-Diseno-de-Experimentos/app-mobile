import 'package:equatable/equatable.dart';

/// A chat target rendered in the unified feed.
///
/// Two backend resources collapse onto this one entity:
/// - A real group from `GET /api/v1/groups` (`type == 'GROUP'`).
/// - A direct conversation from `GET /api/v1/conversations`, synthesized
///   client-side into a `type == 'DIRECT'` entity so the feed/UI stay uniform.
///
/// `DIRECT` rows route messages through `/conversations/{id}`; `GROUP` rows
/// through `/groups/{id}`. Archiving remains a local-only client concept.
class GroupEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String visibility; // PUBLIC | PRIVATE
  final String type; // GROUP | DIRECT
  final List<String> memberIds;
  final int memberCount;
  final String createdBy;
  final String createdAt;
  final String updatedAt;

  const GroupEntity({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.visibility,
    this.type = 'GROUP',
    required this.memberIds,
    required this.memberCount,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isDirect => type == 'DIRECT';

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        visibility,
        type,
        memberIds,
        memberCount,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
