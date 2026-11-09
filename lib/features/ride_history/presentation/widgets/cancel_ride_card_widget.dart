import 'package:driver_app/core/extensions/num_extension.dart';
import 'package:driver_app/core/extensions/strings_extensions.dart';
import 'package:driver_app/features/ride_room/presentation/widgets/plain_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/extensions/double_extension.dart';
import '../../../../core/extensions/date_extension.dart';
import '../../../../shared/widgets/ride_driver_info.dart';
import '../../../../shared/widgets/ride_stats_row.dart';
import '../../../../shared/widgets/rider_history_header.dart';
import '../../../../shared/widgets/verticle_location_stepper.dart';
import '../../domain/enitities/ride_history_entites.dart';

class CancelRideCard extends StatelessWidget {
  final RideEntity ride;

  const CancelRideCard({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final rideTypeLabel = _localizedRideType(context, ride.rideType);
    final statusLabel = _localizedStatus(context, ride.rideStatus);
    return PlainBackgroundWidget(
      isAllRounded: true,
      radius: 24,

      isPlain: true,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RideTopInfo(rideType: rideTypeLabel, status: statusLabel),
          const Gap(8),
          DriverInfoSection(
            profileImage: ride.user.profilePicture,
            userName: ride.user.displayName,
            rating: ride.user.rating,
            showTrailing: false,
          ),
          const Gap(8),
          VerticleLocationStepper(
            locationList: [
              ride.pickupPoint.placeName,
              ride.dropOffPoint.placeName,
            ],
            startTime: ride.createdAt.formatTimeWithFixedAmPm(
              localeName: context.l10n.localeName,
            ),
            endTime: ride.createdAt
                .add(Duration(minutes: ride.averageTime))
                .formatTimeWithFixedAmPm(localeName: context.l10n.localeName),
          ),
          const Gap(10),
          RideStatsRow(
            totalTime: ride.averageTime.formatAvgTime(context),
            // totalTime: "${ride.averageTime} min",
            totalDistance:
                ride.rideDistance.formatDistance(decimalDigits: 2),
            totalAmount: "\$${ride.rideFare.toStringAsFixed(2)}",
          ),
          const Gap(12),
          // Cancellation Info
          // Container(
          //   padding: const EdgeInsets.all(12),
          //   decoration: BoxDecoration(
          //     color: Colors.red.withOpacity(0.1),
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         'Cancellation Reason',
          //         style: Theme.of(context).textTheme.labelSmall?.copyWith(
          //           fontWeight: FontWeight.w600,
          //           color: Colors.red,
          //         ),
          //       ),
          //       const Gap(4),
          //       Text(
          //         ride.cancellationReason?.isNotEmpty == true
          //             ? ride.cancellationReason!
          //             : 'No reason provided',
          //         style: Theme.of(
          //           context,
          //         ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          //         maxLines: 2,
          //         overflow: TextOverflow.ellipsis,
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

String _localizedRideType(BuildContext context, String rideType) {
  final l10 = context.l10n;
  switch (rideType.toLowerCase()) {
    case 'economy':
      return l10.economy;
    case 'luxury':
      return l10.luxury;
    case 'carpool':
      return l10.carpool_ride;
    default:
      return rideType.capitalised;
  }
}

String _localizedStatus(BuildContext context, String status) {
  final l10 = context.l10n;
  switch (status.toLowerCase()) {
    case 'completed':
      return l10.completed;
    case 'cancelled':
    case 'canceled':
      return l10.cancelled;
    default:
      return status.capitalised;
  }
}
