import 'package:flutter/material.dart';

import '../../core/extensions/theme_extension.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96, this.showText = true});

  final double size;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.brand.withOpacity(0.35)),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.directions_car_filled,
            color: colors.brand,
            size: size * 0.55,
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'DRIVER APP',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colors.brand,
                  letterSpacing: 1.2,
                ),
          ),
        ],
      ],
    );
  }
}
