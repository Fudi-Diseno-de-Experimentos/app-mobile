import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/announcements/presentation/bloc/announcement_bloc.dart';
import '../../../../features/announcements/presentation/bloc/announcement_event.dart';
import '../../../../features/announcements/presentation/widgets/announcements_view.dart';
import '../../../../features/events/presentation/bloc/event_bloc.dart';
import '../../../../features/events/presentation/bloc/event_event.dart';
import '../../../../features/events/presentation/widgets/events_view.dart';

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
          create: (_) => sl<EventBloc>()..add(FetchEvents()),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                  const Text(
                    "Company Feed",
                    style: TextStyle(
                      color: AppColors.neutral,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Official updates and news from across the organization",
                    style: TextStyle(
                      color: AppColors.tertiary,
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
                                  ? AppColors.neutral
                                  : AppColors.secondary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Announcements",
                              style: TextStyle(
                                color: _selectedIndex == 0
                                    ? AppColors.surface
                                    : AppColors.tertiary,
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
                                  ? AppColors.neutral
                                  : AppColors.secondary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Events",
                              style: TextStyle(
                                color: _selectedIndex == 1
                                    ? AppColors.surface
                                    : AppColors.tertiary,
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
}
