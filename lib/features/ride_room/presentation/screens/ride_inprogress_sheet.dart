import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/utils/ride_cancel_flow_helper.dart';
import 'package:driver_app/core/utils/mapbox_navigation_launcher.dart';
import 'package:driver_app/features/ride_history/presentation/widgets/info_card_widget.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:driver_app/features/ride_room/presentation/screens/drag_handler.dart';
import 'package:driver_app/features/ride_room/presentation/widgets/plain_background_widget.dart';
import 'package:driver_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_images.dart';
import '../../../../shared/widgets/google_maps_navigate_button.dart';
import '../../../../shared/widgets/ride_driver_info.dart';
import '../../../../shared/widgets/ride_stats_row.dart';
import '../../../../shared/widgets/verticle_location_stepper.dart';

class RideInprogressSheet extends ConsumerStatefulWidget {
  const RideInprogressSheet({super.key});

  @override
  ConsumerState<RideInprogressSheet> createState() =>
      _RideInprogressSheetState();
}

class _RideInprogressSheetState extends ConsumerState<RideInprogressSheet> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  static const double maxChildSize = 0.65;
  static const double minChildSize = 0.4;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: maxChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
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
    final vehicle = ride.vehicle;
    final vehicleName = <String>[vehicle?.name ?? '', vehicle?.model ?? '']
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part.trim())
        .join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: hp,
          child: Text(
            l10.ride_in_progress,
            style: context.textTheme.headlineMedium,
            textAlign: TextAlign.start,
          ),
        ).animate().fade(duration: 350.ms).slideY(begin: 0.15, end: 0),

        const SizedBox(height: 16),
        Divider(height: AppSizes.p20),
        Padding(
          padding: hp,
          child: DriverInfoSection(
            profileImage: ride.user?.profilePicture ?? AppImages.sedan,
            userName: userName,
            rating: 4.5,
            carImage: vehicle?.image ?? AppImages.sedan,
            carName: vehicleName,
            vehicleType: vehicle?.numberPlate ?? '',
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
        ).animate().fade(delay: 150.ms).scale(begin: const Offset(0.95, 0.95)),

        Divider(height: AppSizes.p20),
        Padding(
          padding: hp,
          child: VerticleLocationStepper(
            showTopBorder: false,
            locationList: [pickupName, dropoffName],
            startTime: startTime,
          ),
        ).animate().fade(delay: 250.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: AppSizes.p16),
        // Padding(padding: hp, child: const InfoCard(showTopBorder: true)),
        if (sr.isNotEmpty)
          Padding(
            padding: hp,
            child: InfoCard(showTopBorder: true, description: sr),
          ).animate().fade(delay: 350.ms).slideY(begin: 0.1, end: 0),

        if (ride.dropOffPointRequested != null)
          Padding(
                padding: hp,
                child: GoogleMapsNavigateButton(
                  onPressed: () => openMapboxNavigation(
                    context,
                    ref: ref,
                    destinationLat:
                        ride.dropOffPointRequested!.location.latitude,
                    destinationLng:
                        ride.dropOffPointRequested!.location.longitude,
                    destinationName: ride.dropOffPointRequested!.placeName,
                  ),
                ),
              )
              .animate()
              .fade(delay: 450.ms)
              .scale(begin: const Offset(0.95, 0.95)),

        const SizedBox(height: AppSizes.p16),
        Padding(
          padding: hp,
          child: RideStatsRow(
            totalTime: ride.averageTime.formatAvgTime(context),
            totalDistance:
                ride.rideDistance.formatDistance(decimalDigits: 2), //nce: "${ride.rideDistance} KM",
            totalAmount: "\$${ride.payoutFare.toStringAsFixed(2)}",
          ),
        ).animate().fade(delay: 550.ms).slideY(begin: 0.1, end: 0),

        Divider(
          height: AppSizes.p20,
          endIndent: 16,
          indent: 16,
        ).animate().fade(delay: 550.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: AppSizes.p20),

        Padding(
          padding: hp,
          child: AppButton(
            text: l10.end_ride,
            // Only a ride the backend already moved to `in-progress` can be
            // completed. Until `ride:status:update` says so — with 3-D Secure
            // that is after the passenger verifies the payment — the button
            // stays disabled instead of failing against the state machine.
            isDisable: !ref.watch(
              rideSocketProvider.select(
                (s) =>
                    (s.ride?.rideStatus ?? '').trim().toLowerCase() ==
                    'in-progress',
              ),
            ),
            onPressed: () async {
              final confirmed = await showEndRideConfirmation(context);
              if (confirmed) {
                ref.read(rideSocketProvider.notifier).rideCompleteAction();
              }
            },
          ),
        ).animate().fade(delay: 650.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: AppSizes.p16),
        Padding(
          padding: hp,
          child: AppButton(
            fontColor: context.appColors.brand,
            backgroundColor: context.appColors.border,
            text: l10.cancel_ride,
            onPressed: () => _onCancelRideTap(ride.id),
          ),
        ).animate().fade(delay: 660.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: AppSizes.p32),
      ],
    );
  }

  Future<void> _onCancelRideTap(String? rideId) async {
    if (!mounted) return;
    await cancelRideWithConfirmation(
      context: context,
      ref: ref,
      rideId: rideId,
    );
  }
}
