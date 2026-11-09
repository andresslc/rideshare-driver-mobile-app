import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/utils/mapbox_navigation_launcher.dart';
import 'package:driver_app/features/ride_history/presentation/widgets/info_card_widget.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:driver_app/features/ride_room/presentation/screens/drag_handler.dart';
import 'package:driver_app/features/ride_room/presentation/widgets/plain_background_widget.dart';
import 'package:driver_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_images.dart';
import '../../../../shared/widgets/google_maps_navigate_button.dart';
import '../../../../shared/widgets/ride_driver_info.dart';
import '../../../../shared/widgets/ride_stats_row.dart';
import '../../../../shared/widgets/verticle_location_stepper.dart';

class ReachedDestinationSheet extends ConsumerStatefulWidget {
  const ReachedDestinationSheet({super.key});

  @override
  ConsumerState<ReachedDestinationSheet> createState() =>
      _ReachedDestinationSheetState();
}

class _ReachedDestinationSheetState
    extends ConsumerState<ReachedDestinationSheet> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  static const double maxChildSize = 0.85;
  static const double minChildSize = 0.4;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: maxChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      controller: _sheetController,
      snap: true,
      snapSizes: const [minChildSize, maxChildSize],
      builder: (context, controller) {
        return PlainBackgroundWidget(
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                DragHandlerWidget(
                  controller: _sheetController,
                  minChildSize: minChildSize,
                  maxChildSize: maxChildSize,
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(top: 16),
                    controller: controller,
                    children: [_sheetContent()],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------- UI PARTS ----------------

  Widget _sheetContent() {
    final l10 = context.l10n;
    final hp = EdgeInsets.symmetric(horizontal: 16);
    final rideState = ref.watch(rideSocketProvider);
    final ride = rideState.ride;

    if (ride == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final String startTime = ride.createdAt != null
        ? DateFormat('hh:mm a').format(ride.createdAt!)
        : '--:--';
    final String userName = (ride.user?.name.trim().isNotEmpty ?? false)
        ? ride.user!.name.trim()
        : 'Passenger';
    final String pickupName =
        (ride.pickupPoint?.placeName.trim().isNotEmpty ?? false)
        ? ride.pickupPoint!.placeName
        : 'Pickup location';
    final String dropoffName =
        (ride.dropOffPointRequested?.placeName.trim().isNotEmpty ?? false)
        ? ride.dropOffPointRequested!.placeName
        : 'Dropoff location';

    final sr = ride.specialRequest.trim();
    final vehicleName = <String>[
      ride.vehicle?.name?.trim() ?? '',
      ride.vehicle?.model?.trim() ?? '',
    ].where((part) => part.isNotEmpty).join(' ').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: hp,
          child: Text(
            l10.reached_destination,
            style: context.textTheme.headlineMedium,
            textAlign: TextAlign.start,
          ),
        ),

        const SizedBox(height: 16),
        Divider(height: AppSizes.p20),
        Padding(
          padding: hp,
          child: DriverInfoSection(
            profileImage: ride.user?.profilePicture ?? AppImages.sedan,
            userName: userName,
            rating: 4.5,
            carImage: ride.vehicle?.image ?? AppImages.sedan,
            carName: vehicleName,
            vehicleType: ride.vehicle?.numberPlate ?? '',
            wantChatIcon: true,
            showTopBorder: false,
            showTrailing: true,
            showBadge: rideState.unreadChatDotForParticipant(
              ride.user?.id ?? ride.userId,
            ),
            onTrailing: () {
              final rideId = ride.id;
              final riderId = ride.user?.id ?? ride.userId ?? '';
              final riderName = userName;
              final profileImage = ride.user?.profilePicture ?? '';
              if (rideId.isEmpty || riderId.isEmpty) return;
              context.pushNamed(
                Routes.chat.name,
                queryParameters: {
                  'rideId': rideId,
                  'riderId': riderId,
                  'riderName': riderName,
                  if (profileImage.isNotEmpty)
                    'riderProfileImage': profileImage,
                },
              );
              ref.read(rideSocketProvider.notifier).clearChatBadge();
            },
          ),
        ),
        Divider(height: AppSizes.p20),
        Padding(
          padding: hp,
          child: VerticleLocationStepper(
            showTopBorder: false,
            locationList: [pickupName, dropoffName],
            startTime: startTime,
          ),
        ),
        const SizedBox(height: AppSizes.p16),

        if (sr.isNotEmpty)
          Padding(
            padding: hp,
            child: InfoCard(showTopBorder: true, description: sr),
          ),
        if (ride.dropOffPointRequested != null)
          Padding(
            padding: hp,
            child: GoogleMapsNavigateButton(
              onPressed: () => openMapboxNavigation(
                context,
                ref: ref,
                destinationLat: ride.dropOffPointRequested!.location.latitude,
                destinationLng: ride.dropOffPointRequested!.location.longitude,
                destinationName: ride.dropOffPointRequested!.placeName,
              ),
            ),
          ),
        const SizedBox(height: AppSizes.p16),
        Padding(
          padding: hp,
          child: RideStatsRow(
            totalTime: ride.averageTime.formatAvgTime(context),
            // totalTime: "${ride.averageTime} min",

            // totalDistance: "${ride.rideDistance} KM",
            totalDistance:
                ride.rideDistance.formatDistance(decimalDigits: 2),
            totalAmount: "\$${ride.payoutFare.toStringAsFixed(2)}",
          ),
        ),

        Divider(height: AppSizes.p20, endIndent: 16, indent: 16),
        const SizedBox(height: AppSizes.p20),

        Padding(
          padding: hp,
          // This sheet is the summary shown once the ride is already
          // completed, so it closes the ride room. Re-sending `ride:complete`
          // from here asks for `completed -> completed` and the backend
          // rejects it as an invalid transition.
          child: AppButton(
            text: l10.done,
            onPressed: () {
              ref.read(rideSocketProvider.notifier).clearRideState();
              context.goNamed(Routes.home.name);
            },
          ),
        ),
        const SizedBox(height: AppSizes.p32),
      ],
    );
  }
}
