import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/announcement_entity.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementEntity item;

  const AnnouncementCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: AppColors.secondary.withOpacity(0.5),
        ),
        padding: const EdgeInsets.only(top: 18, bottom: 18, right: 16),
        margin: const EdgeInsets.only(bottom: 21, left: 29, right: 29),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16, left: 17),
              child: Text(
                item.title,
                style: const TextStyle(
                  color: AppColors.neutral,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 16, left: 17),
              width: double.infinity,
              child: Text(
                item.description,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                ),
              ),
            ),
            if (item.image != null && item.image!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 10, left: 16),
                height: 125,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    item.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.secondary,
                      child: const Icon(Icons.image_not_supported, color: AppColors.tertiary),
                    ),
                  ),
                ),
              ),
            Container(
              margin: const EdgeInsets.only(left: 17),
              child: Text(
                _formatRelativeDate(item.createdAt),
                style: const TextStyle(
                  color: AppColors.tertiary,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRelativeDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0 && now.day == date.day) {
        return "Today";
      } else if (difference.inDays == 1 || (difference.inDays == 0 && now.day != date.day)) {
        return "Yesterday";
      } else {
        return "${date.month}/${date.day}/${date.year}";
      }
    } catch (e) {
      return isoDate;
    }
  }
}
