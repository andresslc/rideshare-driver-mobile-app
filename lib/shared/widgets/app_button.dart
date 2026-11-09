// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import '../../core/extensions/context_extension.dart';
// import '../../core/extensions/theme_extension.dart';

// class AppButton extends StatefulWidget {
//   const AppButton({
//     super.key,
//     this.height,
//     this.width,
//     this.radius = 12,
//     this.backgroundColor,
//     this.onPressed,
//     required this.text,
//     this.fontSize,
//     this.fontWeight,
//     this.fontColor,
//     this.padding,
//     this.isDisable = false,
//     this.child,
//   });

//   final double? height;
//   final double? width;
//   final double radius;
//   final Color? backgroundColor;
//   final void Function()? onPressed;
//   final String text;
//   final double? fontSize;
//   final FontWeight? fontWeight;
//   final Color? fontColor;
//   final EdgeInsetsGeometry? padding;
//   final bool isDisable;
//   final Widget? child;

//   @override
//   AppButtonState createState() => AppButtonState();
// }

// class AppButtonState extends State<AppButton>
//     with SingleTickerProviderStateMixin {
//   bool isPressed = false;

//   @override
//   Widget build(BuildContext context) {
//     final isDisabled = widget.isDisable || widget.onPressed == null;

//     return SizedBox(
//       width: widget.width ?? context.screenWidth,
//       height: widget.height ?? 50,
//       child: GestureDetector(
//         onSecondaryTap: isDisabled
//             ? null
//             : () => setState(() => isPressed = true),
//         onTapDown: isDisabled
//             ? null
//             : (_) => setState(() => isPressed = true), // Button pressed
//         onTapUp: isDisabled
//             ? null
//             : (_) => setState(() => isPressed = false), // Button released
//         onTapCancel: isDisabled
//             ? null
//             : () =>
//                   setState(() => isPressed = false), // Handle tap cancellation
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 100),
//           decoration: BoxDecoration(
//             color: widget.backgroundColor,
//             borderRadius: BorderRadius.circular(widget.radius),
//           ),
//           curve: Curves.easeInOut,
//           transformAlignment: Alignment.center,
//           transform: Matrix4.identity()
//             ..scale(isPressed ? 0.93 : 1.0), // Scale down when pressed
//           child: ElevatedButton(
//             onPressed: isDisabled
//                 ? null
//                 : () {
//                     HapticFeedback.heavyImpact();
//                     widget.onPressed?.call();
//                   },
//             style: ElevatedButton.styleFrom(
//               // disabledBackgroundColor: context.appColors.textPrimary,
//               backgroundColor: widget.backgroundColor,
//               shadowColor: Colors.transparent,
//               alignment: Alignment.center,
//               padding: widget.padding,
//               // shape: RoundedRectangleBorder(
//               //   borderRadius: BorderRadius.circular(widget.radius),
//               // ),
//               fixedSize: Size(
//                 widget.width ?? double.maxFinite,
//                 widget.height ?? 50,
//               ),
//             ),
//             child: FittedBox(
//               child:
//                   widget.child ??
//                   Text(
//                     widget.text,

//                     style: context.textTheme.bodyMedium?.copyWith(
//                       color: isDisabled
//                           ? context.appColors.textSecondary
//                           : widget.fontColor ?? context.appColors.button,
//                       fontSize: widget.fontSize ?? 14,
//                       fontWeight: widget.fontWeight ?? FontWeight.w600,
//                     ),
//                   ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    this.height,
    this.width,
    this.radius = 12,
    this.backgroundColor,
    this.onPressed,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.fontColor,
    this.padding,
    this.isDisable = false,
    this.isLoading = false,
    this.child,
    this.alignment = Alignment.center,
  });

  final double? height;
  final double? width;
  final double radius;
  final Color? backgroundColor;
  final void Function()? onPressed;
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? fontColor;
  final EdgeInsetsGeometry? padding;
  final bool isDisable;
  final bool isLoading;
  final Widget? child;
  final AlignmentGeometry alignment;
  @override
  AppButtonState createState() => AppButtonState();
}

class AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled =
        widget.isDisable || widget.onPressed == null || widget.isLoading;

    return SizedBox(
      width: widget.width ?? context.screenWidth,
      // agar null ho to parent ki width lega
      height: widget.height ?? 50,
      child: GestureDetector(
        onSecondaryTap: widget.isDisable
            ? null
            : () => setState(() => isPressed = true),
        onTapDown: widget.isDisable
            ? null
            : (_) => setState(() => isPressed = true), // Button pressed
        onTapUp: widget.isDisable
            ? null
            : (_) => setState(() => isPressed = false), // Button released
        onTapCancel: widget.isDisable
            ? null
            : () =>
                  setState(() => isPressed = false), // Handle tap cancellation
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
          curve: Curves.easeInOut,
          transformAlignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(isPressed ? 0.93 : 1.0), // Scale down when pressed
          child: ElevatedButton(
            onPressed: widget.isDisable
                ? null
                : () {
                    HapticFeedback.heavyImpact();
                    widget.onPressed?.call();
                  },
            style: ElevatedButton.styleFrom(
              // disabledBackgroundColor: context.appColors.textPrimary,
              backgroundColor: widget.backgroundColor,
              shadowColor: Colors.transparent,
              alignment: Alignment.center,
              padding: widget.padding ?? const EdgeInsets.all(0),
              // shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.circular(widget.radius),
              // ),
              fixedSize: Size(
                widget.width ?? double.maxFinite,
                widget.height ?? 50,
              ),
            ),
            child: widget.isLoading
                ? LoadingAnimationWidget.threeRotatingDots(
                    color: widget.fontColor ?? context.appColors.button,
                    size: (widget.height ?? 50) * 0.6,
                  )
                : widget.child ??
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.text,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: isDisabled
                                ? context.appColors.textSecondary
                                : widget.fontColor ?? context.appColors.button,
                            fontSize: widget.fontSize ?? 14,
                            fontWeight: widget.fontWeight ?? FontWeight.w600,
                          ),
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
