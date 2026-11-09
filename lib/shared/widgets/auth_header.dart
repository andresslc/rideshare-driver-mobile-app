import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/extensions/theme_extension.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.center = true,
  });

  final String title;
  final String subtitle;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textAlign = center ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: textAlign,
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.15),

        const SizedBox(height: 8),
        Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
              textAlign: textAlign,
            )
            .animate()
            .fadeIn(delay: 180.ms) // thoda late
            .slideY(begin: 0.15),
      ],
    );
  }
}
