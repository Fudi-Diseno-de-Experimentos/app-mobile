import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/main_app_bar.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../domain/entities/group_entity.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_item.dart';
import '../widgets/segmented_selector.dart';

/// Unified chat feed. One list, four client-side tabs:
/// All (recent-first) · Direct (2 members) · Groups (>2) · Archives (local).
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _tab = 0;
  bool _profileRequested = false;
  bool _groupsRequested = false;

  static const _tabs = ['All', 'Direct', 'Groups', 'Archives'];

  DateTime _parse(String iso) =>
      DateTime.tryParse(iso) ?? DateTime.fromMillisecondsSinceEpoch(0);

  List<GroupEntity> _filter(GroupsLoaded state) {
    final archived = state.archivedIds;
    final sorted = [...state.groups]
      ..sort((a, b) => _parse(b.updatedAt).compareTo(_parse(a.updatedAt)));
    switch (_tab) {
      case 1:
        return sorted
            .where((g) => !archived.contains(g.id) && g.isDirect)
            .toList();
      case 2:
        return sorted
            .where((g) => !archived.contains(g.id) && !g.isDirect)
            .toList();
      case 3:
        return sorted.where((g) => archived.contains(g.id)).toList();
      default:
        return sorted.where((g) => !archived.contains(g.id)).toList();
    }
  }

  Future<void> _openComposer(
    String userId,
    String companyId,
    String route,
  ) async {
    final created = await context.push<GroupEntity>(route);
    if (!mounted) return;
    if (created == null) return;
    context.read<ChatBloc>().add(LoadGroups(userId, companyId));
    context.push('/messages/conversation', extra: created);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        if (profileState is ProfileInitial && !_profileRequested) {
          _profileRequested = true;
          context.read<ProfileBloc>().add(ProfileLoadRequested());
        }

        if (profileState is! ProfileLoaded) {
          return Scaffold(
            appBar: const MainAppBar(title: 'Messages'),
            body: profileState is ProfileError
                ? Center(
                    child: Text(
                      profileState.message,
                      style: const TextStyle(color: AppColors.destructive),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          );
        }

        final userId = profileState.profile.userId;
        final companyId = profileState.profile.companyId ?? '';
        if (!_groupsRequested) {
          _groupsRequested = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<ChatBloc>().add(LoadGroups(userId, companyId));
            }
          });
        }

        return Scaffold(
          appBar: MainAppBar(
            title: 'Messages',
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.edit_square),
                onSelected: (v) => _openComposer(
                  userId,
                  companyId,
                  v == 'group'
                      ? '/messages/new-group'
                      : '/messages/new-chat',
                ),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'chat',
                    child: ListTile(
                      leading: Icon(Icons.person_outline),
                      title: Text('New message'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'group',
                    child: ListTile(
                      leading: Icon(Icons.group_add_outlined),
                      title: Text('New group'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: SegmentedSelector(
                  labels: _tabs,
                  selectedIndex: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
              ),
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoading || state is ChatInitial) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (state is ChatError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(
                            color: AppColors.destructive,
                          ),
                        ),
                      );
                    }
                    if (state is GroupsLoaded) {
                      final items = _filter(state);
                      if (items.isEmpty) {
                        return Center(
                          child: Text(
                            'No ${_tabs[_tab].toLowerCase()} chats',
                            style: const TextStyle(
                              color: AppColors.tertiary,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding:
                            const EdgeInsets.only(top: 8, bottom: 24),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final group = items[i];
                          return ChatItem(
                            group: group,
                            archived:
                                state.archivedIds.contains(group.id),
                            onTap: () => context.push(
                              '/messages/conversation',
                              extra: group,
                            ),
                            onToggleArchive: () {
                              final wasArchived =
                                  state.archivedIds.contains(group.id);
                              context
                                  .read<ChatBloc>()
                                  .add(ToggleArchive(group.id));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    wasArchived
                                        ? 'Unarchived'
                                        : 'Archived',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
