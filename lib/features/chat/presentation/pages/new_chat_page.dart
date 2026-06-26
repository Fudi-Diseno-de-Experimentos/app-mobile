import 'package:app_mobile/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:app_mobile/features/chat/presentation/bloc/chat_event.dart';
import 'package:app_mobile/features/chat/presentation/bloc/chat_state.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// People finder: search company employees, tap one to start a 1:1 chat.
/// A 1:1 is a backend `DIRECT` conversation created/fetched (idempotent) via
/// `POST /api/v1/conversations` — never a normal group.
class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  bool _membersRequested = false;
  bool _profileRequested = false;
  List<ProfileEntity> _members = const [];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ProfileEntity> _filtered(String currentUserId) {
    final q = _query.trim().toLowerCase();
    return _members.where((m) {
      if (m.id == currentUserId) return false; // can't DM yourself
      if (q.isEmpty) return true;
      final hay = '${m.name} ${m.lastname} ${m.email}'.toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  void _startChat(ProfileEntity person) {
    context.read<ChatBloc>().add(
          StartDirectChat(
            targetUserId: person.userId,
            displayName: '${person.name} ${person.lastname}'.trim(),
            avatarUrl: person.avatarUrl,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        if (profileState is ProfileInitial && !_profileRequested) {
          _profileRequested = true;
          context.read<ProfileBloc>().add(ProfileLoadRequested());
        }

        final me = profileState.profileOrNull;

        if (me == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('New message')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final currentUserId = me.id;
        final companyId = me.companyId;

        if (!_membersRequested && companyId != null && companyId.isNotEmpty) {
          _membersRequested = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<ChatBloc>().add(LoadCompanyMembers(companyId));
            }
          });
        }

        return Scaffold(
          appBar: AppBar(title: const Text('New message')),
          body: BlocConsumer<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state is CompanyMembersLoaded) {
                setState(() => _members = state.members);
              } else if (state is GroupCreated) {
                context.pop(state.group);
              } else if (state is ChatError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: colorScheme.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              final creating = state is GroupCreating;
              final loading =
                  state is CompanyMembersLoading && _members.isEmpty;

              return Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _search,
                          onChanged: (v) => setState(() => _query = v),
                          decoration: InputDecoration(
                            hintText: 'Search people',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor:
                                colorScheme.secondary.withValues(alpha: 0.12),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: loading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildList(currentUserId, colorScheme),
                      ),
                    ],
                  ),
                  if (creating)
                    Container(
                      color: Colors.black.withValues(alpha: 0.15),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildList(String currentUserId, ColorScheme colorScheme) {
    final people = _filtered(currentUserId);
    if (people.isEmpty) {
      return const Center(child: Text('No people found'));
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: people.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final p = people[i];
        final initials =
            '${p.name.isNotEmpty ? p.name[0] : ''}${p.lastname.isNotEmpty ? p.lastname[0] : ''}'
                .toUpperCase();
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            backgroundImage:
                (p.avatarUrl != null && p.avatarUrl!.isNotEmpty)
                    ? NetworkImage(p.avatarUrl!)
                    : null,
            child: (p.avatarUrl == null || p.avatarUrl!.isEmpty)
                ? Text(
                    initials,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          title: Text('${p.name} ${p.lastname}'.trim()),
          subtitle: Text(p.email),
          trailing: const Icon(Icons.chat_bubble_outline, size: 20),
          onTap: () => _startChat(p),
        );
      },
    );
  }
}
