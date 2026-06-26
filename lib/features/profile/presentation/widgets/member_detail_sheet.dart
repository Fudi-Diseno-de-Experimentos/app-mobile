import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/core/utils/date_format.dart';
import 'package:app_mobile/features/analytics/domain/entities/user_announcement_view_entity.dart';
import 'package:app_mobile/features/analytics/domain/entities/user_event_view_entity.dart';
import 'package:app_mobile/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:app_mobile/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:app_mobile/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MemberDetailSheet extends StatefulWidget {
  final ProfileEntity member;

  const MemberDetailSheet({super.key, required this.member});

  @override
  State<MemberDetailSheet> createState() => _MemberDetailSheetState();
}

class _MemberDetailSheetState extends State<MemberDetailSheet> {
  late AnalyticsBloc _analyticsBloc;

  @override
  void initState() {
    super.initState();
    _analyticsBloc = sl<AnalyticsBloc>();
    _analyticsBloc.add(FetchUserViewHistoryRequested(userId: widget.member.userId));
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
              color: colorScheme.onSurface.withValues(alpha: 0.2),
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
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
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
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
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
            unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
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
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
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
                  color: colorScheme.secondary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.1),
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
                        color: colorScheme.onSurface.withValues(alpha: 0.75),
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
                              color: colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Viewed',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          AppDateFormat.monthDayTime(view.viewedAt),
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.55),
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
          userId: widget.member.userId,
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
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
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
                  color: colorScheme.secondary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.1),
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
                        color: colorScheme.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Scheduled: ${AppDateFormat.date(view.eventDate)}',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.55),
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
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              view.eventLocation!,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Divider(color: colorScheme.outline.withValues(alpha: 0.1)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              size: 14,
                              color: colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Viewed',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          AppDateFormat.monthDayTime(view.viewedAt),
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.55),
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
          userId: widget.member.userId,
          forceRefresh: true,
        ));
        await _analyticsBloc.stream.firstWhere(
          (state) => state is! AnalyticsUserHistoryLoading,
        );
      },
      child: child,
    );
  }
}
