import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'di.dart';
import '../features/iam/presentation/pages/sign_up_page.dart';
import '../features/iam/presentation/pages/sign_in_page.dart';
import '../features/iam/presentation/pages/verification_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/profile/presentation/pages/settings_page.dart';
import '../features/profile/presentation/pages/update_profile_page.dart';
import '../features/profile/domain/entities/profile_entity.dart';
import '../shared/widgets/main_layout.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/feed/presentation/pages/company_feed_page.dart';
import '../features/announcements/presentation/pages/announcement_page.dart';
import '../features/announcements/presentation/pages/create_announcement_page.dart';
import '../features/announcements/presentation/bloc/announcement_bloc.dart';
import '../features/announcements/presentation/bloc/comment_bloc.dart';
import '../features/announcements/domain/entities/announcement_entity.dart';
import '../features/events/domain/entities/event_entity.dart';
import '../features/events/presentation/pages/create_event_page.dart';
import '../features/events/presentation/pages/event_page.dart';
import '../features/events/presentation/bloc/event_bloc.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/iam/presentation/bloc/iam_bloc.dart';
import '../shared/widgets/main_app_bar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'home',
);
final GlobalKey<NavigatorState> _filesNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'files',
);
final GlobalKey<NavigatorState> _messagesNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'messages');
final GlobalKey<NavigatorState> _profileNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

CustomTransitionPage<T> _slideFromRight<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Widget _announcementDetail(AnnouncementEntity item) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => sl<AnnouncementBloc>()),
      BlocProvider(create: (_) => sl<CommentBloc>()),
    ],
    child: AnnouncementPage(announcement: item),
  );
}

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/sign-in',
  routes: [
    GoRoute(path: '/sign-in', builder: (context, state) => const SignInPage()),
    GoRoute(path: '/register', builder: (context, state) => const SignUpPage()),
    GoRoute(
      path: '/join-company',
      builder: (context, state) => const VerificationPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
              routes: [
                GoRoute(
                  path: 'announcement',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) {
                    final item = state.extra as AnnouncementEntity;
                    return _slideFromRight(
                      key: state.pageKey,
                      child: _announcementDetail(item),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _filesNavigatorKey,
          routes: [
            GoRoute(
              path: '/files',
              builder: (context, state) => const CompanyFeedPage(),
              routes: [
                GoRoute(
                  path: 'create-announcement',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => BlocProvider(
                    create: (context) => sl<AnnouncementBloc>(),
                    child: CreateAnnouncementPage(
                      announcement: state.extra as AnnouncementEntity?,
                    ),
                  ),
                ),
                GoRoute(
                  path: 'create-event',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => BlocProvider(
                    create: (context) => sl<EventBloc>(),
                    child: CreateEventPage(
                      event: state.extra as EventEntity?,
                    ),
                  ),
                ),
                GoRoute(
                  path: 'announcement',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) {
                    final item = state.extra as AnnouncementEntity;
                    return _slideFromRight(
                      key: state.pageKey,
                      child: _announcementDetail(item),
                    );
                  },
                ),
                GoRoute(
                  path: 'event',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) {
                    final event = state.extra as EventEntity;
                    return _slideFromRight(
                      key: state.pageKey,
                      child: BlocProvider(
                        create: (context) => sl<EventBloc>(),
                        child: EventPage(event: event),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _messagesNavigatorKey,
          routes: [
            GoRoute(
              path: '/messages',
              builder: (context, state) => Scaffold(
                appBar: const MainAppBar(title: 'Messages'),
                body: const ChatPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
              routes: [
                GoRoute(
                  path: 'settings',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final profile = state.extra as ProfileEntity;
                    return BlocProvider(
                      create: (context) => sl<IamBloc>(),
                      child: SettingsPage(profile: profile),
                    );
                  },
                ),
                GoRoute(
                  path: 'update',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final profile = state.extra as ProfileEntity;
                    return UpdateProfilePage(profile: profile);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
