// import 'package:driver_app/core/core.dart';
// import 'package:driver_app/shared/widgets/app_gradient_box.dart';
// import 'package:flutter/material.dart';

// class SlowConnectionBanner extends StatelessWidget {
//   const SlowConnectionBanner({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = context.isDark;
//     final backgroundColor = isDark
//         ? AppColors.lightButton
//         : AppColors.brandLight;
//     final borderColor = isDark
//         ? const Color(0xFF334039)
//         : const Color(0xFFD2DCD4);
//     final iconColor = context.appColors.brand;
//     final textColor = context.appColors.textPrimary;

//     return SafeArea(
//       bottom: false,
//       child: Material(
//         color: Colors.transparent,
//         child: Container(
//           decoration: BoxDecoration(
//             color: backgroundColor,
//             border: Border(bottom: BorderSide(color: borderColor, width: 1)),
//             // color: Color.alphaBlend(
//             //   Colors.orange.withValues(alpha: 0.8),
//             //   backgroundColor,
//             // ),
//             // border: Border(bottom: BorderSide(color: Colors.orange, width: 2)),
//           ),

//           padding: const EdgeInsets.symmetric(
//             horizontal: AppSizes.p16,
//             vertical: AppSizes.p12,
//           ),
//           child: Row(
//             children: <Widget>[
//               Icon(
//                 Icons.signal_wifi_statusbar_connected_no_internet_4,
//                 color: iconColor,
//                 size: AppSizes.p20,
//               ),
//               const SizedBox(width: AppSizes.p12),
//               Expanded(
//                 child: Text(
//                   context.l10n.slow_connection_banner,
//                   style: context.textTheme.bodyMedium?.copyWith(
//                     color: textColor,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import '../../core/extensions/context_extension.dart';
import '../../core/extensions/theme_extension.dart';
import '../../core/theme/app_colors.dart';

class SlowConnectionBanner extends StatefulWidget {
  const SlowConnectionBanner({super.key});

  @override
  State<SlowConnectionBanner> createState() => _SlowConnectionBannerState();
}

class _SlowConnectionBannerState extends State<SlowConnectionBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Slow, deliberate pulse — mirrors the "still trying" nature of a
    // flaky connection rather than a generic loading spinner.
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.isDark;
    //   final colors = context.appColors;
    final Color iconColor = isDark ? AppColors.brand : AppColors.lightButton;
    final Color backgroundColor = isDark
        ? AppColors.lightButton
        : AppColors.brand;
    final Color borderColor = isDark
        ? const Color(0xFF334039)
        : const Color(0xFFD2DCD4);
    final Color accent = iconColor;

    return SafeArea(
      bottom: false,
      child: Material(
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border(bottom: BorderSide(color: borderColor, width: 0.8)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final double t = _pulseController.value;
                  return Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 22 + (t * 6),
                          height: 22 + (t * 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: 0.14 * (1 - t)),
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: 0.12),
                          ),
                          child: Icon(
                            Icons.wifi_rounded,
                            size: 20,
                            color: iconColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Text(
                    //   'Unstable network',
                    //   maxLines: 1,
                    //   overflow: TextOverflow.ellipsis,
                    //   style: context.textTheme.bodyMedium?.copyWith(
                    //     fontSize: 13,
                    //     fontWeight: FontWeight.w600,
                    //     height: 1.1,
                    //     color: colors.textPrimary,
                    //   ),
                    // ),
                    const SizedBox(height: 1),
                    Expanded(
                      child: Text(
                        context.l10n.slow_connection_banner,
                        style: context.textTheme.bodyMedium?.copyWith(
                          // color: Colors.white,
                          color: context.appColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
