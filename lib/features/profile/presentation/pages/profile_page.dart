import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_state.dart';
import 'package:app_mobile/features/profile/presentation/widgets/members_tab_content.dart';
import 'package:app_mobile/features/profile/presentation/widgets/profile_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
    final colorScheme = theme.colorScheme;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state.profileOrNull;
        final isManagerOrAdmin = profile?.isManagerOrAdmin ?? false;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              if (profile != null)
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Settings',
                  onPressed: () =>
                      context.push('/profile/settings', extra: profile),
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
                } else if (profile != null) {
                  if (isManagerOrAdmin && profile.companyId != null) {
                    return DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                            labelColor: colorScheme.primary,
                            unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
                            indicatorColor: colorScheme.primary,
                            tabs: const [
                              Tab(text: 'My Profile'),
                              Tab(text: 'Members'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                ProfileBody(profile: profile),
                                MembersTabContent(companyId: profile.companyId!),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ProfileBody(profile: profile);
                }
                return const SizedBox();
              },
            ),
          ),
        );
      },
    );
  }
}
