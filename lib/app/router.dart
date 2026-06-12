import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/core/auth/token_store.dart';
import 'package:app_mobile/features/announcements/domain/entities/announcement_entity.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/announcement_bloc.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/comment_bloc.dart';
import 'package:app_mobile/features/announcements/presentation/pages/announcement_page.dart';
import 'package:app_mobile/features/announcements/presentation/pages/create_announcement_page.dart';
import 'package:app_mobile/features/chat/domain/entities/group_entity.dart';
import 'package:app_mobile/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:app_mobile/features/chat/presentation/bloc/message_bloc.dart';
import 'package:app_mobile/features/chat/presentation/pages/chat_page.dart';
import 'package:app_mobile/features/chat/presentation/pages/conversation_page.dart';
import 'package:app_mobile/features/chat/presentation/pages/create_group_page.dart';
import 'package:app_mobile/features/chat/presentation/pages/edit_group_page.dart';
import 'package:app_mobile/features/chat/presentation/pages/new_chat_page.dart';
import 'package:app_mobile/features/company/domain/entities/company_entity.dart';
import 'package:app_mobile/features/company/presentation/bloc/company_bloc.dart';
import 'package:app_mobile/features/company/presentation/bloc/space_bloc.dart';
import 'package:app_mobile/features/company/presentation/pages/company_page.dart';
import 'package:app_mobile/features/company/presentation/pages/spaces_page.dart';
import 'package:app_mobile/features/company/presentation/pages/unassigned_employees_page.dart';
import 'package:app_mobile/features/events/domain/entities/event_entity.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_bloc.dart';
import 'package:app_mobile/features/events/presentation/pages/create_event_page.dart';
import 'package:app_mobile/features/events/presentation/pages/event_page.dart';
import 'package:app_mobile/features/feed/presentation/pages/company_feed_page.dart';
import 'package:app_mobile/features/home/presentation/pages/home_page.dart';
import 'package:app_mobile/features/iam/presentation/bloc/iam_bloc.dart';
import 'package:app_mobile/features/iam/presentation/pages/company_setup_page.dart';
import 'package:app_mobile/features/iam/presentation/pages/sign_in_page.dart';
import 'package:app_mobile/features/iam/presentation/pages/sign_up_page.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:app_mobile/features/profile/presentation/pages/company_edit_page.dart';
import 'package:app_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:app_mobile/features/profile/presentation/pages/settings_page.dart';
import 'package:app_mobile/features/profile/presentation/pages/update_profile_page.dart';
import 'package:app_mobile/shared/widgets/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
  initialLocation: sl<TokenStore>().isSignedIn ? '/home' : '/sign-in',
  redirect: (context, state) {
    final signedIn = sl<TokenStore>().isSignedIn;
    final onAuthPage = state.matchedLocation == '/sign-in' ||
        state.matchedLocation == '/register';

    if (!signedIn && !onAuthPage) return '/sign-in';
    if (signedIn && onAuthPage) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/sign-in', builder: (context, state) => const SignInPage()),
    GoRoute(path: '/register', builder: (context, state) => const SignUpPage()),
    GoRoute(
      path: '/join-company',
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<CompanyBloc>()),
          BlocProvider(create: (_) => sl<IamBloc>()),
        ],
        child: const CompanySetupPage(),
      ),
    ),
    GoRoute(
      path: '/company',
      builder: (context, state) =>
          CompanyPage(company: state.extra as CompanyEntity),
      routes: [
        GoRoute(
          path: 'spaces',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<SpaceBloc>(),
            child: const SpacesPage(),
          ),
        ),
        GoRoute(
          path: 'unassigned',
          builder: (context, state) =>
              UnassignedEmployeesPage(company: state.extra as CompanyEntity),
        ),
      ],
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
              builder: (context, state) => BlocProvider(
                create: (_) => sl<ChatBloc>(),
                child: const ChatPage(),
              ),
              routes: [
                GoRoute(
                  path: 'conversation',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) {
                    final group = state.extra as GroupEntity;
                    return _slideFromRight(
                      key: state.pageKey,
                      child: BlocProvider(
                        create: (_) => sl<MessageBloc>(),
                        child: ConversationPage(group: group),
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: 'new-chat',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) {
                    return _slideFromRight(
                      key: state.pageKey,
                      child: BlocProvider(
                        create: (_) => sl<ChatBloc>(),
                        child: const NewChatPage(),
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: 'edit-group',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) {
                    final group = state.extra as GroupEntity;
                    return _slideFromRight(
                      key: state.pageKey,
                      child: BlocProvider(
                        create: (_) => sl<ChatBloc>(),
                        child: EditGroupPage(group: group),
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: 'new-group',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) {
                    return _slideFromRight(
                      key: state.pageKey,
                      child: BlocProvider(
                        create: (_) => sl<ChatBloc>(),
                        child: const CreateGroupPage(),
                      ),
                    );
                  },
                ),
              ],
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
                GoRoute(
                  path: 'company-edit',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final company = state.extra as CompanyEntity;
                    return BlocProvider(
                      create: (_) => sl<CompanyBloc>(),
                      child: CompanyEditPage(company: company),
                    );
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
