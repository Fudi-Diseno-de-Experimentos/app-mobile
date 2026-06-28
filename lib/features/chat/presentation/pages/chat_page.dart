import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/features/chat/domain/entities/group_entity.dart';
import 'package:app_mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:app_mobile/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:app_mobile/features/chat/presentation/bloc/chat_event.dart';
import 'package:app_mobile/features/chat/presentation/bloc/chat_state.dart';
import 'package:app_mobile/features/chat/presentation/widgets/chat_item.dart';
import 'package:app_mobile/features/chat/presentation/widgets/segmented_selector.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_state.dart';
import 'package:app_mobile/shared/widgets/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

  Future<void> _showComposerSheet(String userId, String companyId) async {
    final route = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('New message'),
              onTap: () => Navigator.of(context).pop('/messages/new-chat'),
            ),
            ListTile(
              leading: const Icon(Icons.group_add_outlined),
              title: const Text('New group'),
              onTap: () => Navigator.of(context).pop('/messages/new-group'),
            ),
          ],
        ),
      ),
    );
    if (route == null || !mounted) return;
    await _openComposer(userId, companyId, route);
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
            appBar: MainAppBar(
              title: 'Messages',
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push('/notifications'),
                ),
              ],
            ),
            body: profileState is ProfileError
                ? Center(
                    child: Text(
                      profileState.message,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
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
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showComposerSheet(userId, companyId),
            backgroundColor: Theme.of(context).colorScheme.onSurface,
            child: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.surface,
            ),
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
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      );
                    }
                    if (state is GroupsLoaded) {
                      final items = _filter(state);
                      return RefreshIndicator(
                        onRefresh: () async {
                          await sl<ChatRepository>().clearCache();
                          if (context.mounted) {
                            context.read<ChatBloc>().add(LoadGroups(userId, companyId));
                          }
                        },
                        child: items.isEmpty
                            ? SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Container(
                                  height: MediaQuery.of(context).size.height * 0.6,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'No ${_tabs[_tab].toLowerCase()} chats',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.tertiary,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(top: 4, bottom: 24),
                                itemCount: items.length,
                                separatorBuilder: (context, _) => Divider(
                                  height: 1,
                                  thickness: 1,
                                  indent: 86,
                                  endIndent: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withValues(alpha: 0.15),
                                ),
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
                              ),
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
