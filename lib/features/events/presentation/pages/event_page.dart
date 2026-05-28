import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di.dart';
import '../../../analytics/presentation/bloc/analytics_bloc.dart';
import '../../../analytics/presentation/bloc/analytics_event.dart';
import '../../../analytics/presentation/bloc/analytics_state.dart';
import '../../domain/entities/event_entity.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../profile/domain/usecases/get_company_members_usecase.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';
import '../../../announcements/presentation/pages/announcement_page.dart'; // To reuse PercentagePainter

class EventPage extends StatefulWidget {
  final EventEntity event;

  const EventPage({super.key, required this.event});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  List<ProfileEntity> _recipients = [];
  bool _recipientsLoaded = false;
  late AnalyticsBloc _analyticsBloc;
  List<ProfileEntity> _companyMembers = [];

  @override
  void initState() {
    super.initState();
    _analyticsBloc = sl<AnalyticsBloc>();

    if (widget.event.recipientIds.isNotEmpty) {
      _fetchRecipients();
    } else {
      _recipientsLoaded = true;
    }
    _registerView();

    final roles = _currentUserRoles();
    final isManagerOrAdmin = roles.contains('ROLE_ADMIN') || roles.contains('ROLE_MANAGER');
    if (isManagerOrAdmin) {
      _fetchCompanyMembers();
      _analyticsBloc.add(FetchStatsAndViewersRequested(
        contentId: widget.event.id,
        isEvent: true,
      ));
    }
  }

  @override
  void dispose() {
    _analyticsBloc.close();
    super.dispose();
  }

  List<String> _currentUserRoles() {
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      return profileState.profile.roles ?? const [];
    } else if (profileState is ProfileUpdateSuccess) {
      return profileState.profile.roles ?? const [];
    }
    return const [];
  }

  void _registerView() {
    final profileState = context.read<ProfileBloc>().state;
    String? actorId;
    if (profileState is ProfileLoaded) {
      actorId = profileState.profile.id;
    } else if (profileState is ProfileUpdateSuccess) {
      actorId = profileState.profile.id;
    }
    if (actorId != null && actorId.isNotEmpty) {
      _analyticsBloc.add(RegisterEventView(
        eventId: widget.event.id,
        userId: actorId,
      ));
    }
  }

  void _fetchRecipients() {
    final profileState = context.read<ProfileBloc>().state;
    String? companyId;
    if (profileState is ProfileLoaded) {
      companyId = profileState.profile.companyId;
    } else if (profileState is ProfileUpdateSuccess) {
      companyId = profileState.profile.companyId;
    }
    if (companyId != null) {
      context.read<EventBloc>().add(FetchCompanyMembers(companyId));
    } else {
      setState(() => _recipientsLoaded = true);
    }
  }

  void _fetchCompanyMembers() async {
    final profileState = context.read<ProfileBloc>().state;
    String? companyId;
    if (profileState is ProfileLoaded) {
      companyId = profileState.profile.companyId;
    } else if (profileState is ProfileUpdateSuccess) {
      companyId = profileState.profile.companyId;
    }
    if (companyId != null) {
      final usecase = sl<GetCompanyMembersUseCase>();
      final result = await usecase(companyId);
      result.fold(
        (_) {},
        (members) {
          if (mounted) {
            setState(() {
              _companyMembers = members;
            });
          }
        },
      );
    }
  }

  bool _canManage(BuildContext context) {
    final profileState = context.read<ProfileBloc>().state;
    String? userId;
    List<String> roles = const [];
    if (profileState is ProfileLoaded) {
      userId = profileState.profile.id;
      roles = profileState.profile.roles ?? const [];
    } else if (profileState is ProfileUpdateSuccess) {
      userId = profileState.profile.id;
      roles = profileState.profile.roles ?? const [];
    }
    final isOwner = userId != null && userId == widget.event.createdBy;
    final isAdmin = roles.contains('ROLE_ADMIN');
    return isOwner || isAdmin;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canManage = _canManage(context);

    final roles = _currentUserRoles();
    final isManagerOrAdmin = roles.contains('ROLE_ADMIN') || roles.contains('ROLE_MANAGER');

    Widget pageBody;
    if (isManagerOrAdmin) {
      pageBody = DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
              indicatorColor: colorScheme.primary,
              tabs: const [
                Tab(text: 'Details'),
                Tab(text: 'Analytics'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildDetailsView(colorScheme, textTheme, canManage),
                  _buildAnalyticsView(colorScheme, textTheme),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      pageBody = _buildDetailsView(colorScheme, textTheme, canManage);
    }

    return BlocListener<EventBloc, EventState>(
      listener: (context, state) {
        if (state is EventMembersLoaded) {
          setState(() {
            _recipients = state.members
                .where((m) => widget.event.recipientIds.contains(m.id))
                .toList();
            _recipientsLoaded = true;
          });
        } else if (state is EventDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event deleted')),
          );
          context.pop();
        } else if (state is EventError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Event Details',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          actions: [
            if (canManage)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
                onSelected: (value) => _onMenuSelected(context, value),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 20, color: colorScheme.onSurface),
                        const SizedBox(width: 12),
                        const Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            size: 20, color: colorScheme.error),
                        const SizedBox(width: 12),
                        Text(
                          'Delete',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: SafeArea(child: pageBody),
      ),
    );
  }

  Widget _buildDetailsView(
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool canManage,
  ) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        final isLoading = state is EventLoading;
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.access_time,
                    label: _formatDate(widget.event.date),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: widget.event.location.isEmpty
                        ? 'No location'
                        : widget.event.location,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.description.isEmpty
                        ? 'No description'
                        : widget.event.description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Invited',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInvitedSection(colorScheme, textTheme),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: colorScheme.surface.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsView(ColorScheme colorScheme, TextTheme textTheme) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      bloc: _analyticsBloc,
      builder: (context, state) {
        if (state is AnalyticsStatsAndViewersLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AnalyticsStatsAndViewersError) {
          return RefreshIndicator(
            onRefresh: () async {
              _analyticsBloc.add(FetchStatsAndViewersRequested(
                contentId: widget.event.id,
                isEvent: true,
                forceRefresh: true,
              ));
              await _analyticsBloc.stream.firstWhere((state) => state is! AnalyticsStatsAndViewersLoading);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                height: 300,
                child: Center(
                  child: Text(
                    state.message,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
              ),
            ),
          );
        } else if (state is AnalyticsStatsAndViewersLoaded) {
          final stats = state.stats;
          final viewers = state.viewers;

          final pendingCount = (stats.totalUsers - viewers.length).clamp(0, stats.totalUsers);

          return RefreshIndicator(
            onRefresh: () async {
              _analyticsBloc.add(FetchStatsAndViewersRequested(
                contentId: widget.event.id,
                isEvent: true,
                forceRefresh: true,
              ));
              await _analyticsBloc.stream.firstWhere((state) => state is! AnalyticsStatsAndViewersLoading);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Premium Percentage Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Native circular progress percentage
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: CustomPaint(
                            painter: PercentagePainter(
                              percentage: stats.viewPercentage,
                              primaryColor: colorScheme.primary,
                              backgroundColor: colorScheme.primary.withOpacity(0.15),
                            ),
                            child: Center(
                              child: Text(
                                '${stats.viewPercentage.toStringAsFixed(0)}%',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Visualizations',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Viewed: ${viewers.length} / ${stats.totalUsers} users',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                'Pending: $pendingCount users',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.55),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Viewers List',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (viewers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No readers logged yet.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                    )
                  else
                    ...viewers.map((viewer) {
                      final matchedMember = _companyMembers.cast<ProfileEntity>().firstWhere(
                        (m) => m.id == viewer.userId,
                        orElse: () => ProfileEntity(
                          id: viewer.userId,
                          userId: viewer.userId,
                          username: viewer.userEmail,
                          name: viewer.userFullName.split(' ').first,
                          lastname: viewer.userFullName.split(' ').skip(1).join(' '),
                          email: viewer.userEmail,
                        ),
                      );

                      final initials = '${matchedMember.name.isNotEmpty ? matchedMember.name[0] : ''}${matchedMember.lastname.isNotEmpty ? matchedMember.lastname[0] : ''}'
                          .toUpperCase();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: colorScheme.primary.withOpacity(0.1),
                              backgroundImage: matchedMember.avatarUrl != null && matchedMember.avatarUrl!.isNotEmpty
                                  ? NetworkImage(matchedMember.avatarUrl!)
                                  : null,
                              child: matchedMember.avatarUrl == null || matchedMember.avatarUrl!.isEmpty
                                  ? Text(
                                      initials,
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontSize: 13,
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
                                    viewer.userFullName,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    viewer.userEmail,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatViewedAt(viewer.viewedAt),
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  String _formatViewedAt(String isoDate) {
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

  Widget _buildInvitedSection(ColorScheme colorScheme, TextTheme textTheme) {
    if (widget.event.recipientIds.isEmpty) {
      return Text(
        'No invited people',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
      );
    }

    if (!_recipientsLoaded) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(color: colorScheme.onSurface),
        ),
      );
    }

    if (_recipients.isEmpty) {
      return Text(
        '${widget.event.recipientIds.length} invited',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
      );
    }

    return Column(
      children: _recipients.map((member) {
        final initials =
            '${member.name.isNotEmpty ? member.name[0] : ''}${member.lastname.isNotEmpty ? member.lastname[0] : ''}'
                .toUpperCase();
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.secondary.withOpacity(0.2),
                backgroundImage: member.avatarUrl != null &&
                        member.avatarUrl!.isNotEmpty
                    ? NetworkImage(member.avatarUrl!)
                    : null,
                child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                    ? Text(
                        initials,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${member.name} ${member.lastname}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      member.email,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        context.push('/files/create-event', extra: widget.event);
        break;
      case 'delete':
        _confirmDelete(context);
        break;
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final bloc = context.read<EventBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text(
          'Are you sure you want to delete this event? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      bloc.add(DeleteEventRequested(widget.event.id));
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final hour = date.hour > 12
          ? date.hour - 12
          : (date.hour == 0 ? 12 : date.hour);
      final period = date.hour >= 12 ? 'PM' : 'AM';
      final minute = date.minute.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      return '$day/$month/${date.year}, $hour:$minute $period';
    } catch (_) {
      return isoDate;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurface.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}
