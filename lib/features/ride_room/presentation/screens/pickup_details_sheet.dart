import 'package:driver_app/core/constants/app_icons.dart';
import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/utils/ride_cancel_flow_helper.dart';
import 'package:driver_app/core/utils/mapbox_navigation_launcher.dart';
import 'package:driver_app/core/services/location_service.dart';
import 'package:driver_app/features/ride_history/presentation/widgets/info_card_widget.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:driver_app/features/ride_room/presentation/screens/drag_handler.dart';
import 'package:driver_app/features/ride_room/presentation/widgets/plain_background_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../shared/widgets/app_button.dart' show AppButton;
import '../../../../shared/widgets/google_maps_navigate_button.dart';
import '../../../../shared/widgets/ride_driver_info.dart';

class PickupDetailsSheet extends ConsumerStatefulWidget {
  const PickupDetailsSheet({super.key});

  @override
  ConsumerState<PickupDetailsSheet> createState() => _PickupDetailsSheetState();
}

class _PickupDetailsSheetState extends ConsumerState<PickupDetailsSheet> {
  static const double minChildSize = 0.45;
  static const double maxChildSize = 0.6;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final LocationService _locationService = locator<LocationService>();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: maxChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      snap: true,
      controller: _sheetController,
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
    final ride = ref.watch(rideSocketProvider).ride;

    final sr = ride?.specialRequest.trim() ?? '';
    final vehicleName = <String>[
      ride?.vehicle?.name?.trim() ?? '',
      ride?.vehicle?.model?.trim() ?? '',
    ].where((part) => part.isNotEmpty).join(' ').trim();

    // final chatNotifier = ref.read(chatHistoryProvider.notifier);
    // ref.listen<RideSocketState>(rideSocketProvider, (previous, next) {
    // final lastMessage = next.lastChatMessage;
    // final currentChat = chatNotifier.state.chats;
    // });

    if (ride == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: hp,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // "Pickup DEtail",
                l10.pickup_details,
                style: context.textTheme.headlineMedium,
                textAlign: TextAlign.start,
              ),
              if (kDebugMode)
                Text(
                  "ID: ${ride.id}",
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.appColors.brand,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ).animate().fade(duration: 300.ms).slideY(begin: -0.2, end: 0),

        const SizedBox(height: 16),
        Divider(height: AppSizes.p20),
        Padding(
          padding: hp,
          child: DriverInfoSection(
            profileImage: ride.user?.profilePicture ?? AppImages.sedan,
            userName: ride.user?.name ?? '',
            rating: ride.user?.rating ?? 4.5,
            carImage: ride.vehicle?.image ?? AppImages.sedan,
            carName: vehicleName,
            vehicleType: ride.vehicle?.numberPlate ?? '',
            // Default rating as it's not in the entity yet
            wantChatIcon: true,
            showTopBorder: false,
            showTrailing: true,
            showBadge: ref
                .watch(rideSocketProvider)
                .unreadChatDotForParticipant(ride.user?.id ?? ride.userId),
            onTrailing: () {
              final rideId = ride.id;
              final riderId = ride.user?.id ?? ride.userId ?? '';
              final riderName = (ride.user?.name.trim().isNotEmpty ?? false)
                  ? ride.user!.name.trim()
                  : 'Passenger';
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
        ).animate().fade(delay: 100.ms).slideX(begin: -0.08, end: 0),
        Divider(height: AppSizes.p20),

        Padding(
          padding: hp,
          child: InfoCard(
            title: context.l10n.pickup_location,
            description: ride.pickupPoint?.placeName ?? '',
            icon: AppIcons.locationFill,
            showTopBorder: false,
          ),
        ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 12),
        Padding(
          padding: hp,
          child: InfoCard(
            title: context.l10n.dropoff_location,
            description: ride.dropOffPointRequested?.placeName ?? '',
            icon: AppIcons.locationFill,
            showTopBorder: true,
          ),
        ).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0),
        SizedBox(height: AppSizes.p20),
        if (sr.isNotEmpty)
          Padding(
            padding: hp,
            child: InfoCard(showTopBorder: true, description: sr)
                .animate()
                .fade(delay: 350.ms)
                .scale(begin: const Offset(0.96, 0.96)),
          ),
        if (ride.pickupPoint != null)
          Padding(
            padding: hp.copyWith(bottom: 8),
            child: GoogleMapsNavigateButton(
              onPressed: () => openMapboxNavigation(
                context,
                ref: ref,
                destinationLat: ride.pickupPoint!.location.latitude,
                destinationLng: ride.pickupPoint!.location.longitude,
                destinationName: ride.pickupPoint!.placeName,
              ),
            ),
          ).animate().fade(delay: 400.ms).slideX(begin: 0.08, end: 0),
        Padding(
          padding: hp,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppButton(
                  fontColor: context.appColors.brand,
                  backgroundColor: context.appColors.border,
                  text: l10.cancel_ride,
                  onPressed: () => _onCancelRideTap(ride.id),
                ),
              ),
              const Gap(7),
              Expanded(
                child: AppButton(
                  backgroundColor: AppColors.brand,
                  text: l10.arrived,
                  onPressed: () => _markArrived(ride.id),
                ),
              ),
            ],
          ),
        ).animate().fade(delay: 500.ms).slideY(begin: 0.2, end: 0),
        SizedBox(height: AppSizes.p32),
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

  Future<void> _markArrived(String rideId) async {
    final position = await _locationService.getCurrentPosition();
    if (!mounted) return;

    if (position == null) {
      context.showToast(context.l10n.unable_to_get);
      return;
    }

    await ref
        .read(rideSocketProvider.notifier)
        .driverArriveAction(
          rideId,
          lat: position.latitude,
          lng: position.longitude,
        );
  }
}
