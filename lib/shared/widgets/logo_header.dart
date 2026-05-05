import 'package:flutter/material.dart';

class LogoHeader extends StatelessWidget {
  final String title;

  const LogoHeader({super.key, this.title = 'Centralis'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.hardEdge,
          // Used a local placeholder icon or an asset here later. Using NetworkImage for prototyping as in md.
          child: Image.asset(
            "assets/images/logo-centralis.svg",
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.business, size: 65),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontSize: 36),
        ),
      ],
    );
  }
}
