import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/extensions/strings_extensions.dart';
import 'package:driver_app/features/ride_history/presentation/widgets/info_card_widget.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:driver_app/features/ride_room/presentation/widgets/plain_background_widget.dart';
import 'package:driver_app/shared/widgets/circular_profile.dart';
import 'package:driver_app/shared/widgets/ride_stats_row.dart';
import 'package:driver_app/shared/widgets/slide_to_confirm.dart';
import 'package:driver_app/shared/widgets/verticle_location_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:driver_app/features/ride_room/domain/entities/ride_entities.dart';

class RideRequestCard extends ConsumerWidget {
  final RideEntity ride;
  final VoidCallback? onAccept;

  /// Marks the request the driver came to from a push notification.
  final bool isHighlighted;

  const RideRequestCard({
    super.key,
    required this.ride,
    this.onAccept,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔹 Selectively watch only the acceptance state for THIS specific ride.
    // This optimization ensures that only the card being interacted with rebuilds.
    final bool isAccepting = ref.watch(
      rideSocketProvider.select((s) => s.acceptingRideId == ride.id),
    );
    final bool isAnyAccepting = ref.watch(
      rideSocketProvider.select((s) => s.acceptingRideId != null),
    );

    final l10n = context.l10n;
    final user = ride.user;
    final String userName = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name.trim()
        : 'Passenger';
    final String pickupName =
        (ride.pickupPoint?.placeName.trim().isNotEmpty ?? false)
        ? ride.pickupPoint!.placeName
        : 'Pickup location';
    final String dropoffName =
        (ride.dropOffPointRequested?.placeName.trim().isNotEmpty ?? false)
        ? ride.dropOffPointRequested!.placeName
        : 'Dropoff location';
    // final DateTime createdAt = ride.createdAt ?? DateTime.now();
    final vehicle = ride.vehicle;
    final String vehicleName =
        <String>[vehicle?.name ?? '', vehicle?.model ?? '']
            .where((part) => part.trim().isNotEmpty)
            .map((part) => part.trim())
            .join(' ');
    final String requestLabel = _localizedRideType(context, ride.rideType);
    final Color tagColor = context.appColors.brand;

    final Widget card = PlainBackgroundWidget(
      isAllRounded: true,

      isPlain: Theme.of(context).brightness == Brightness.dark,
      padding: const EdgeInsets.all(16),
      radius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircularProfile(
                image: user?.profilePicture,
                size: context.screenWidth * 0.14,
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName.capitalised,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const Gap(6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const Gap(4),
                        Text(
                          (user?.rating ?? 0).toStringAsFixed(1),
                          style: context.textTheme.bodySmall,
                        ),
                        const Gap(4),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(8),
              _RideRequestTag(label: requestLabel, color: tagColor),
            ],
          ),
          const Gap(14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (vehicleName.isNotEmpty)
                _RideMetaChip(
                  icon: Icons.directions_car_outlined,
                  label: vehicleName,
                ),
              if ((vehicle?.numberPlate ?? '').trim().isNotEmpty)
                _RideMetaChip(
                  icon: Icons.badge_outlined,
                  label: vehicle!.numberPlate!.trim(),
                ),
              // How far out the ring had to reach to include this driver:
              // explains a request that shows up seconds after it was asked for.
              if (ride.dispatch?.displayRadius != null)
                _RideMetaChip(
                  icon: Icons.my_location_outlined,
                  label: l10n.ride_request_dispatch_radius(
                    _formatRadius(ride.dispatch!.displayRadius!),
                    // The event carries its own unit; the app-wide one from
                    // `GET /config/ride` is the fallback.
                    ride.dispatch!.distanceUnit ?? distanceUnitLabel(),
                  ),
                ),
            ],
          ),
          const Gap(14),
          Container(
            decoration: BoxDecoration(
              color: context.appColors.fieldFill.withValues(
                alpha: context.isDark ? 0.22 : 0.94,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.appColors.border),
            ),
            padding: const EdgeInsets.all(14),
            child: VerticleLocationStepper(
              locationList: [pickupName, dropoffName],
              showTopBorder: false,
              backgroundColor: Colors.transparent,
            ),
          ),
          // const Gap(12),
          if (ride.specialRequest.isNotEmpty)
            Column(
              children: [
                const Gap(AppSizes.p12),
                InfoCard(
                  showIcon: false,
                  showTopBorder: false,
                  description: ride.specialRequest.trim(),
                ),
              ],
            ),
          const Gap(AppSizes.p12),
          // Driver earnings, not what the passenger pays: on a promo ride the
          // platform covers the difference, so this can be above the fare and
          // is never zero on a free ride.
          RideStatsRow(
            totalTime: ride.averageTime.formatAvgTime(context),
            totalDistance: ride.rideDistance.formatDistance(),
            totalAmount: "\$${ride.payoutFare.toStringAsFixed(2)}",
          ),
          const Gap(AppSizes.p12),

          RepaintBoundary(
            child: SizedBox(
              height: 56,
              child: SlideToConfirm(
                text: l10n.accept,
                acceptedText: l10n.accepted,
                isLoading: isAccepting,
                isAccepted: ride.rideStatus.toLowerCase() == 'accepted',
                isDisabled:
                    isAnyAccepting ||
                    ride.rideStatus.toLowerCase() == 'accepted',
                onSubmit: onAccept,
              ),
            ),
          ),
        ],
      ),
    );

    if (!isHighlighted) return card;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.brand, width: 2),
      ),
      child: Padding(padding: const EdgeInsets.all(2), child: card),
    );
  }
}

class _RideRequestTag extends StatelessWidget {
  const _RideRequestTag({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.appColors.brand;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: context.isDark ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: effectiveColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          overflow: TextOverflow.ellipsis,
          color: effectiveColor,
        ),
      ),
    );
  }
}

class _RideMetaChip extends StatelessWidget {
  const _RideMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.appColors.fieldFill.withValues(
          alpha: context.isDark ? 0.3 : 0.88,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: context.appColors.textSecondary),
          const Gap(6),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Drops the trailing zero on whole radii: 2.0 -> "2", 1.5 -> "1.5".
String _formatRadius(double radius) {
  return radius == radius.roundToDouble()
      ? radius.toStringAsFixed(0)
      : radius.toStringAsFixed(1);
}

String _localizedRideType(BuildContext context, String rideType) {
  switch (rideType.toLowerCase()) {
    case 'economy':
      return context.l10n.economy;
    case 'private':
      return context.l10n.private;
    case 'luxury':
      return context.l10n.luxury;

    default:
      return rideType.capitalised;
  }
}
