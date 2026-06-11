import 'package:app_mobile/features/chat/domain/entities/message_entity.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMine;

  /// Sender display name, shown above the body for incoming group messages
  /// (WhatsApp style). Null hides the line (DMs / my own / mid-run messages).
  final String? senderName;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.senderName,
  });

  bool get _isDeleted => message.status == 'DELETED' || !message.isVisible;
  bool get _isEdited => message.isEdited || message.status == 'EDITED';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isDeleted) {
      return Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.block,
                size: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.45),
              ),
              const SizedBox(width: 6),
              Text(
                'This message was deleted',
                style: textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bg = isMine
        ? colorScheme.primary
        : colorScheme.secondary.withValues(alpha: 0.25);
    final fg = isMine ? colorScheme.onPrimary : colorScheme.onSurface;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMine ? 14 : 2),
            bottomRight: Radius.circular(isMine ? 2 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMine &&
                senderName != null &&
                senderName!.isNotEmpty) ...[
              Text(
                senderName!,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
            ],
            Text(
              message.body,
              style: textTheme.bodyMedium?.copyWith(color: fg),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _time(message.sentAt),
                  style: textTheme.labelSmall?.copyWith(
                    color: fg.withValues(alpha: 0.6),
                  ),
                ),
                if (_isEdited) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(edited)',
                    style: textTheme.labelSmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: fg.withValues(alpha: 0.6),
                    ),
                  ),
                ],
                if (message.isPending) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.schedule,
                    size: 12,
                    color: fg.withValues(alpha: 0.6),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _time(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
