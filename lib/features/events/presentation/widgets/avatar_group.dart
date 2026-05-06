import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AvatarGroup extends StatelessWidget {
  final List<String> uuids;

  const AvatarGroup({super.key, required this.uuids});

  @override
  Widget build(BuildContext context) {
    // Show up to 3 avatars, plus a badge
    final displayCount = uuids.length > 3 ? 3 : uuids.length;
    final remainingCount = uuids.length - displayCount;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (remainingCount > 0)
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.surface,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(800),
              color: AppColors.secondary,
            ),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            margin: const EdgeInsets.only(right: 4),
            child: Text(
              "+$remainingCount",
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        for (var i = 0; i < displayCount; i++)
          Container(
            width: 24,
            height: 24,
            margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tertiary,
            ),
            child: const Icon(Icons.person, size: 16, color: AppColors.surface),
          ),
      ],
    );
  }
}
