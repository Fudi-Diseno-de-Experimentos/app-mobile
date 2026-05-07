import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BottomAvatarList extends StatelessWidget {
  final List<String> uuids;

  const BottomAvatarList({super.key, required this.uuids});

  @override
  Widget build(BuildContext context) {
    if (uuids.isEmpty) return const SizedBox.shrink();
    
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(left: 29, top: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: uuids.map((uuid) {
                return AvatarPlaceholder(uuid: uuid);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class AvatarPlaceholder extends StatelessWidget {
  final String uuid;

  const AvatarPlaceholder({super.key, required this.uuid});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: Container(
          color: AppColors.background.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 20),
          margin: const EdgeInsets.only(right: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary,
                ),
                child: const Icon(
                  Icons.person,
                  size: 20,
                  color: AppColors.surface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
