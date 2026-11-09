import 'package:driver_app/core/constants/app_colors.dart';
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/driver_referral_summary_entity.dart';

/// Referral stats, styled like the wallet's balance sub-cards.
/// `voided` is shown only when it is greater than 0.
class ReferralStatsGrid extends StatelessWidget {
  const ReferralStatsGrid({super.key, required this.stats});

  final DriverReferralStatsEntity stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final tiles = [
      _ReferralStatTile(
        title: l10n.referral_stat_saved,
        value: '${stats.saved}',
        icon: Icons.person,
        accentColor: context.appColors.textSecondary,
      ),
      _ReferralStatTile(
        title: l10n.referral_stat_applied,
        value: '${stats.applied}',
        icon: Icons.directions_car_outlined,
        accentColor: AppColors.warning,
      ),
      _ReferralStatTile(
        title: l10n.referral_stat_completed,
        value: '${stats.completed}',
        icon: Icons.check_circle_rounded,
        accentColor: AppColors.brand,
      ),
      _ReferralStatTile(
        title: l10n.referral_stat_earned,
        value: '\$${stats.totalEarned.toStringAsFixed(2)}',
        icon: Icons.stars_rounded,
        accentColor: Colors.amber.shade700,
      ),
      if (stats.voided > 0)
        _ReferralStatTile(
          title: l10n.referral_stat_voided,
          value: '${stats.voided}',
          icon: Icons.cancel,
          accentColor: AppColors.error,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final tileWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final tile in tiles) SizedBox(width: tileWidth, child: tile),
          ],
        );
      },
    );
  }
}

class _ReferralStatTile extends StatelessWidget {
  const _ReferralStatTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: accentColor),
              const SizedBox(width: 4),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: textTheme.labelMedium?.copyWith(
                      color: colors.textPrimary.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
