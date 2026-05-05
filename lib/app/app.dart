import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_theme.dart';
import '../features/iam/presentation/bloc/iam_bloc.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';
import 'di.dart';
import 'router.dart';

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
        routerConfig: appRouter,
      ),
    );
  }
}
