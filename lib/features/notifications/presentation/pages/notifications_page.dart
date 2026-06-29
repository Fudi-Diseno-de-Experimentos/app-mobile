import 'package:app_mobile/core/utils/date_format.dart';
import 'package:app_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:app_mobile/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:app_mobile/features/notifications/presentation/bloc/notification_event.dart';
import 'package:app_mobile/features/notifications/presentation/bloc/notification_state.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileBloc>().state.profileOrNull;
    if (profile != null) {
      context.read<NotificationBloc>().add(FetchNotificationsList(profile.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is NotificationsLoaded) {
            final list = state.notifications;
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_outlined,
                      size: 72,
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'All caught up!',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No new notifications at this time.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                final profile = context.read<ProfileBloc>().state.profileOrNull;
                if (profile != null) {
                  context.read<NotificationBloc>().add(
                        FetchNotificationsList(profile.userId),
                      );
                }
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: list.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 72,
                  endIndent: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.08),
                ),
                itemBuilder: (context, index) {
                  final notification = list[index];
                  return _NotificationItem(notification: notification);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationEntity notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isUnread = !notification.isRead;
    final category = _getCategory(notification.title);
    final iconData = _getIconData(category);
    final iconColor = _getIconColor(category, colorScheme);

    return InkWell(
      onTap: () {
        if (isUnread) {
          context.read<NotificationBloc>().add(MarkNotificationRead(notification.id));
        }
      },
      child: Container(
        color: isUnread
            ? colorScheme.primary.withValues(alpha: 0.03)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon with Circle Background
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(notification.createdAt),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: textTheme.bodySmall?.copyWith(
                      color: isUnread
                          ? colorScheme.onSurface.withValues(alpha: 0.8)
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: 12),
              // Blue Dot for unread
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getCategory(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('message') || lowerTitle.contains('group')) {
      return 'chat';
    }
    if (lowerTitle.contains('event')) {
      return 'event';
    }
    if (lowerTitle.contains('announcement') || lowerTitle.contains('anuncio')) {
      return 'announcement';
    }
    return 'default';
  }

  IconData _getIconData(String category) {
    switch (category) {
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'event':
        return Icons.event_outlined;
      case 'announcement':
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  Color _getIconColor(String category, ColorScheme colorScheme) {
    switch (category) {
      case 'chat':
        return Colors.blue;
      case 'event':
        return Colors.green;
      case 'announcement':
        return Colors.orange;
      default:
        return colorScheme.primary;
    }
  }

  String _formatDate(DateTime dateTime) {
    try {
      final isoStr = dateTime.toIso8601String();
      return AppDateFormat.relativeDateTime(isoStr);
    } catch (_) {
      return '';
    }
  }
}
