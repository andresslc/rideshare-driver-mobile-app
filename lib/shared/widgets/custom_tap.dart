import 'package:driver_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
}

class CustomTap extends StatelessWidget {
  const CustomTap({
    super.key,
    this.onTap,
    required this.child,
    this.padding = 0.0,
    this.radius = 12.0,
    this.isNeedOverlay = true,
    this.hapticFeedbackType = HapticFeedbackType.lightImpact,
  });

  final VoidCallback? onTap;
  final Widget child;
  final double padding;
  final double radius;
  final bool isNeedOverlay;
  final HapticFeedbackType hapticFeedbackType;

  void _triggerHaptic() {
    switch (hapticFeedbackType) {
      case HapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        splashColor: isNeedOverlay
            ? AppColors.brand.withValues(alpha: 0.1)
            : Colors.transparent, // Optional: disables ripple
        highlightColor: isNeedOverlay
            ? AppColors.brand.withValues(alpha: 0.1)
            : Colors.transparent,
        onTap: () {
          _triggerHaptic();
          if (onTap != null) {
            onTap!();
          }
        },
        child: Padding(padding: EdgeInsets.all(padding), child: child),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class CustomTap extends StatelessWidget {
//   const CustomTap({
//     super.key,
//     this.onTap,
//     required this.child,
//     this.padding = 8.0,
//     this.radius = 12.0,
//   });

//   final VoidCallback? onTap;
//   final Widget child;
//   final double padding;
//   final double radius;

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(radius),
//       child: InkWell(
//         onTap: () {
//           HapticFeedback.lightImpact();
//           if (onTap != null) {
//             onTap!();
//           }
//         },
//         child: Padding(padding: EdgeInsets.all(padding), child: child),
//       ),
//     );
//   }
// }
