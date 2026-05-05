import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/iam/presentation/pages/sign_up_page.dart';
import '../features/iam/presentation/pages/sign_in_page.dart';
import '../features/iam/presentation/pages/verification_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/sign-in',
  routes: [
    GoRoute(path: '/sign-in', builder: (context, state) => const SignInPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      path: '/join-company',
      builder: (context, state) => const VerificationPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Home Placeholder'))),
    ),
  ],
);
