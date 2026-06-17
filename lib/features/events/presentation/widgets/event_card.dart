import 'package:app_mobile/core/utils/date_format.dart';
import 'package:app_mobile/features/events/domain/entities/event_entity.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_bloc.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_event.dart';
import 'package:app_mobile/features/events/presentation/widgets/avatar_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventCard extends StatelessWidget {
  final EventEntity item;

  /// The signed-in user's *user* id, used to find this user's own invitation
  /// status within the event's recipients.
  final String? currentUserId;

  const EventCard({super.key, required this.item, this.currentUserId});

  @override
  Widget build(BuildContext context) {
    // Only an invitee still awaiting a response sees the inline controls. The
    // creator and anyone who already responded have a null/non-pending status.
    final isPending = item.statusFor(currentUserId) == RecipientStatus.pending;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(vertical: 17),
      margin: const EdgeInsets.only(bottom: 11, left: 25, right: 25),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title and Attendees
          Container(
            margin: const EdgeInsets.only(bottom: 9, left: 18, right: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (item.recipientIds.isNotEmpty)
                  AvatarGroup(uuids: item.recipientIds),
              ],
            ),
          ),

          // Button Label and Description
          Container(
            margin: const EdgeInsets.only(bottom: 45, left: 18, right: 30),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Button',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    item.description,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Footer: Time
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 25),
            width: double.infinity,
            child: Row(
              children: [
                Icon(Icons.access_time, size: 20, color: Theme.of(context).colorScheme.tertiary),
                const SizedBox(width: 8),
                Text(
                  AppDateFormat.relativeDateTime(item.date),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Inline invitation actions (only while awaiting a response).
          if (isPending) ...[
            const SizedBox(height: 14),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              child: _InvitationActions(eventId: item.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _InvitationActions extends StatelessWidget {
  final String eventId;

  const _InvitationActions({required this.eventId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () =>
                context.read<EventBloc>().add(DeclineInvitation(eventId)),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('Decline'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () =>
                context.read<EventBloc>().add(AcceptInvitation(eventId)),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('Accept'),
          ),
        ),
      ],
    );
  }
}
