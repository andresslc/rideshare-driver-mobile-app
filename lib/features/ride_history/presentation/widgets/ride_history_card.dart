import 'package:driver_app/core/extensions/num_extension.dart';
import 'package:driver_app/core/extensions/strings_extensions.dart';
import 'package:driver_app/core/extensions/double_extension.dart';
import 'package:driver_app/features/ride_room/presentation/widgets/plain_background_widget.dart';
import 'package:driver_app/shared/widgets/ride_driver_info.dart';
import 'package:driver_app/shared/widgets/ride_stats_row.dart';
import 'package:driver_app/shared/widgets/rider_history_header.dart';
import 'package:driver_app/shared/widgets/verticle_location_stepper.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extension.dart';
import '../../../../core/extensions/date_extension.dart';
import '../../domain/enitities/ride_history_entites.dart';

class RideHistoryCard extends StatelessWidget {
  final RideEntity ride;

  const RideHistoryCard({super.key, required this.ride});

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
          const SizedBox(height: 8.0),
          DriverInfoSection(
            profileImage: ride.user.profilePicture,
            userName: ride.user.displayName,
            rating: ride.user.rating.toDouble(),
            // carImage: AppImages.sedan,
            carName:
                "${ride.driver.vehicle?.make ?? ''} ${ride.driver.vehicle?.model ?? ''}"
                    .trim(),
            vehicleType: ride.driver.vehicle?.licensePlateNumber ?? '',
            showTrailing: false,
          ),
          const SizedBox(height: 8.0),
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
          const SizedBox(height: 10.0),
          RideStatsRow(
            // totalTime: "${ride.averageTime} min",
            totalTime: ride.averageTime.formatAvgTime(context),
            totalDistance:
                ride.rideDistance.formatDistance(decimalDigits: 2),
            totalAmount: "\$${ride.rideFare.toStringAsFixed(2)}",
          ),
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
