import 'package:flutter/material.dart';

class ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const ProfileActionButton({super.key, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withValues(
            alpha: 0.2,
          ), // Matches 0x66EFF1F2 idea
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 26),
        child: Icon(icon, color: theme.colorScheme.onSurface),
      ),
    );
  }
}
