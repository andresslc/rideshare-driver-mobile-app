import 'package:driver_app/core/constants/app_colors.dart';
import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/extensions/context_extension.dart'
    show ContextExtension;
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_divider.dart';

class DashboardRideStats extends StatelessWidget {
  const DashboardRideStats({
    super.key,
    required this.totalRides,
    required this.cancelledRides,
    required this.compeletedRides,
  });

  final String totalRides;
  final String cancelledRides;
  final String compeletedRides;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppGradientBox(
      cornerRadius: AppSizes.p24,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.p12),
            child: Text(l10n.recent_ride, style: context.textTheme.bodyMedium),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              // border: Border.symmetric(
              //   horizontal: BorderSide(
              //     color: AppColors.genericBorder,
              //     width: 1,
              //   ),
              // ),
              border: Border(
                top: BorderSide(color: AppColors.genericBorder, width: .8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Total Rides
                _DashboardStatItem(
                  title: context.l10n.todays_rides,
                  value: totalRides,
                ),
                AppVerticalDivider(width: .8, color: AppColors.genericBorder),

                /// Active Rides
                _DashboardStatItem(
                  title: context.l10n.cancelled,
                  value: cancelledRides,
                ),

                AppVerticalDivider(width: .8, color: AppColors.genericBorder),

                /// Total Earnings
                _DashboardStatItem(
                  title: context.l10n.completed,
                  value: compeletedRides,
                  isAmount: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardStatItem extends StatelessWidget {
  const _DashboardStatItem({
    required this.title,
    required this.value,
    this.isAmount = false,
  });

  final String title;
  final String value;
  final bool isAmount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(title, style: context.textTheme.titleSmall),
        ],
      ),
    );
  }
}
