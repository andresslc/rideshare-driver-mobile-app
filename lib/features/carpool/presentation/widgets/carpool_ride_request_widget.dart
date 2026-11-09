import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/extensions/num_extension.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/features/carpool/domain/entities/carpool_entity.dart';
import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:driver_app/shared/widgets/ride_driver_info.dart';
import 'package:driver_app/shared/widgets/verticle_location_stepper.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../shared/widgets/ride_stats_row.dart';

class CarpoolRideRequestCard extends StatelessWidget {
  final CarpoolIncomingRequestEntity ride;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const CarpoolRideRequestCard({
    super.key,
    required this.ride,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return AppGradientBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Passenger info
          DriverInfoSection(
            showTopBorder: false,
            profileImage: ride.passenger.image,
            userName: ride.passenger.displayName,
            rating: ride.passenger.rating,
          ),

          const Gap(10),

          /// Pickup & Dropoff
          VerticleLocationStepper(
            locationList: [
              ride.pickupStop.placeName,
              ride.dropOffStop.placeName,
            ],
            startTime: null, // Replace with actual startTime if available
            endTime: null, // Replace with actual endTime/duration if available
          ),

          const SizedBox(height: 4),
          Divider(),
          const SizedBox(height: 4),

          /// Number of Passengers / Required Seats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "No of Passengers",
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                ride.requiredSeats.toString(),
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          RideStatsRow(
            totalDistance:
                "${ride.distance?.toStringAsFixed(2)} ${context.l10n.miles}",
            totalAmount: "\$${ride.fareCharged.toStringAsFixed(2)}",
          ),

          /// Fare & Distance / Time Info (optional, static here)
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(
          //           // "Fare Charged",
          //           context.l10n.estimated_fare,
          //           style: context.textTheme.bodyMedium?.copyWith(
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //         const SizedBox(height: 4),
          //         Text(
          //           // "${ride.fareCharged.toStringAsFixed(2)} USD",
          //           "\$${ride.fareCharged.toStringAsFixed(2)}",
          //           style: context.textTheme.bodyMedium?.copyWith(
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //       ],
          //     ),

          //     // Vertical Divider
          //     Container(
          //       height: 48,
          //       width: 1.5,
          //       color: context.appColors.border,
          //     ),

          //     Column(
          //       crossAxisAlignment: CrossAxisAlignment.end,
          //       children: [
          //         Text(
          //           "Total Distance",
          //           style: context.textTheme.bodyMedium?.copyWith(
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //         const SizedBox(height: 4),
          //         Text(
          // (ride.distance ?? 0).formatDistance(),
          //           style: context.textTheme.bodyMedium?.copyWith(
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
          const SizedBox(height: 14),

          /// Accept / Reject buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  backgroundColor: context.colorScheme.error,
                  text: "Reject",
                  fontColor: context.colorScheme.onPrimary,
                  onPressed: onReject,
                ),
              ),
              const Gap(12),
              Expanded(
                child: AppButton(text: "Accept", onPressed: onAccept),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
