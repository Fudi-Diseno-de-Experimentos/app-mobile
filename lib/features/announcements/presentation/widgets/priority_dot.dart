import 'package:flutter/material.dart';

/// Single source of truth for announcement urgency styling.
///
/// Maps the API priority enum (`NORMAL` | `HIGH` | `URGENT`) to a sort rank
/// and a traffic-light color. Shared by the feed card, the home mini card and
/// the detail header so the dot stays consistent everywhere.
class PriorityStyle {
  PriorityStyle._();

  /// Lower = more urgent. Drives the feed sort order.
  static int rank(String priority) {
    switch (priority.toUpperCase()) {
      case 'URGENT':
        return 0;
      case 'HIGH':
        return 1;
      default: // NORMAL / unknown
        return 2;
    }
  }

  static Color color(BuildContext context, String priority) {
    final scheme = Theme.of(context).colorScheme;
    switch (priority.toUpperCase()) {
      case 'URGENT':
        return scheme.error; // red
      case 'HIGH':
        return Colors.orange; // amber
      default:
        return const Color(0xFF2E7D32); // calm green = normal
    }
  }
}

/// Small filled circle signalling announcement urgency at a glance.
/// Replaces the old text priority badge.
class PriorityDot extends StatelessWidget {
  final String priority;
  final double size;

  const PriorityDot({super.key, required this.priority, this.size = 12});

  @override
  Widget build(BuildContext context) {
    final color = PriorityStyle.color(context, priority);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 0.5,
          ),
        ],
      ),
    );
  }
}
