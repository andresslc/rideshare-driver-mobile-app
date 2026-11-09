import 'package:flutter/material.dart';

import '../../core/extensions/theme_extension.dart';

class AppVerticalDivider extends StatelessWidget {
  final Color? color;
  final double? width;
  const AppVerticalDivider({super.key, this.color, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: width ?? 1.2,
      color: color ?? context.appColors.border,
    );
  }
}
