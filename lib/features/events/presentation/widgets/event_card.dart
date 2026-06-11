import 'package:app_mobile/core/utils/date_format.dart';
import 'package:app_mobile/features/events/domain/entities/event_entity.dart';
import 'package:app_mobile/features/events/presentation/widgets/avatar_group.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final EventEntity item;

  const EventCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
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
          
          // Footer: Time and Location
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
                const Spacer(),
                Icon(Icons.location_on_outlined, size: 20, color: Theme.of(context).colorScheme.tertiary),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: Text(
                    item.location,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
