import 'dart:math' as math;

import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/core/utils/date_format.dart';
import 'package:app_mobile/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:app_mobile/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:app_mobile/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:app_mobile/features/announcements/domain/entities/announcement_entity.dart';
import 'package:app_mobile/features/announcements/domain/entities/comment_entity.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/announcement_bloc.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/announcement_event.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/announcement_state.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/comment_bloc.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/comment_event.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/comment_state.dart';
import 'package:app_mobile/features/announcements/presentation/widgets/priority_dot.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_company_members_usecase.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AnnouncementPage extends StatefulWidget {
  final AnnouncementEntity announcement;

  const AnnouncementPage({super.key, required this.announcement});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final _commentController = TextEditingController();
  late AnalyticsBloc _analyticsBloc;
  List<ProfileEntity> _companyMembers = [];

  // Fresh server copy fetched on open; falls back to route-passed data.
  AnnouncementEntity? _detail;
  AnnouncementEntity get _current => _detail ?? widget.announcement;

  @override
  void initState() {
    super.initState();
    _analyticsBloc = sl<AnalyticsBloc>();

    context.read<CommentBloc>().add(FetchComments(widget.announcement.id));
    context
        .read<AnnouncementBloc>()
        .add(FetchAnnouncementById(widget.announcement.id));

    final profileState = context.read<ProfileBloc>().state;
    final actualUserId = profileState.profileOrNull?.userId;

    if (actualUserId != null && actualUserId.isNotEmpty) {
      _analyticsBloc.add(RegisterAnnouncementView(
        announcementId: widget.announcement.id,
        userId: actualUserId,
      ));
    }

    final isManagerOrAdmin = context
            .read<ProfileBloc>()
            .state
            .profileOrNull
            ?.isManagerOrAdmin ??
        false;
    if (isManagerOrAdmin) {
      _fetchMembers();
      _analyticsBloc.add(FetchStatsAndViewersRequested(
        contentId: widget.announcement.id,
        isEvent: false,
      ));
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _analyticsBloc.close();
    super.dispose();
  }

  void _fetchMembers() async {
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

  ({String? userId, List<String> roles}) _currentUser(BuildContext context) {
    // NOTE: announcements/comments store profile.id under "author"/"createdBy"
    // fields, so this deliberately exposes profile.id as userId.
    final profile = context.read<ProfileBloc>().state.profileOrNull;
    return (userId: profile?.id, roles: profile?.roles ?? const <String>[]);
  }

  bool _canManage(BuildContext context) {
    final user = _currentUser(context);
    final isOwner =
        user.userId != null && user.userId == _current.createdBy;
    final isAdmin = user.roles.contains('ROLE_ADMIN');
    return isOwner || isAdmin;
  }

  bool _canDeleteComment(BuildContext context, CommentEntity comment) {
    final user = _currentUser(context);
    final isAuthor = user.userId != null && user.userId == comment.authorId;
    final isAdmin = user.roles.contains('ROLE_ADMIN');
    return isAuthor || isAdmin;
  }

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        context.push('/files/create-announcement', extra: _current);
        break;
      case 'delete':
        _confirmDelete(context);
        break;
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final bloc = context.read<AnnouncementBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: const Text(
          'Are you sure you want to delete this announcement? This action cannot be undone.',
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
      bloc.add(DeleteAnnouncementRequested(widget.announcement.id));
    }
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final user = _currentUser(context);
    final authorId = user.userId;
    // The send button is disabled until the profile loads, but guard anyway
    // so a comment is never attributed to a phantom author.
    if (authorId == null) return;
    context.read<CommentBloc>().add(
          CreateCommentRequested(
            announcementId: widget.announcement.id,
            content: text,
            authorId: authorId,
          ),
        );
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> _confirmDeleteComment(
    BuildContext context,
    CommentEntity comment,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    final bloc = context.read<CommentBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
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
      bloc.add(
        DeleteCommentRequested(
          commentId: comment.id,
          announcementId: widget.announcement.id,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final announcement = _current;
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
                  _buildDetailsView(announcement, colorScheme, textTheme),
                  _buildAnalyticsView(colorScheme, textTheme),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      pageBody = _buildDetailsView(announcement, colorScheme, textTheme);
    }

    return BlocListener<AnnouncementBloc, AnnouncementState>(
      listener: (context, state) {
        if (state is AnnouncementDetailLoaded) {
          setState(() => _detail = state.announcement);
        } else if (state is AnnouncementDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Announcement deleted')),
          );
          context.pop();
        } else if (state is AnnouncementError) {
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
            'Announcement',
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
    AnnouncementEntity announcement,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<CommentBloc>().add(
            FetchComments(widget.announcement.id, forceRefresh: true));
        context
            .read<AnnouncementBloc>()
            .add(FetchAnnouncementById(widget.announcement.id));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 12),
                  child: PriorityDot(
                    priority: announcement.priority,
                    size: 14,
                  ),
                ),
                Expanded(
                  child: Text(
                    announcement.title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppDateFormat.relativeDate(announcement.createdAt),
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha:0.5),
              ),
            ),
            const SizedBox(height: 12),
            _buildAuthorRow(announcement.createdBy, colorScheme, textTheme),
            if (announcement.image != null &&
                announcement.image!.isNotEmpty) ...[
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  announcement.image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    width: double.infinity,
                    color: colorScheme.secondary.withValues(alpha:0.1),
                    child: Icon(
                      Icons.image_not_supported,
                      color: colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              announcement.description,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha:0.85),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            Divider(color: colorScheme.secondary.withValues(alpha:0.3)),
            const SizedBox(height: 16),
            Text(
              'Comments',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildCommentInput(colorScheme),
            const SizedBox(height: 16),
            _buildCommentList(colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            style: TextStyle(color: colorScheme.onSurface),
            minLines: 1,
            maxLines: 4,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _submitComment(),
            decoration: InputDecoration(
              hintText: 'Add a comment...',
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withValues(alpha:0.4),
              ),
              filled: true,
              fillColor: colorScheme.secondary.withValues(alpha:0.1),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        BlocBuilder<CommentBloc, CommentState>(
          builder: (context, state) {
            final isBusy = state is CommentActionInProgress;
            // Disabled until the profile loads so comments always carry a
            // real author id (watch: re-enables as soon as it arrives).
            final hasAuthor =
                context.watch<ProfileBloc>().state.profileOrNull != null;
            return IconButton(
              onPressed: isBusy || !hasAuthor ? null : _submitComment,
              icon: Icon(Icons.send, color: colorScheme.primary),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommentList(ColorScheme colorScheme, TextTheme textTheme) {
    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        if (state is CommentLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is CommentError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              state.message,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
            ),
          );
        }

        final comments = state is CommentLoaded
            ? state.comments
            : state is CommentActionInProgress
                ? state.comments
                : <CommentEntity>[];

        if (comments.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No comments yet. Be the first to comment.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha:0.5),
              ),
            ),
          );
        }

        return Column(
          children: comments
              .map((c) => _buildCommentTile(c, colorScheme, textTheme))
              .toList(),
        );
      },
    );
  }

  Widget _buildCommentTile(
    CommentEntity comment,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final matchedMember = _companyMembers.byProfileId(comment.authorId);
    final initials = matchedMember.initials;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colorScheme.secondary.withValues(alpha:0.3),
            backgroundImage: matchedMember.avatarUrl != null && matchedMember.avatarUrl!.isNotEmpty
                ? NetworkImage(matchedMember.avatarUrl!)
                : null,
            child: matchedMember.avatarUrl == null || matchedMember.avatarUrl!.isEmpty
                ? Text(
                    initials,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${matchedMember.name} ${matchedMember.lastname}',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      AppDateFormat.relativeDate(comment.createdAt),
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha:0.55),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.content,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (_canDeleteComment(context, comment))
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: 18,
                color: colorScheme.onSurface.withValues(alpha:0.5),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              onSelected: (value) {
                if (value == 'delete') {
                  _confirmDeleteComment(context, comment);
                }
              },
              itemBuilder: (context) => [
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
    );
  }

  Widget _buildAuthorRow(String authorId, ColorScheme colorScheme, TextTheme textTheme) {
    final matchedMember = _companyMembers.byProfileId(authorId);
    final initials = matchedMember.initials;

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: colorScheme.primary.withValues(alpha:0.1),
          backgroundImage: matchedMember.avatarUrl != null && matchedMember.avatarUrl!.isNotEmpty
              ? NetworkImage(matchedMember.avatarUrl!)
              : null,
          child: matchedMember.avatarUrl == null || matchedMember.avatarUrl!.isEmpty
              ? Text(
                  initials,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Text(
          'By ${matchedMember.name} ${matchedMember.lastname}',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface.withValues(alpha:0.9),
          ),
        ),
      ],
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
                contentId: widget.announcement.id,
                isEvent: false,
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
                contentId: widget.announcement.id,
                isEvent: false,
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

}

class PercentagePainter extends CustomPainter {
  final double percentage;
  final Color primaryColor;
  final Color backgroundColor;

  PercentagePainter({
    required this.percentage,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 10.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final activePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    final sweepAngle = 2 * math.pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant PercentagePainter oldDelegate) =>
      oldDelegate.percentage != percentage ||
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.backgroundColor != backgroundColor;
}
