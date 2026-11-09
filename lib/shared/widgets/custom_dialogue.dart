import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/core/theme/app_colors.dart';
import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomDialogue extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imagePath;
  final IconData? icon;
  final Color? iconColor;
  final List<AppButton>? buttons;
  final VoidCallback? onClose;

  const CustomDialogue({
    super.key,
    required this.title,
    required this.subtitle,
    this.imagePath,
    this.icon,
    this.buttons,
    this.onClose,

    this.iconColor,
  });
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.04;
    final iconSize = size.width * 0.12;
    final spacingMedium = size.height * 0.02;
    final buttonHeight = size.height * 0.06;
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child:
          AppGradientBox(
                cornerRadius: 16,
                isPlain: true,
                padding: EdgeInsets.symmetric(
                  horizontal: padding,
                  // vertical: padding * 1.5,
                ).copyWith(top: padding * 1.5, bottom: padding / 1.5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon or Image
                    if (imagePath != null)
                      Image.asset(imagePath!, height: iconSize, width: iconSize)
                          .animate()
                          .scale(
                            duration: 400.ms,
                            curve: Curves.easeOutBack,
                            begin: const Offset(0, 0),
                            end: const Offset(1, 1),
                          )
                          .fadeIn()
                    else if (icon != null)
                      Icon(
                            icon,
                            color: iconColor ?? context.appColors.brand,
                            size: iconSize,
                          )
                          .animate()
                          .scale(
                            duration: 400.ms,
                            curve: Curves.easeOutBack,
                            begin: const Offset(0, 0),
                            end: const Offset(1, 1),
                          )
                          .fadeIn(),
                    const SizedBox(height: AppSizes.p12),

                    // Title
                    Text(
                          title,
                          textAlign: TextAlign.center,
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 150.ms, duration: 300.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: AppSizes.p8),
                    // Subtitle (Flexible + Centered)
                    Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: AppColors.subtitledialogue,
                            fontSize: size.width * 0.038,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 250.ms, duration: 300.ms)
                        .slideY(begin: 0.1, end: 0),
                    SizedBox(height: spacingMedium),
                    // Buttons
                    if (buttons != null && buttons!.isNotEmpty)
                      Row(
                        spacing: 8,
                        children: List.generate(buttons!.length, (index) {
                          final btn = buttons![index];

                          return Expanded(
                                child: AppButton(
                                  height: buttonHeight,
                                  // radius: AppSizes.radiusSmall,
                                  text: btn.text,
                                  fontSize:
                                      context.textTheme.labelMedium?.fontSize,
                                  fontWeight: FontWeight.w600,
                                  onPressed: btn.onPressed,
                                  backgroundColor: btn.backgroundColor,
                                  fontColor: btn.fontColor,
                                ),
                              )
                              .animate()
                              .fadeIn(delay: (300 + index * 100).ms)
                              .slideY(begin: 0.1, end: 0);
                        }),
                      ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 250.ms)
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                duration: 300.ms,
                curve: Curves.easeOutBack,
              ),
    );
  }
}

//without button use dialogue
 // showDialog(
              //   context: context,
              //   builder: (_) => GradientSideDialog(
              //     title: "Success",
              //     subtitle: "Your action was successful!",
              //     icon: Icons.check_circle,
              
              

//with button
            //  showDialog(
            //       context: context,
            //       builder: (_) => GradientSideDialog(
            //         title: "Warning",
            //         subtitle: "Are you hare you want to delete this account?",
            //         imagePath: AppImages.noImage,
            //         buttons: [
            //           AppButton(
            //             text: "Cancel",
            //             fontColor: AppColors.brandDark,
            //             onPressed: () => Navigator.pop(context),
            //             backgroundColor: AppColors.darkField,
            //           ),
            //           AppButton(
            //             text: "Confirm",
            //             fontColor: AppColors.darkBackground,
            //             backgroundColor: AppColors.brand,
            //             onPressed: () {
            //               Navigator.pop(context);
            //             },
            //             // color: Colors.red,
            //           ),
            //         ],
            //       ),
            //     );