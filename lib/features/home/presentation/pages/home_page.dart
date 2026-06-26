import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/core/utils/date_format.dart';
import 'package:app_mobile/features/announcements/domain/entities/announcement_entity.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/announcement_bloc.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/announcement_event.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/announcement_state.dart';
import 'package:app_mobile/features/announcements/presentation/widgets/priority_dot.dart';
import 'package:app_mobile/features/chat/domain/entities/group_entity.dart';
import 'package:app_mobile/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:app_mobile/features/chat/presentation/bloc/chat_event.dart';
import 'package:app_mobile/features/chat/presentation/bloc/chat_state.dart';
import 'package:app_mobile/features/events/domain/entities/event_entity.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_bloc.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_event.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_state.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AnnouncementBloc>()..add(FetchAnnouncements()),
        ),
        BlocProvider(
          create: (_) => sl<EventBloc>()..add(FetchEvents()),
        ),
      ],
      child: const _HomeContent(),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Text(
                  'Home',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),

            // Latest Chats
            SliverToBoxAdapter(
              child: _SectionHeader(title: 'RECENT CHATS'),
            ),
            const SliverToBoxAdapter(child: _LatestChatsSection()),

            // Company Announcements
            SliverToBoxAdapter(
              child: _SectionHeader(title: 'COMPANY ANNOUNCEMENTS'),
            ),
            const SliverToBoxAdapter(child: _AnnouncementsSection()),

            // Events
            SliverToBoxAdapter(
              child: _SectionHeader(title: 'EVENTS'),
            ),
            const _EventsSection(),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
      child: Text(
        title,
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─── Latest Chats ─────────────────────────────────────────────────────────────

class _LatestChatsSection extends StatefulWidget {
  const _LatestChatsSection();

  @override
  State<_LatestChatsSection> createState() => _LatestChatsSectionState();
}

class _LatestChatsSectionState extends State<_LatestChatsSection> {
  late final ChatBloc _chatBloc;
  bool _requested = false;

  @override
  void initState() {
    super.initState();
    _chatBloc = sl<ChatBloc>();
    _loadChats(context.read<ProfileBloc>().state);
  }

  @override
  void dispose() {
    _chatBloc.close();
    super.dispose();
  }

  void _loadChats(ProfileState profileState) {
    if (_requested) return;
    final profile = profileState.profileOrNull;
    if (profile == null) return;
    _requested = true;
    _chatBloc.add(LoadGroups(profile.id, profile.companyId ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // The profile may still be loading when home first builds; request the
    // chat feed as soon as it arrives.
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) => _loadChats(state),
      child: BlocBuilder<ChatBloc, ChatState>(
        bloc: _chatBloc,
        builder: (context, state) {
          final chats = state is GroupsLoaded
              ? (state.groups
                    .where((g) => !state.archivedIds.contains(g.id))
                    .toList()
                ..sort((a, b) => (DateTime.tryParse(b.updatedAt) ??
                        DateTime.fromMillisecondsSinceEpoch(0))
                    .compareTo(DateTime.tryParse(a.updatedAt) ??
                        DateTime.fromMillisecondsSinceEpoch(0))))
              : const <GroupEntity>[];

          if (chats.isEmpty) {
            return SizedBox(
              height: 88,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 18,
                      color: colorScheme.onSurface.withValues(alpha: 0.35),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'No recent chats',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: chats.length.clamp(0, 6),
              separatorBuilder: (_, _) => const SizedBox(width: 20),
              itemBuilder: (context, index) {
                final chat = chats[index];
                final hasImage =
                    chat.imageUrl != null && chat.imageUrl!.isNotEmpty;
                return GestureDetector(
                  onTap: () => context.go('/messages'),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            colorScheme.primary.withValues(alpha: 0.1),
                        backgroundImage:
                            hasImage ? NetworkImage(chat.imageUrl!) : null,
                        child: hasImage
                            ? null
                            : Text(
                                chat.name.isNotEmpty
                                    ? chat.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(color: colorScheme.primary),
                              ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 64,
                        child: Text(
                          chat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ─── Announcements horizontal scroll ─────────────────────────────────────────

class _AnnouncementsSection extends StatelessWidget {
  const _AnnouncementsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnnouncementBloc, AnnouncementState>(
      builder: (context, state) {
        if (state is AnnouncementLoading) {
          return const SizedBox(
            height: 130,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AnnouncementError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              state.message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }
        if (state is AnnouncementLoaded) {
          if (state.announcements.isEmpty) {
            return _EmptyHint(
              icon: Icons.campaign_outlined,
              label: 'No recent announcements',
            );
          }
          return SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 24, right: 8),
              itemCount: state.announcements.length,
              itemBuilder: (context, index) {
                return _AnnouncementMiniCard(
                  item: state.announcements[index],
                );
              },
            ),
          );
        }
        return const SizedBox(height: 140);
      },
    );
  }
}

class _AnnouncementMiniCard extends StatelessWidget {
  final AnnouncementEntity item;

  const _AnnouncementMiniCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () async {
        await context.push('/home/announcement', extra: item);
        if (context.mounted) {
          context.read<AnnouncementBloc>().add(FetchAnnouncements());
        }
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12, bottom: 4, top: 2),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.secondary.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: PriorityDot(priority: item.priority, size: 10),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              item.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Events vertical list ─────────────────────────────────────────────────────

class _EventsSection extends StatelessWidget {
  const _EventsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        if (state is EventLoading) {
          return const SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (state is EventError) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                state.message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          );
        }
        if (state is EventLoaded) {
          if (state.events.isEmpty) {
            return SliverToBoxAdapter(
              child: _EmptyHint(
                icon: Icons.event_outlined,
                label: 'No upcoming events',
              ),
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _EventMiniCard(item: state.events[index]),
              childCount: state.events.length,
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}

class _EventMiniCard extends StatelessWidget {
  final EventEntity item;

  const _EventMiniCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => context.push('/files/event', extra: item),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.secondary.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Date block
            Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _dayOf(item.date),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    _monthOf(item.date),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          AppDateFormat.relativeDateTime(item.date),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }

  String _dayOf(String isoDate) {
    try {
      return DateTime.parse(isoDate).day.toString();
    } catch (_) {
      return '—';
    }
  }

  String _monthOf(String isoDate) {
    const months = [
      '', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    try {
      final m = DateTime.parse(isoDate).month;
      return months[m];
    } catch (_) {
      return '';
    }
  }
}

// ─── Shared empty hint ────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EmptyHint({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.35)),
          const SizedBox(width: 8),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}
