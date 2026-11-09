import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../shared/widgets/custom_tap.dart';

class PaymentMethodWidget extends StatelessWidget {
  final String cardNumber;
  final bool isDefault;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const PaymentMethodWidget({
    super.key,
    required this.cardNumber,
    this.isDefault = false,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final textTheme = context.textTheme;

    return CustomTap(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 1, color: context.appColors.border),

          /// Payment Method Label
          Padding(
            padding: const EdgeInsets.only(
              left: AppSizes.p4,
              top: AppSizes.p12,
              bottom: AppSizes.p4,
            ),
            child: Text(
              'Payment Method',
              style: textTheme.labelMedium?.copyWith(
                color: appColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          /// Card Details with Gradient
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
                    '**** **** **** $cardNumber',
                    style: textTheme.titleMedium?.copyWith(
                      color: appColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isDefault)
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
