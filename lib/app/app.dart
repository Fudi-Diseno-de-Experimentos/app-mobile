import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/app/router.dart';
import 'package:app_mobile/core/theme/app_theme.dart';
import 'package:app_mobile/features/iam/presentation/bloc/iam_bloc.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// App-level messenger so non-widget code (the auth interceptor's expiry
/// callback, cold-start cleanup) can surface a snackbar.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<IamBloc>(create: (_) => sl<IamBloc>()),
        BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Centralis',
        theme: AppTheme.lightTheme,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        routerConfig: appRouter,
      ),
    );
  }
}
