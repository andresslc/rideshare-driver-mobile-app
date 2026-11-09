import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/l10n/app_localizations.dart';
import 'package:driver_app/shared/widgets/app_gradient_overlay_dropdown.dart';
import 'package:flutter/material.dart';

class TransactionFilterHeader extends StatelessWidget {
  const TransactionFilterHeader({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  final String selectedCategory;
  final void Function(String) onChanged;

  static const _categories = ['all', 'debit', 'credit'];

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final l10n = AppLocalizations.of(context)!;

    final categoryLabels = {
      'all': l10n.all,
      'debit': l10n.debit,
      'credit': l10n.credit,
    };

    final items = _categories
        .map(
          (c) => GradientDropdownItem<String>(
            value: c,
            label: categoryLabels[c] ?? c,
          ),
        )
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              l10n.transactionHistory,
              style: textTheme.titleSmall?.copyWith(
                color: context.appColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppGradientOverlayDropdown<String>(
            selected: selectedCategory.toLowerCase(),
            items: items,
            onSelected: onChanged,
          ),
        ],
      ),
    );
  }
}
