import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di.dart';
import '../../../analytics/presentation/bloc/analytics_bloc.dart';
import '../../../analytics/presentation/bloc/analytics_event.dart';
import '../../../analytics/presentation/bloc/analytics_state.dart';
import '../../../analytics/domain/entities/user_announcement_view_entity.dart';
import '../../../analytics/domain/entities/user_event_view_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_company_members_usecase.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_action_button.dart';

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
        final profile = state is ProfileLoaded
            ? state.profile
            : state is ProfileUpdateSuccess
                ? state.profile
                : null;

        final roles = profile?.roles ?? [];
        final isManagerOrAdmin =
            roles.contains('ROLE_ADMIN') || roles.contains('ROLE_MANAGER');

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
                            unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
                            indicatorColor: colorScheme.primary,
                            tabs: const [
                              Tab(text: 'My Profile'),
                              Tab(text: 'Members'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _ProfileBody(profile: profile),
                                _MembersTabContent(companyId: profile.companyId!),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return _ProfileBody(profile: profile);
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

String _positionLabel(String role) {
  switch (role) {
    case 'ROLE_ADMIN':
      return 'Admin';
    case 'ROLE_MANAGER':
      return 'Manager';
    case 'ROLE_USER':
      return 'Miembro';
    default:
      if (role.startsWith('ROLE_')) {
        final raw = role.substring(5).toLowerCase();
        return raw.isEmpty ? role : raw[0].toUpperCase() + raw.substring(1);
      }
      return role;
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
                      color: colorScheme.onSurface.withOpacity(0.5),
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

            // Position (plain text)
            if (roles.isNotEmpty)
              Text(
                roles.map(_positionLabel).join(' · '),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
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
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    profile.email,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
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

class _MembersTabContent extends StatefulWidget {
  final String companyId;

  const _MembersTabContent({required this.companyId});

  @override
  State<_MembersTabContent> createState() => _MembersTabContentState();
}

class _MembersTabContentState extends State<_MembersTabContent> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<ProfileEntity> _allMembers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMembers() async {
    final usecase = sl<GetCompanyMembersUseCase>();
    final result = await usecase(widget.companyId);
    result.fold(
      (_) => setState(() => _loading = false),
      (members) {
        if (mounted) {
          setState(() {
            _allMembers = members;
            _loading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _allMembers.where((m) {
      final fullName = '${m.name} ${m.lastname}'.toLowerCase();
      return fullName.contains(_searchQuery) ||
          m.email.toLowerCase().contains(_searchQuery);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Search Field
          TextField(
            controller: _searchController,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Search member...',
              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
              prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.5)),
              filled: true,
              fillColor: colorScheme.secondary.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No members found',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final member = filtered[index];
                      final initials =
                          '${member.name.isNotEmpty ? member.name[0] : ''}${member.lastname.isNotEmpty ? member.lastname[0] : ''}'
                              .toUpperCase();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: colorScheme.primary.withOpacity(0.1),
                            backgroundImage: member.avatarUrl != null &&
                                    member.avatarUrl!.isNotEmpty
                                ? NetworkImage(member.avatarUrl!)
                                : null,
                            child: member.avatarUrl == null ||
                                    member.avatarUrl!.isEmpty
                                ? Text(
                                    initials,
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            '${member.name} ${member.lastname}',
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            member.email,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: colorScheme.onSurface.withOpacity(0.4),
                          ),
                          onTap: () =>
                              _showMemberDetail(context, member, colorScheme, textTheme),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showMemberDetail(
    BuildContext context,
    ProfileEntity member,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: _MemberDetailSheet(member: member),
        );
      },
    );
  }
}

class _MemberDetailSheet extends StatefulWidget {
  final ProfileEntity member;

  const _MemberDetailSheet({required this.member});

  @override
  State<_MemberDetailSheet> createState() => _MemberDetailSheetState();
}

class _MemberDetailSheetState extends State<_MemberDetailSheet> {
  late AnalyticsBloc _analyticsBloc;

  @override
  void initState() {
    super.initState();
    _analyticsBloc = sl<AnalyticsBloc>();
    _analyticsBloc.add(FetchUserViewHistoryRequested(userId: widget.member.id));
  }

  @override
  void dispose() {
    _analyticsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final initials =
        '${widget.member.name.isNotEmpty ? widget.member.name[0] : ''}${widget.member.lastname.isNotEmpty ? widget.member.lastname[0] : ''}'
            .toUpperCase();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Header handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // User Card Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  backgroundImage: widget.member.avatarUrl != null &&
                          widget.member.avatarUrl!.isNotEmpty
                      ? NetworkImage(widget.member.avatarUrl!)
                      : null,
                  child: widget.member.avatarUrl == null ||
                          widget.member.avatarUrl!.isEmpty
                      ? Text(
                          initials,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.member.name} ${widget.member.lastname}',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        widget.member.email,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
            indicatorColor: colorScheme.primary,
            tabs: const [
              Tab(text: 'Announcements'),
              Tab(text: 'Events'),
            ],
          ),

          Expanded(
            child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
              bloc: _analyticsBloc,
              builder: (context, state) {
                if (state is AnalyticsUserHistoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AnalyticsUserHistoryError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  );
                } else if (state is AnalyticsUserHistoryLoaded) {
                  return TabBarView(
                    children: [
                      _buildAnnouncementsTab(
                        state.announcementViews,
                        colorScheme,
                        textTheme,
                      ),
                      _buildEventsTab(
                        state.eventViews,
                        colorScheme,
                        textTheme,
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsTab(
    List<UserAnnouncementViewEntity> views,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final child = views.isEmpty
        ? SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: 300,
              alignment: Alignment.center,
              child: Text(
                'No announcements viewed yet.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: views.length,
            itemBuilder: (context, index) {
              final view = views[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      view.announcementTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      view.announcementContent,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              size: 14,
                              color: colorScheme.onSurface.withOpacity(0.4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Viewed',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formatDateTime(view.viewedAt),
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.55),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );

    return RefreshIndicator(
      onRefresh: () async {
        _analyticsBloc.add(FetchUserViewHistoryRequested(
          userId: widget.member.id,
          forceRefresh: true,
        ));
        await _analyticsBloc.stream.firstWhere(
          (state) => state is! AnalyticsUserHistoryLoading,
        );
      },
      child: child,
    );
  }

  Widget _buildEventsTab(
    List<UserEventViewEntity> views,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final child = views.isEmpty
        ? SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: 300,
              alignment: Alignment.center,
              child: Text(
                'No events viewed yet.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: views.length,
            itemBuilder: (context, index) {
              final view = views[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      view.eventTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      view.eventDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 14,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Scheduled: ${_formatEventDate(view.eventDate)}',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.55),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (view.eventLocation != null && view.eventLocation!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              view.eventLocation!,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.55),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Divider(color: colorScheme.outline.withOpacity(0.1)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              size: 14,
                              color: colorScheme.onSurface.withOpacity(0.4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Viewed',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formatDateTime(view.viewedAt),
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.55),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );

    return RefreshIndicator(
      onRefresh: () async {
        _analyticsBloc.add(FetchUserViewHistoryRequested(
          userId: widget.member.id,
          forceRefresh: true,
        ));
        await _analyticsBloc.stream.firstWhere(
          (state) => state is! AnalyticsUserHistoryLoading,
        );
      },
      child: child,
    );
  }

  String _formatDateTime(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final period = date.hour >= 12 ? 'PM' : 'AM';
      final minute = date.minute.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final monthStr = months[date.month - 1];

      return '$monthStr $day, $hour:$minute $period';
    } catch (_) {
      return isoDate;
    }
  }

  String _formatEventDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      return '$day/$month/${date.year}';
    } catch (_) {
      return isoDate;
    }
  }
}
