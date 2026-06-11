import 'package:app_mobile/features/chat/domain/entities/group_entity.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class GroupsLoaded extends ChatState {
  final List<GroupEntity> groups;
  final Set<String> archivedIds;

  const GroupsLoaded(this.groups, this.archivedIds);

  @override
  List<Object?> get props => [groups, archivedIds];
}

// ─── People finder / group creator states ────────────────────────────────────

class CompanyMembersLoading extends ChatState {}

class CompanyMembersLoaded extends ChatState {
  final List<ProfileEntity> members;

  const CompanyMembersLoaded(this.members);

  @override
  List<Object?> get props => [members];
}

class GroupCreating extends ChatState {}

class GroupCreated extends ChatState {
  final GroupEntity group;

  const GroupCreated(this.group);

  @override
  List<Object?> get props => [group];
}

// ─── Group editing states ────────────────────────────────────────────────────

class GroupUpdating extends ChatState {}

class GroupUpdated extends ChatState {
  final GroupEntity group;

  const GroupUpdated(this.group);

  @override
  List<Object?> get props => [group];
}
