import 'package:flutter/material.dart';
import '../../domain/entities/group_entity.dart';

class ChatItem extends StatelessWidget {
  final GroupEntity group;
  final bool archived;
  final VoidCallback onTap;
  final VoidCallback onToggleArchive;

  const ChatItem({
    super.key,
    required this.group,
    required this.archived,
    required this.onTap,
    required this.onToggleArchive,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      onLongPress: onToggleArchive,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.surface,
          border: Border.all(
            color: colorScheme.secondary.withValues(alpha: 0.2),
          ),
        ),
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              backgroundImage:
                  (group.imageUrl != null && group.imageUrl!.isNotEmpty)
                      ? NetworkImage(group.imageUrl!)
                      : null,
              child: (group.imageUrl == null || group.imageUrl!.isEmpty)
                  ? Icon(
                      group.isDirect ? Icons.person : Icons.groups,
                      color: colorScheme.primary,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    group.isDirect
                        ? 'Direct chat'
                        : '${group.memberCount} members · ${group.visibility.toLowerCase()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _relative(group.updatedAt),
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  archived ? Icons.unarchive_outlined : Icons.archive_outlined,
                  size: 18,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _relative(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${date.day}/${date.month}/${date.year}';
  }
}
