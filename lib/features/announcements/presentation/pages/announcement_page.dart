import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/announcement_entity.dart';

class AnnouncementPage extends StatelessWidget {
  final AnnouncementEntity announcement;

  const AnnouncementPage({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Anuncio',
          style: TextStyle(color: colorScheme.onSurface),
        ),
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
                  Expanded(
                    child: Text(
                      announcement.title,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _PriorityBadge(priority: announcement.priority),
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
            ],
          ),
        ),
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

class _PriorityBadge extends StatelessWidget {
  final String priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (priority.toUpperCase()) {
      'URGENT' => colorScheme.error,
      'HIGH' => Colors.orange,
      _ => colorScheme.primary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
