import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroups extends ChatEvent {
  final String userId;

  /// Needed to resolve DM display names from company member profiles.
  final String companyId;

  const LoadGroups(this.userId, this.companyId);

  @override
  List<Object?> get props => [userId, companyId];
}

/// Open (get-or-create) a 1:1 DM via `POST /api/v1/conversations`.
/// [displayName]/[avatarUrl] come from the picked person's profile and are
/// only used to label the synthesized feed/conversation entity.
class StartDirectChat extends ChatEvent {
  final String targetUserId;
  final String displayName;
  final String? avatarUrl;

  const StartDirectChat({
    required this.targetUserId,
    required this.displayName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [targetUserId, displayName, avatarUrl];
}

class ToggleArchive extends ChatEvent {
  final String groupId;

  const ToggleArchive(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

/// Load company employees for the people finder / group member picker.
class LoadCompanyMembers extends ChatEvent {
  final String companyId;

  const LoadCompanyMembers(this.companyId);

  @override
  List<Object?> get props => [companyId];
}

/// Create a group (also used for 1:1: a 2-member PRIVATE group).
class CreateGroupRequested extends ChatEvent {
  final String name;
  final String? description;
  final String? imageUrl;
  final String visibility;
  final List<String> memberIds;
  final String createdBy;

  const CreateGroupRequested({
    required this.name,
    this.description,
    this.imageUrl,
    required this.visibility,
    required this.memberIds,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [
        name,
        description,
        imageUrl,
        visibility,
        memberIds,
        createdBy,
      ];
}

/// Edit an existing group's name/description/image (`PUT /groups/{id}`).
class UpdateGroupRequested extends ChatEvent {
  final String groupId;
  final String name;
  final String? description;
  final String? imageUrl;

  const UpdateGroupRequested({
    required this.groupId,
    required this.name,
    this.description,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [groupId, name, description, imageUrl];
}
