import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/iam/presentation/pages/sign_up_page.dart';
import '../features/iam/presentation/pages/sign_in_page.dart';
import '../features/iam/presentation/pages/verification_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/profile/presentation/pages/update_profile_page.dart';
import '../features/profile/domain/entities/profile_entity.dart';
import '../shared/widgets/main_app_bar.dart';
import '../shared/widgets/main_layout.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/feed/presentation/pages/company_feed_page.dart';
import '../features/announcements/presentation/pages/create_announcement_page.dart';
import '../features/events/presentation/pages/create_event_page.dart';

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
              builder: (context, state) => const Scaffold(
                appBar: MainAppBar(title: 'Home'),
                body: Center(child: Text('Home Placeholder')),
              ),
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
                  builder: (context, state) => const CreateAnnouncementPage(),
                ),
                GoRoute(
                  path: 'create-event',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const CreateEventPage(),
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
