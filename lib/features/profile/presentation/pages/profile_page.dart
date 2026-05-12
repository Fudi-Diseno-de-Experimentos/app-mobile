import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_action_button.dart';
import '../widgets/role_chip.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(ProfileLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded || state is ProfileUpdateSuccess) {
                final profile = (state is ProfileLoaded)
                    ? state.profile
                    : (state as ProfileUpdateSuccess).profile;
                return IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Settings',
                  onPressed: () =>
                      context.push('/profile/settings', extra: profile),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ProfileBloc>().add(
                        ProfileLoadRequested(),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is ProfileLoaded ||
                state is ProfileUpdateSuccess) {
              final profile = (state is ProfileLoaded)
                  ? state.profile
                  : (state as ProfileUpdateSuccess).profile;
              return _ProfileBody(profile: profile);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final ProfileEntity profile;

  const _ProfileBody({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final roles = profile.roles ?? const <String>[];

    return Container(
      constraints: const BoxConstraints.expand(),
      color: theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 138,
              height: 138,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surface,
                image:
                    profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(profile.avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: profile.avatarUrl == null || profile.avatarUrl!.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 80,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    )
                  : null,
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              "${profile.name} ${profile.lastname}",
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),

            // Username
            Text(
              '@${profile.username}',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),

            // Email row
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.mail_outline,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    profile.email,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Roles as chips
            if (roles.isNotEmpty)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: roles.map((r) => RoleChip(role: r)).toList(),
              ),

            const SizedBox(height: 32),

            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProfileActionButton(
                  icon: Icons.phone,
                  onPressed: () {},
                ),
                const SizedBox(width: 18),
                ProfileActionButton(
                  icon: Icons.message,
                  onPressed: () {},
                ),
                const SizedBox(width: 18),
                ProfileActionButton(
                  icon: Icons.email,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
