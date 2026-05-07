import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/event_entity.dart';
import 'avatar_group.dart';

class EventCard extends StatelessWidget {
  final EventEntity item;

  const EventCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.primary,
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
                    style: const TextStyle(
                      color: AppColors.neutral,
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
                const Text(
                  "Button",
                  style: TextStyle(
                    color: AppColors.tertiary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  child: Text(
                    item.description,
                    style: const TextStyle(
                      color: AppColors.primary,
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
                const Icon(Icons.access_time, size: 20, color: AppColors.tertiary),
                const SizedBox(width: 8),
                Text(
                  _formatDate(item.date),
                  style: const TextStyle(
                    color: AppColors.tertiary,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.location_on_outlined, size: 20, color: AppColors.tertiary),
                const SizedBox(width: 8),
                Container(
                  width: 80,
                  child: Text(
                    item.location,
                    style: const TextStyle(
                      color: AppColors.primary,
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

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final period = date.hour >= 12 ? 'PM' : 'AM';
      final minute = date.minute.toString().padLeft(2, '0');
      
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        return "Today, $hour:$minute $period";
      }
      return "${date.month}/${date.day}/${date.year}, $hour:$minute $period";
    } catch (e) {
      return isoDate;
    }
  }
}
