import 'package:driver_app/core/core.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:driver_app/shared/widgets/custom_tap.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BalanceWidget extends StatelessWidget {
  final num balance;
  final bool hasRideRequests;
  final bool isOnline;
  final VoidCallback? onRideRequestsTap;

  const BalanceWidget({
    super.key,
    required this.balance,
    this.hasRideRequests = false,
    this.isOnline = false,
    this.onRideRequestsTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final String rideStatusText = hasRideRequests
        ? l10n.rideRequestsWaiting
        : isOnline
        ? l10n.driverOnlineActive
        : l10n.driverGoOnline;
    final Color rideStatusColor = hasRideRequests
        ? context.appColors.brand
        : isOnline
        ? context.appColors.textSecondary
        : context.colorScheme.error;

    return AppGradientBox(
      cornerRadius: AppSizes.p24,
      padding: const EdgeInsets.all(AppSizes.p12),
      child: Column(
        children: [
          CustomTap(
            onTap: onRideRequestsTap,
            child: AppGradientBox(
              cornerRadius: 14,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p12,
                vertical: 10,
              ),
              child: Row(
                children: [
                  _RideAvailabilityDot(
                    color: rideStatusColor,
                    isHighlighted: hasRideRequests,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      rideStatusText,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: hasRideRequests
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: context.appColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.available_balance,
                      style: context.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "\$${balance.toStringAsFixed(2)}",
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.appColors.brand,
                      ),
                    ),
                  ],
                ),
              ),
              AppGradientBox(
                cornerRadius: AppSizes.p14,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p12),
                  child: CustomTap(
                    onTap: () {
                      context.pushNamed(Routes.wallet.name);
                    },
                    child: Text(
                      l10n.view_detail,
                      style: context.textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RideAvailabilityDot extends StatelessWidget {
  const _RideAvailabilityDot({
    required this.color,
    required this.isHighlighted,
  });

  final Color color;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.38),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}
