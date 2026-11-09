import 'package:driver_app/core/constants/app_icons.dart';
import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../shared/widgets/custom_tap.dart';

/// Example bank/card model
class BankCardModel {
  final String id;
  final String cardNumber;
  final bool isDefault;
  final String? brandImage;

  BankCardModel({
    required this.id,
    required this.cardNumber,
    this.isDefault = false,
    this.brandImage,
  });
}

class CardWidget extends StatelessWidget {
  final BankCardModel card;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final bool showIcons; // ✅ optional icons
  final String? title; // ✅ optional title on left

  const CardWidget({
    super.key,
    required this.card,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.showIcons = true, // default: true
    this.title, // default: null
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final appColors = context.appColors;
    final textTheme = context.textTheme;

    return CustomTap(
      onTap: onTap,
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Optional Top Row (Title left, Icons right)
          if (showIcons || title != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (title != null)
                  Text(title!, style: textTheme.labelMedium?.copyWith()),
                if (showIcons)
                  Row(
                    children: [
                      if (onEdit != null)
                        CustomTap(
                          onTap: onEdit,
                          child: Image.asset(
                            AppIcons.edit,
                            width: AppSizes.iconSmall + 4,
                            height: AppSizes.iconSmall + 4,
                            fit: BoxFit.contain,
                            color: colors.secondary,
                          ),
                        ),
                      if (onEdit != null && onDelete != null)
                        const Gap(AppSizes.p12),
                      if (onDelete != null)
                        CustomTap(
                          onTap: onDelete,
                          child: Image.asset(
                            AppIcons.trash,
                            width: AppSizes.iconSmall + 4,
                            height: AppSizes.iconSmall + 4,
                            fit: BoxFit.contain,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          if (showIcons || title != null) const Gap(AppSizes.p8),

          ///  Card Details with Gradient
          AppGradientBox(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p16,
              vertical: AppSizes.p12,
            ),
            cornerRadius: AppSizes.p16,
            borderWidth: 1.5,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '**** **** **** ${card.cardNumber}',
                    style: textTheme.titleMedium?.copyWith(
                      color: appColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (card.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.p8,
                      vertical: AppSizes.p4,
                    ),
                    decoration: BoxDecoration(
                      color: appColors.brand,
                      borderRadius: BorderRadius.circular(AppSizes.p8),
                    ),
                    child: Text(
                      'Default',
                      style: textTheme.labelSmall?.copyWith(
                        color: appColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Gap(AppSizes.p12),
        ],
      ),
    );
  }
}
