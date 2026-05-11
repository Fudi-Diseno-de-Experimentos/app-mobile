import 'package:flutter/material.dart';

class RoleChip extends StatelessWidget {
  final String role;

  const RoleChip({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _colorFor(role, colorScheme);
    final label = _labelFor(role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Color _colorFor(String role, ColorScheme scheme) {
    switch (role) {
      case 'ROLE_ADMIN':
        return Colors.red;
      case 'ROLE_MANAGER':
        return Colors.orange;
      default:
        return scheme.primary;
    }
  }

  String _labelFor(String role) {
    if (role.startsWith('ROLE_')) {
      final raw = role.substring(5).toLowerCase();
      return raw.isEmpty ? role : raw[0].toUpperCase() + raw.substring(1);
    }
    return role;
  }
}
