
import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:driver_app/shared/widgets/custom_tap.dart';
import 'package:flutter/material.dart';

class LanguageSelection extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const LanguageSelection({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final textTheme = context.textTheme;

    return CustomTap(
      onTap: () => onChanged(value),
      child: AppGradientBox(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
        cornerRadius: AppSizes.p16,
        borderWidth: 1.5,
        blurSigma: 20,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  color: appColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              activeColor: appColors.brand,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
