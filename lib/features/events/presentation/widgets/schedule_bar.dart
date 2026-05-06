import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ScheduleBar extends StatelessWidget {
  const ScheduleBar({super.key});

  @override
  Widget build(BuildContext context) {
    // For demonstration, these are hardcoded. You can dynamically generate this list.
    final days = ["MON", "TUE", "WED", "THU", "FRI"];
    final dates = ["12", "13", "14", "15", "16"];

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        padding: const EdgeInsets.only(left: 24),
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return Container(
            width: 40,
            margin: const EdgeInsets.only(right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.tertiary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Text(
                    dates[index],
                    style: const TextStyle(
                      color: AppColors.neutral,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  days[index],
                  style: const TextStyle(
                    color: AppColors.tertiary,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
