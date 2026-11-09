import 'package:driver_app/core/constants/app_colors.dart';
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/extensions/strings_extensions.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:driver_app/shared/widgets/circular_profile.dart';
import 'package:driver_app/shared/widgets/date_formate.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/driver_referral_item_entity.dart';

class ReferralHistoryTile extends StatelessWidget {
  const ReferralHistoryTile({super.key, required this.item});

  final DriverReferralItemEntity item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final name = (item.riderFirstName?.trim().isNotEmpty ?? false)
        ? item.riderFirstName!.trim()
        : context.l10n.referral_rider_fallback;

    return AppGradientBox(
      padding: const EdgeInsets.all(12),
      cornerRadius: 12,
      child: Row(
        children: [
          CircularProfile(image: item.riderProfilePicture, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelMedium,
                ),
                if (item.displayDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    DateTimeUtils.formatDate(item.displayDate!),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _ReferralStatusChip(item: item),
        ],
      ),
    );
  }
}

class _ReferralStatusChip extends StatelessWidget {
  const _ReferralStatusChip({required this.item});

  final DriverReferralItemEntity item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

    final (String label, Color color) = switch (item.status) {
      DriverReferralStatus.saved => (
        l10n.referral_status_saved,
        colors.textSecondary,
      ),
      DriverReferralStatus.applied => (
        l10n.referral_status_applied,
        AppColors.warning,
      ),
      DriverReferralStatus.completed => (
        item.bonusAmount != null
            ? '${l10n.referral_status_completed} +\$${item.bonusAmount!.toStringAsFixed(2)}'
            : l10n.referral_status_completed,
        AppColors.brand,
      ),
      DriverReferralStatus.voided => (
        l10n.referral_status_voided,
        AppColors.error,
      ),
      // A status this app version doesn't know yet: show it as the API sent it.
      DriverReferralStatus.unknown => (
        (item.rawStatus?.trim().isNotEmpty ?? false)
            ? item.rawStatus!.trim().replaceAll('_', ' ').capitalised
            : '—',
        colors.textSecondary,
      ),
    };

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: context.screenWidth * 0.42),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5), width: .5),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: context.textTheme.labelSmall?.copyWith(color: color),
        ),
      ),
    );
  }
}
