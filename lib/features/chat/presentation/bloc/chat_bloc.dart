import 'package:app_mobile/features/chat/data/datasources/chat_archive_store.dart';
import 'package:app_mobile/features/chat/domain/entities/conversation_entity.dart';
import 'package:app_mobile/features/chat/domain/entities/group_entity.dart';
import 'package:app_mobile/features/chat/domain/usecases/create_group_usecase.dart';
import 'package:app_mobile/features/chat/domain/usecases/get_my_conversations_usecase.dart';
import 'package:app_mobile/features/chat/domain/usecases/get_my_groups_usecase.dart';
import 'package:app_mobile/features/chat/domain/usecases/start_conversation_usecase.dart';
import 'package:app_mobile/features/chat/domain/usecases/update_group_usecase.dart';
import 'package:app_mobile/features/chat/presentation/bloc/chat_event.dart';
import 'package:app_mobile/features/chat/presentation/bloc/chat_state.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_company_members_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetMyGroupsUseCase getMyGroupsUseCase;
  final GetMyConversationsUseCase getMyConversationsUseCase;
  final StartConversationUseCase startConversationUseCase;
  final GetCompanyMembersUseCase getCompanyMembersUseCase;
  final CreateGroupUseCase createGroupUseCase;
  final UpdateGroupUseCase updateGroupUseCase;
  final ChatArchiveStore archiveStore;

  List<GroupEntity> _groups = const [];

  ChatBloc({
    required this.getMyGroupsUseCase,
    required this.getMyConversationsUseCase,
    required this.startConversationUseCase,
    required this.getCompanyMembersUseCase,
    required this.createGroupUseCase,
    required this.updateGroupUseCase,
    required this.archiveStore,
  }) : super(ChatInitial()) {
    on<LoadGroups>(_onLoadGroups);
    on<StartDirectChat>(_onStartDirectChat);
    on<ToggleArchive>(_onToggleArchive);
    on<LoadCompanyMembers>(_onLoadCompanyMembers);
    on<CreateGroupRequested>(_onCreateGroupRequested);
    on<UpdateGroupRequested>(_onUpdateGroupRequested);
  }

  /// Synthesize a `DIRECT` [GroupEntity] from a DM so the feed/UI stay uniform.
  GroupEntity _toGroup(
    ConversationEntity c,
    Map<String, ProfileEntity> byUserId,
  ) {
    final other = byUserId[c.otherUserId];
    final name = other == null
        ? 'Direct chat'
        : '${other.name} ${other.lastname}'.trim();
    return GroupEntity(
      id: c.id,
      name: name.isEmpty ? 'Direct chat' : name,
      imageUrl: other?.avatarUrl,
      visibility: 'PRIVATE',
      type: 'DIRECT',
      memberIds: c.memberIds,
      memberCount: c.memberIds.length,
      createdBy: '',
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
    );
  }

  Future<void> _onLoadGroups(
    LoadGroups event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());

    final groupsResult = await getMyGroupsUseCase(event.userId);
    final groups = groupsResult.getRight().toNullable();
    if (groups == null) {
      groupsResult.fold(
        (failure) => emit(ChatError(failure.message)),
        (_) {},
      );
      return;
    }

    // Resolve DM names from company members; tolerate missing companyId.
    final byUserId = <String, ProfileEntity>{};
    if (event.companyId.isNotEmpty) {
      final membersResult =
          await getCompanyMembersUseCase(event.companyId);
      membersResult.fold(
        (_) {},
        (members) {
          for (final m in members) {
            byUserId[m.userId] = m;
          }
        },
      );
    }

    // DMs are excluded from /groups; fetch them separately. A DM failure
    // must not blank the whole feed, so we just drop them on error.
    final conversationsResult = await getMyConversationsUseCase();
    final dms = conversationsResult
        .map((list) => list.map((c) => _toGroup(c, byUserId)).toList())
        .getRight()
        .toNullable() ??
        const <GroupEntity>[];

    _groups = [...groups, ...dms];
    emit(GroupsLoaded(_groups, archiveStore.getArchived()));
  }

  Future<void> _onStartDirectChat(
    StartDirectChat event,
    Emitter<ChatState> emit,
  ) async {
    emit(GroupCreating());
    final result = await startConversationUseCase(event.targetUserId);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (conversation) => emit(
        GroupCreated(
          GroupEntity(
            id: conversation.id,
            name: event.displayName.isEmpty
                ? 'Direct chat'
                : event.displayName,
            imageUrl: event.avatarUrl,
            visibility: 'PRIVATE',
            type: 'DIRECT',
            memberIds: conversation.memberIds,
            memberCount: conversation.memberIds.length,
            createdBy: '',
            createdAt: conversation.createdAt,
            updatedAt: conversation.updatedAt,
          ),
        ),
      ),
    );
  }

  Future<void> _onToggleArchive(
    ToggleArchive event,
    Emitter<ChatState> emit,
  ) async {
    final archived = await archiveStore.toggle(event.groupId);
    emit(GroupsLoaded(_groups, archived));
  }

  Future<void> _onLoadCompanyMembers(
    LoadCompanyMembers event,
    Emitter<ChatState> emit,
  ) async {
    emit(CompanyMembersLoading());
    final result = await getCompanyMembersUseCase(event.companyId);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (members) => emit(CompanyMembersLoaded(members)),
    );
  }

  Future<void> _onCreateGroupRequested(
    CreateGroupRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(GroupCreating());
    final result = await createGroupUseCase(
      name: event.name,
      description: event.description,
      imageUrl: event.imageUrl,
      visibility: event.visibility,
      memberIds: event.memberIds,
      createdBy: event.createdBy,
    );
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (group) => emit(GroupCreated(group)),
    );
  }

  Future<void> _onUpdateGroupRequested(
    UpdateGroupRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(GroupUpdating());
    final result = await updateGroupUseCase(
      groupId: event.groupId,
      name: event.name,
      description: event.description,
      imageUrl: event.imageUrl,
    );
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (group) => emit(GroupUpdated(group)),
    );
  }
}
