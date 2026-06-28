import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/announcement_bloc.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/announcement_event.dart';
import 'package:app_mobile/features/announcements/presentation/widgets/announcements_view.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_bloc.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_event.dart';
import 'package:app_mobile/features/events/presentation/widgets/events_view.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CompanyFeedPage extends StatelessWidget {
  const CompanyFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AnnouncementBloc>()..add(FetchAnnouncements()),
        ),
        BlocProvider(
          create: (_) => sl<EventBloc>()
            ..add(FetchEvents.forProfile(
              context.read<ProfileBloc>().state.profileOrNull,
            )),
        ),
      ],
      child: const _CompanyFeedPageContent(),
    );
  }
}

class _CompanyFeedPageContent extends StatefulWidget {
  const _CompanyFeedPageContent();

  @override
  State<_CompanyFeedPageContent> createState() => _CompanyFeedPageContentState();
}

class _CompanyFeedPageContentState extends State<_CompanyFeedPageContent> {
  int _selectedIndex = 0; // 0: Announcements, 1: Events

  @override
  void initState() {
    super.initState();
    final profileBloc = context.read<ProfileBloc>();
    if (profileBloc.state is ProfileInitial) {
      profileBloc.add(ProfileLoadRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: _buildFloatingActionButton(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Company Feed',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () => context.push('/notifications'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Official updates and news from across the organization',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tabs
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedIndex = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedIndex == 0
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.secondary.withValues(alpha:0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Announcements',
                              style: TextStyle(
                                color: _selectedIndex == 0
                                    ? Theme.of(context).colorScheme.surface
                                    : Theme.of(context).colorScheme.tertiary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedIndex = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedIndex == 1
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.secondary.withValues(alpha:0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Events',
                              style: TextStyle(
                                color: _selectedIndex == 1
                                    ? Theme.of(context).colorScheme.surface
                                    : Theme.of(context).colorScheme.tertiary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content View
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: const [
                  AnnouncementsView(),
                  EventsView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_selectedIndex == 0) {
      // Announcements: accessible only to ROLE_ADMIN or ROLE_MANAGER
      return BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final canCreateAnnouncement =
              state.profileOrNull?.isManagerOrAdmin ?? false;

          if (canCreateAnnouncement) {
            final announcementBloc = context.read<AnnouncementBloc>();
            return FloatingActionButton(
              onPressed: () async {
                await context.push('/files/create-announcement');
                announcementBloc.add(FetchAnnouncements());
              },
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              child: Icon(Icons.add, color: Theme.of(context).colorScheme.surface),
            );
          }
          return const SizedBox.shrink();
        },
      );
    } else {
      // Events: accessible only to ROLE_ADMIN or ROLE_MANAGER
      return BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final canCreateEvent =
              state.profileOrNull?.isManagerOrAdmin ?? false;

          if (canCreateEvent) {
            return FloatingActionButton(
              onPressed: () async {
                await context.push('/files/create-event');
                if (context.mounted) {
                  context.read<EventBloc>().add(FetchEvents.forProfile(
                        context.read<ProfileBloc>().state.profileOrNull,
                      ));
                }
              },
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              child: Icon(Icons.event, color: Theme.of(context).colorScheme.surface),
            );
          }
          return const SizedBox.shrink();
        },
      );
    }
  }
}

