import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/core/utils/date_format.dart';
import 'package:app_mobile/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:app_mobile/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:app_mobile/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:app_mobile/features/announcements/presentation/pages/announcement_page.dart'; // To reuse PercentagePainter
import 'package:app_mobile/features/company/domain/usecases/get_spaces_usecase.dart';
import 'package:app_mobile/features/events/domain/entities/event_entity.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_bloc.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_event.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_state.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_company_members_usecase.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

  /// Resolved room name for the event's spaceId. Null while loading or if the
  /// room was deleted — in which case the room row is hidden.
  String? _roomName;

  // Updated copy received after an edit; falls back to route-passed data.
  EventEntity? _updated;
  EventEntity get _current => _updated ?? widget.event;

  @override
  void initState() {
    super.initState();
    _analyticsBloc = sl<AnalyticsBloc>();

    if (_current.recipientIds.isNotEmpty) {
      _fetchRecipients();
    } else {
      _recipientsLoaded = true;
    }
    _loadRoomName();
    _registerView();

    final isManagerOrAdmin = context
            .read<ProfileBloc>()
            .state
            .profileOrNull
            ?.isManagerOrAdmin ??
        false;
    if (isManagerOrAdmin) {
      _fetchCompanyMembers();
      _analyticsBloc.add(FetchStatsAndViewersRequested(
        contentId: _current.id,
        isEvent: true,
      ));
    }
  }

  @override
  void dispose() {
    _analyticsBloc.close();
    super.dispose();
  }

  Future<void> _loadRoomName() async {
    final result = await sl<GetSpacesUseCase>()();
    if (!mounted) return;
    result.fold((_) {}, (spaces) {
      final match = spaces.where((s) => s.id == _current.spaceId);
      setState(() => _roomName = match.isNotEmpty ? match.first.name : null);
    });
  }

  void _registerView() {
    final profileState = context.read<ProfileBloc>().state;
    final actualUserId = profileState.profileOrNull?.userId;
    if (actualUserId != null && actualUserId.isNotEmpty) {
      _analyticsBloc.add(RegisterEventView(
        eventId: _current.id,
        userId: actualUserId,
      ));
    }
  }

  void _fetchRecipients() {
    final profileState = context.read<ProfileBloc>().state;
    final companyId = profileState.profileOrNull?.companyId;
    if (companyId != null) {
      context.read<EventBloc>().add(FetchCompanyMembers(companyId));
    } else {
      setState(() => _recipientsLoaded = true);
    }
  }

  void _fetchCompanyMembers() async {
    final profileState = context.read<ProfileBloc>().state;
    final companyId = profileState.profileOrNull?.companyId;
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
    final profile = context.read<ProfileBloc>().state.profileOrNull;
    // Events store profile.id in createdBy (see ProfileEntity docs).
    final isOwner = profile != null && profile.id == _current.createdBy;
    final isAdmin = (profile?.roles ?? const []).contains('ROLE_ADMIN');
    return isOwner || isAdmin;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canManage = _canManage(context);

    final isManagerOrAdmin = context
            .read<ProfileBloc>()
            .state
            .profileOrNull
            ?.isManagerOrAdmin ??
        false;

    Widget pageBody;
    if (isManagerOrAdmin) {
      pageBody = DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurface.withValues(alpha:0.6),
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
                .where((m) => _current.recipientIds.contains(m.id))
                .toList();
            _recipientsLoaded = true;
          });
        } else if (state is EventUpdateSuccess &&
            state.event.id == _current.id) {
          setState(() => _updated = state.event);
          // The room may have changed on edit — re-resolve its name.
          _loadRoomName();
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
            RefreshIndicator(
              onRefresh: () async {
                context
                    .read<EventBloc>()
                    .add(const FetchEvents(forceRefresh: true));
                if (_current.recipientIds.isNotEmpty) {
                  _fetchRecipients();
                }
                final isManagerOrAdmin = context
                        .read<ProfileBloc>()
                        .state
                        .profileOrNull
                        ?.isManagerOrAdmin ??
                    false;
                if (isManagerOrAdmin) {
                  _fetchCompanyMembers();
                  _analyticsBloc.add(FetchStatsAndViewersRequested(
                    contentId: _current.id,
                    isEvent: true,
                    forceRefresh: true,
                  ));
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _current.title,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.access_time,
                      label: AppDateFormat.dateTime(_current.date),
                    ),
                    if (_roomName != null) ...[
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.meeting_room_outlined,
                        label: _roomName!,
                      ),
                    ],
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
                      _current.description.isEmpty
                          ? 'No description'
                          : _current.description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha:0.8),
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
            ),
            if (isLoading)
              Container(
                color: colorScheme.surface.withValues(alpha:0.5),
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
                contentId: _current.id,
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
                contentId: _current.id,
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
                      color: colorScheme.secondary.withValues(alpha:0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha:0.1),
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
                              backgroundColor: colorScheme.primary.withValues(alpha:0.15),
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
                                  color: colorScheme.onSurface.withValues(alpha:0.8),
                                ),
                              ),
                              Text(
                                'Pending: $pendingCount users',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha:0.55),
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
                            color: colorScheme.onSurface.withValues(alpha:0.5),
                          ),
                        ),
                      ),
                    )
                  else
                    ...viewers.map((viewer) {
                      final matchedMember = _companyMembers.cast<ProfileEntity>().firstWhere(
                        // viewer.userId is a *user* id, so match on userId,
                        // not the profile id (see ProfileEntity docs).
                        (m) => m.userId == viewer.userId,
                        orElse: () => ProfileEntity(
                          id: viewer.userId,
                          userId: viewer.userId,
                          username: viewer.userEmail,
                          name: viewer.userFullName.split(' ').first,
                          lastname: viewer.userFullName.split(' ').skip(1).join(' '),
                          email: viewer.userEmail,
                          avatarUrl: viewer.userImageUrl,
                        ),
                      );

                      final initials = matchedMember.initials;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha:0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: colorScheme.primary.withValues(alpha:0.1),
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
                                      color: colorScheme.onSurface.withValues(alpha:0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatViewedAt(viewer.viewedAt),
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha:0.4),
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
    if (_current.recipientIds.isEmpty) {
      return Text(
        'No invited people',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha:0.7),
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
        '${_current.recipientIds.length} invited',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha:0.7),
        ),
      );
    }

    return Column(
      children: _recipients.map((member) {
        final initials = member.initials;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withValues(alpha:0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.secondary.withValues(alpha:0.2),
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
                        color: colorScheme.onSurface.withValues(alpha:0.6),
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
        context.push('/files/create-event', extra: _current);
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
      bloc.add(DeleteEventRequested(_current.id));
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
        Icon(icon, size: 18, color: colorScheme.onSurface.withValues(alpha:0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha:0.8),
            ),
          ),
        ),
      ],
    );
  }
}
