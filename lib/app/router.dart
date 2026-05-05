import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/iam/presentation/pages/sign_up_page.dart';
import '../features/iam/presentation/pages/sign_in_page.dart';
import '../features/iam/presentation/pages/verification_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/profile/presentation/pages/update_profile_page.dart';
import '../features/profile/domain/entities/profile_entity.dart';
import '../shared/widgets/main_app_bar.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/sign-in',
  routes: [
    GoRoute(path: '/sign-in', builder: (context, state) => const SignInPage()),
    GoRoute(path: '/register', builder: (context, state) => const SignUpPage()),
    GoRoute(
      path: '/join-company',
      builder: (context, state) => const VerificationPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const Scaffold(
        appBar: MainAppBar(title: 'Home'),
        body: Center(child: Text('Home Placeholder')),
      ),
    ),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    GoRoute(
      path: '/update-profile',
      builder: (context, state) {
        final profile = state.extra as ProfileEntity;
        return UpdateProfilePage(profile: profile);
      },
    ),
  ],
);
