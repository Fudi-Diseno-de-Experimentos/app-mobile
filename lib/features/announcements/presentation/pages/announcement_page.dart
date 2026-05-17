import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di.dart';
import '../../../analytics/presentation/bloc/analytics_bloc.dart';
import '../../../analytics/presentation/bloc/analytics_event.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../bloc/announcement_bloc.dart';
import '../bloc/announcement_event.dart';
import '../bloc/announcement_state.dart';
import '../bloc/comment_bloc.dart';
import '../bloc/comment_event.dart';
import '../bloc/comment_state.dart';
import '../widgets/priority_dot.dart';

class AnnouncementPage extends StatefulWidget {
  final AnnouncementEntity announcement;

  const AnnouncementPage({super.key, required this.announcement});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final _commentController = TextEditingController();

  // Fresh server copy fetched on open; falls back to route-passed data.
  AnnouncementEntity? _detail;
  AnnouncementEntity get _current => _detail ?? widget.announcement;

  @override
  void initState() {
    super.initState();
    context.read<CommentBloc>().add(FetchComments(widget.announcement.id));
    context
        .read<AnnouncementBloc>()
        .add(FetchAnnouncementById(widget.announcement.id));

    final actorId = _currentUser(context).userId;
    if (actorId != null && actorId.isNotEmpty) {
      sl<AnalyticsBloc>().add(RegisterAnnouncementView(
        announcementId: widget.announcement.id,
        userId: actorId,
      ));
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  ({String? userId, List<String> roles}) _currentUser(BuildContext context) {
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      return (
        userId: profileState.profile.id,
        roles: profileState.profile.roles ?? const [],
      );
    } else if (profileState is ProfileUpdateSuccess) {
      return (
        userId: profileState.profile.id,
        roles: profileState.profile.roles ?? const [],
      );
    }
    return (userId: null, roles: const <String>[]);
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
        context.push('/files/create-announcement', extra: widget.announcement);
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
    final authorId = user.userId ?? '00000000-0000-0000-0000-000000000000';
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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Priority + title row
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
                  _formatRelativeDate(announcement.createdAt),
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),

                // Image
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
                        color: colorScheme.secondary.withValues(alpha: 0.1),
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
                    color: colorScheme.onSurface.withValues(alpha: 0.85),
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 32),
                Divider(color: colorScheme.secondary.withValues(alpha: 0.3)),
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
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              filled: true,
              fillColor: colorScheme.secondary.withValues(alpha: 0.1),
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
            return IconButton(
              onPressed: isBusy ? null : _submitComment,
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
                color: colorScheme.onSurface.withValues(alpha: 0.5),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colorScheme.secondary.withValues(alpha: 0.3),
            child: Icon(
              Icons.person,
              size: 18,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.content,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatRelativeDate(comment.createdAt),
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
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
                color: colorScheme.onSurface.withValues(alpha: 0.5),
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

  String _formatRelativeDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0 && now.day == date.day) return 'Hoy';
      if (diff.inDays <= 1) return 'Ayer';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return isoDate;
    }
  }
}

