import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class TransactionHeader extends StatelessWidget {
  const TransactionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p16,
        vertical: AppSizes.p12,
      ),
      decoration: BoxDecoration(
        color: colors.brand,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.p12),
          topRight: Radius.circular(AppSizes.p12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //for date
          Expanded(
            flex: 2,
            child: Text(
              l10n.date,
              style: textTheme.bodySmall?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          ///for account name
          Expanded(
            flex: 4, // space for account name
            child: Text(
              l10n.account_name,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          //for type
          Expanded(
            flex: 2, // space for type
            child: Text(
              l10n.type,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          //for status
          Expanded(
            flex: 3, // space for status
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                l10n.status,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          //for amount
          Expanded(
            flex: 3,
            child: Text(
              l10n.amount,
              textAlign: TextAlign.right,
              style: textTheme.bodySmall?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
