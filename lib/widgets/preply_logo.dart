// File: lib/widgets/preply_logo.dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PreplyLogo extends StatelessWidget {
  const PreplyLogo({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(size * 0.32),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: size * 0.55,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Preply',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: size * 0.6,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
