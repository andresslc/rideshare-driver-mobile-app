import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/extensions/double_extension.dart';
import 'package:driver_app/core/extensions/strings_extensions.dart';
import 'package:driver_app/features/ride_room/presentation/widgets/plain_background_widget.dart';
import 'package:driver_app/shared/widgets/rider_history_header.dart';
import 'package:driver_app/shared/widgets/verticle_location_stepper.dart';
import 'package:flutter/material.dart';

import '../../domain/enitities/carpool_history_entities.dart';
import '../../../../core/extensions/date_extension.dart';

class CarpoolHistoryCard extends StatelessWidget {
  final CarpoolRideEntity carpoolride;

  const CarpoolHistoryCard({super.key, required this.carpoolride});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statusLabel = _localizedStatus(context, carpoolride.status);

    final List<String> locations = [
      carpoolride.startingPoint.placeName,

      ...carpoolride.routes
          .map((r) => r.placeName)
          .where(
            (place) =>
                place != carpoolride.startingPoint.placeName &&
                place != carpoolride.destination.placeName,
          ),

      carpoolride.destination.placeName,
    ];
    final totalTimeMinutes = (carpoolride.routes.length);

    // example distance

    return PlainBackgroundWidget(
      isAllRounded: true,
      radius: 24,
      isPlain: true,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RideTopInfo(rideType: l10n.carpool_ride, status: statusLabel),

          const SizedBox(height: 8.0),
          VerticleLocationStepper(
            locationList: locations,
            startTime: carpoolride.createdAt.formatTimeWithFixedAmPm(
              localeName: l10n.localeName,
            ),
            endTime: carpoolride.createdAt
                .add(Duration(minutes: totalTimeMinutes))
                .formatTimeWithFixedAmPm(localeName: l10n.localeName),
          ),
          const SizedBox(height: 10.0),
          // RideStatsRow(
          //   totalTime: "$totalTimeMinutes ${l10n.min}",
          //   totalDistance: "$totalDistanceMiles ${l10n.miles}",
          //   totalAmount:
          //       "\$${(carpoolride.maxPassengers * 5).toStringAsFixed(2)}",
          // ),
        ],
      ),
    );
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
