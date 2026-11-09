import 'dart:async';

import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/utils/ride_cancel_flow_helper.dart';
import 'package:driver_app/features/ride_history/presentation/widgets/info_card_widget.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:driver_app/features/ride_room/presentation/enums/ride_enum.dart';
import 'package:driver_app/features/ride_room/presentation/states/ride_state.dart';
import 'package:driver_app/features/ride_room/presentation/screens/drag_handler.dart';
import 'package:driver_app/features/ride_room/presentation/widgets/otp_verification_dialog.dart';
import 'package:driver_app/features/ride_room/presentation/widgets/plain_background_widget.dart';
import 'package:driver_app/shared/shared.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_images.dart';
import '../../../../shared/widgets/ride_driver_info.dart';
import '../../../../shared/widgets/ride_stats_row.dart';
import '../../../../shared/widgets/verticle_location_stepper.dart';

class ReachedPickupSheet extends ConsumerStatefulWidget {
  const ReachedPickupSheet({super.key});

  @override
  ConsumerState<ReachedPickupSheet> createState() => _ReachedPickupSheetState();
}

class _ReachedPickupSheetState extends ConsumerState<ReachedPickupSheet> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  Timer? _waitTimer;
  String? _trackedWaitRideId;
  DateTime? _trackedWaitStartedAt;

  static const double maxChildSize = 0.85;
  static const double minChildSize = 0.4;

  @override
  void dispose() {
    _waitTimer?.cancel();
    super.dispose();
  }

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

    _syncWaitTimer(rideState);

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
    final otp = (rideState.otp ?? ride.otp ?? '--').toString();
    final vehicleName = <String>[
      ride.vehicle?.name?.trim() ?? '',
      ride.vehicle?.model?.trim() ?? '',
    ].where((part) => part.isNotEmpty).join(' ').trim();
    // final String? otp = ride.otp?.trim().isNotEmpty == true ? ride.otp : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: hp,
          child: Text(
            l10.reached_pickup_point,
            style: context.textTheme.headlineMedium,
            textAlign: TextAlign.start,
          ),
        ).animate().fade(duration: 300.ms).slideY(begin: 0.2, end: 0),

        const SizedBox(height: 16),
        Divider(height: AppSizes.p20),
        Padding(
          padding: hp,
          child: DriverInfoSection(
            profileImage: ride.user?.profilePicture ?? AppImages.sedan,
            userName: userName,
            rating: ride.user?.rating ?? 0.0,
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
        ).animate().fade(delay: 250.ms).slideY(begin: 0.15, end: 0),
        Divider(height: AppSizes.p20),
        Padding(
          padding: hp,
          child: VerticleLocationStepper(
            showTopBorder: false,
            locationList: [pickupName, dropoffName],
            startTime: startTime,
          ),
        ).animate().fade(delay: 200.ms).slideY(begin: 0.15, end: 0),
        if (_shouldShowWaitBanner(rideState))
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: AppGradientBox(
              cornerRadius: 18,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.appColors.brand.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.timer_outlined,
                      color: context.appColors.brand,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10.wait_timer,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.appColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRemainingWaitTime(rideState),
                          style: context.textTheme.headlineSmall?.copyWith(
                            color:
                                _remainingWaitDuration(rideState) ==
                                    Duration.zero
                                ? context.colorScheme.error
                                : context.appColors.brand,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fade(delay: 350.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: AppSizes.p16),
        if (sr.isNotEmpty)
          Padding(
            padding: hp,
            child: InfoCard(showTopBorder: true, description: sr),
          ),
        Padding(
          padding: hp,
          child: RideStatsRow(
            totalTime: ride.averageTime.formatAvgTime(context),
            totalDistance:
                ride.rideDistance.formatDistance(decimalDigits: 2),
            // totalDistance: "${ride.rideDistance} KM",
            totalAmount: "\$${ride.payoutFare.toStringAsFixed(2)}",
          ),
        ).animate().fade(delay: 550.ms).slideY(begin: 0.1, end: 0),
        Divider(height: AppSizes.p20, endIndent: 16, indent: 16),
        const SizedBox(height: AppSizes.p20),

        Padding(
          padding: hp,
          child: AppButton(
            text: l10.start_ride,
            onPressed: () => _handleRideStart(ride.id, otp),
          ),
        ).animate().fade(delay: 250.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: AppSizes.p16),
        Padding(
          padding: hp,
          child: AppButton(
            fontColor: context.appColors.brand,
            backgroundColor: context.appColors.border,
            text: l10.cancel_ride,
            onPressed: () => _onCancelRideTap(ride.id),
          ),
        ).animate().fade(delay: 650.ms).slideY(begin: 0.2, end: 0),
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

  Future<void> _handleRideStart(String rideId, String? existingOtp) async {
    final int? otpValue = await _promptOtp(existingOtp: existingOtp);
    if (otpValue == null) return;

    await ref
        .read(rideSocketProvider.notifier)
        .rideStartAction(rideId: rideId, otp: otpValue);
  }

  Future<int?> _promptOtp({String? existingOtp}) async {
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return OtpVerificationDialog(
          length: 6,
          expectedOtp: (existingOtp ?? '').trim().isNotEmpty
              ? existingOtp
              : null,
        );
      },
    );
  }

  bool _shouldShowWaitBanner(RideSocketState rideState) {
    final ride = rideState.ride;
    final waitRideId = rideState.pickupWaitRideId?.trim() ?? '';
    if (ride == null || waitRideId.isEmpty) return false;
    if (ride.id.trim() != waitRideId) return false;
    return rideState.currentSheet == RideSheetsType.reachedPickup &&
        rideState.pickupWaitStartedAt != null;
  }

  void _syncWaitTimer(RideSocketState rideState) {
    if (!_shouldShowWaitBanner(rideState)) {
      _waitTimer?.cancel();
      _waitTimer = null;
      _trackedWaitRideId = null;
      _trackedWaitStartedAt = null;
      return;
    }

    final rideId = rideState.pickupWaitRideId?.trim();
    final startedAt = rideState.pickupWaitStartedAt;
    final bool rideChanged = _trackedWaitRideId != rideId;
    final bool startedChanged = _trackedWaitStartedAt != startedAt;
    if (rideId == null || startedAt == null) return;

    if (_waitTimer == null || rideChanged || startedChanged) {
      _trackedWaitRideId = rideId;
      _trackedWaitStartedAt = startedAt;
      _waitTimer?.cancel();
      _waitTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  Duration _remainingWaitDuration(RideSocketState rideState) {
    final startedAt = rideState.pickupWaitStartedAt;
    final duration = rideState.pickupWaitDuration;
    if (startedAt == null) return duration;

    final elapsed = DateTime.now().difference(startedAt);
    final remaining = duration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String _formatRemainingWaitTime(RideSocketState rideState) {
    final remaining = _remainingWaitDuration(rideState);
    final minutes = remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
