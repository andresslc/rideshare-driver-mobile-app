import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/shared/shared.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:flutter/material.dart';

class CarpoolRequestCard extends StatelessWidget {
  const CarpoolRequestCard({
    super.key,
    required this.firstTitle,
    required this.secondTitle,
    required this.onPressed,
    required this.buttonText,
  });

  final String firstTitle;
  final String secondTitle;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppGradientBox(
      cornerRadius: AppSizes.p24,

      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Row 1
            Text(firstTitle, style: context.textTheme.bodyMedium),

            const SizedBox(height: 10),

            /// Row 2
            Text(secondTitle, style: context.textTheme.bodySmall),

            const SizedBox(height: 16),

            /// Button
            SizedBox(
              width: double.infinity,
              child: AppButton(text: buttonText, onPressed: onPressed),
            ),
          ],
        ),
      ),
    );
  }
}
