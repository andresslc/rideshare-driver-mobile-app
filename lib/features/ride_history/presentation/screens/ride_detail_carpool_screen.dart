import 'package:driver_app/features/ride_history/domain/enitities/carpool_history_entities.dart';
import 'package:driver_app/features/ride_room/presentation/widgets/plain_background_widget.dart';
import 'package:driver_app/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/core.dart';
import '../../../../shared/widgets/verticle_location_stepper.dart';

class RideDetailCarpoolScreen extends StatefulWidget {
  final CarpoolRideEntity ride;

  const RideDetailCarpoolScreen({super.key, required this.ride});

  @override
  State<RideDetailCarpoolScreen> createState() =>
      _RideDetailCarpoolScreenState();
}

class _RideDetailCarpoolScreenState extends State<RideDetailCarpoolScreen> {
  // void passenegerroute({required String rideId}) {
  //   context.pushNamed(Routes.passengerdetail.name, extra: {"rideId": rideId});
  // }

  //passenger route
  void passenegerroute({String? carpoolId}) {
    final extra = <String, String>{};
    if (carpoolId != null) extra["carpoolId"] = carpoolId;

    context.pushNamed(Routes.passengerdetail.name, extra: extra);
  }

  //use to remove yesterday and today
  String formatTime(BuildContext context, DateTime date) {
    return date.toLocal().formatTimeWithFixedAmPm(
      localeName: context.l10n.localeName,
    );
  }

  CarpoolRideEntity get ride => widget.ride;
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: EdgeInsets.zero,
      scrollable: true,
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 2),
            Text(
              ride.createdAt.formatRideDateLocalized(
                context.l10n.today_label,
                context.l10n.yesterday_label,
                localeName: context.l10n.localeName,
              ),
              style: context.textTheme.titleMedium,
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            PlainBackgroundWidget(
              isAllRounded: true,
              radius: 10,
              isPlain: Theme.of(context).brightness == Brightness.dark,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.rideDetails,
                    style: context.textTheme.headlineMedium,
                  ),
                  const Gap(AppSizes.p8),
                  VerticleLocationStepper(
                    locationList: ride.routes.map((r) => r.placeName).toList(),
                    startTime: ride.createdAt.formatRideDateLocalized(
                      context.l10n.today_label,
                      context.l10n.yesterday_label,
                      localeName: context.l10n.localeName,
                    ),
                    endTime: ride.createdAt
                        .add(Duration(minutes: ride.avgTime))
                        .formatRideDateLocalized(
                          context.l10n.today_label,
                          context.l10n.yesterday_label,
                          localeName: context.l10n.localeName,
                        ),
                  ),
                  const Gap(AppSizes.p16),

                  Container(
                    // padding: const EdgeInsets.all(10),
                    // padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: context.appColors.border,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  const Gap(AppSizes.p18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.start_time, // "Start Time"
                        style: context.textTheme.titleSmall,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatTime(context, ride.graceTime ?? DateTime.now()),
                        style: context.textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const Gap(AppSizes.p16),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: context.appColors.border,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => passenegerroute(carpoolId: ride.id),
                    child: Text(
                      context.l10n.viewPassenger, // "View Passenger"
                      style: context.textTheme.titleSmall?.copyWith(
                        color: AppColors.brand, // Brand color
                      ),
                    ),
                  ),
                  const Gap(AppSizes.p16),

                  // RideStatsRow(
                  //   totalTime: "${ride.avgTime.toDouble()} min",
                  //   totalDistance:
                  //       "${ride.distance.toStringAsFixed(2)} ${context.l10n.miles}",
                  //   totalAmount: "",
                  //   showAvgTime: true,
                  //   showTime: true,
                  //   showDistance: true,
                  //   showAmount: false,
                  // ),
                  // Container(
                  //   padding: const EdgeInsets.all(10),
                  //   decoration: BoxDecoration(
                  //     border: Border(
                  //       top: BorderSide(
                  //         color: context.appColors.border,
                  //         width: 1,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // const Gap(AppSizes.p12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
