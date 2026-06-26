import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          child: SvgPicture.asset(
            'assets/images/logo-centralis.svg',
            fit: BoxFit.fill,
            placeholderBuilder: (context) => const Icon(Icons.business, size: 65),
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
