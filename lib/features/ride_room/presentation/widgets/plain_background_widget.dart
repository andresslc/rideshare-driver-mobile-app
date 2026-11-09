import 'package:driver_app/core/constants/app_colors.dart';
import 'package:driver_app/core/core.dart';
import 'package:flutter/material.dart';

class PlainBackgroundWidget extends StatelessWidget {
  const PlainBackgroundWidget({
    super.key,
    required this.child,
    this.radius = 32,
    this.padding = EdgeInsets.zero,
    this.color,
    this.border,
    this.isPlain,
    this.isAllRounded = false,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BorderSide? border;
  final bool? isPlain;
  final bool isAllRounded;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDark;

    final usePlain = isPlain ?? isDarkMode;
    return Container(
      padding: padding,
      decoration: ShapeDecoration(
        color:
            color ??
            (usePlain
                ? Theme.of(context).cardColor
                : AppColors.darkTextPrimary),

        //  condition yahan apply hogi
        shape: RoundedSuperellipseBorder(
          borderRadius: isAllRounded
              ? BorderRadius.circular(radius)
              : BorderRadius.only(
                  topLeft: Radius.circular(radius),
                  topRight: Radius.circular(radius),
                ),

          side:
              border ??
              BorderSide(
                color: Colors.grey.withValues(alpha: 0.3), // subtle grey border
                width: 0.5,
              ),
        ),
      ),
      child: child,
    );
  }
}
