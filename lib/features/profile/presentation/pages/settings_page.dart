import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/iam/presentation/bloc/iam_bloc.dart';
import '../../../../features/iam/presentation/bloc/iam_event.dart';
import '../../../../features/iam/presentation/bloc/iam_state.dart';
import '../../domain/entities/profile_entity.dart';
import '../widgets/settings_tile.dart';

class SettingsPage extends StatelessWidget {
  final ProfileEntity profile;

  const SettingsPage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<IamBloc, IamState>(
      listener: (context, state) {
        if (state is IamSignOutSuccess) {
          context.go('/sign-in');
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Settings',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  subtitle: 'Update your name, email and photo',
                  onTap: () =>
                      context.push('/profile/update', extra: profile),
                ),
                const SizedBox(height: 32),
                Text(
                  'Session',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SettingsTile(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  subtitle: 'Log out of your account',
                  iconColor: colorScheme.error,
                  titleColor: colorScheme.error,
                  onTap: () {
                    context.read<IamBloc>().add(const SignOutSubmitted());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
