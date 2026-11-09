import 'package:flutter/material.dart';
import '../../core/extensions/context_extension.dart';
import '../../core/extensions/theme_extension.dart';
import '../../core/constants/app_icons.dart';
import 'custom_tap.dart';

class ChatIconButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double? size;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final Alignment alignment;
  final bool showBadge; // NEW

  const ChatIconButton({
    super.key,
    required this.onTap,
    this.size,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(7.5),
    this.alignment = Alignment.centerRight,
    this.showBadge = false, // default false
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? context.screenWidth * 0.05;

    return Align(
      alignment: alignment,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomTap(
            onTap: onTap,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor ?? context.appColors.brand,
              ),
              child: Image.asset(
                AppIcons.chat,
                height: iconSize,
                width: iconSize,
                fit: BoxFit.contain,
              ),
            ),
          ),

          if (showBadge)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                height: 10,
                width: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}