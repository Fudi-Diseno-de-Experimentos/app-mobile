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
          child: Image.network(
            "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/9pEVa5rDhG/eecjshwa_expires_30_days.png",
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
