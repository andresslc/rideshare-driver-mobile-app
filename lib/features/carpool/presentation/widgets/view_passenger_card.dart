// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/navigation/routes.dart';
import 'package:driver_app/core/params/carpool_params.dart';
import 'package:driver_app/core/theme/app_colors.dart';
import 'package:driver_app/core/utils/toast_manager.dart';
import 'package:driver_app/features/carpool/domain/entities/view_carpool_passenger_entity.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_provider.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_socket_provider.dart';
import 'package:driver_app/features/carpool/presentation/states/carpool_socket_states.dart';
import 'package:driver_app/core/utils/ride_cancel_flow_helper.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:driver_app/features/ride_room/presentation/widgets/otp_verification_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:driver_app/shared/widgets/ride_driver_info.dart';
import 'package:driver_app/shared/widgets/verticle_location_stepper.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/strings_extensions.dart';

class ViewPassengerCard extends ConsumerStatefulWidget {
  final CarpoolPassengerEntity passenger;

  const ViewPassengerCard({super.key, required this.passenger});

  @override
  ConsumerState<ViewPassengerCard> createState() => _ViewPassengerCardState();
}

class _ViewPassengerCardState extends ConsumerState<ViewPassengerCard> {
  bool _isSubmitting = false;
  bool _isPicked = false;
  bool _isRideEnded = false;

  @override
  void initState() {
    super.initState();
    final normalizedStatus = widget.passenger.status.trim().toLowerCase();

    _isPicked = widget.passenger.otpVerified;

    _isRideEnded =
        normalizedStatus == 'completed' ||
        normalizedStatus == 'ended' ||
        normalizedStatus == 'dropped';
  }

  /// ================= PICK =================
  Future<void> _handlePickPassenger() async {
    final bookingId = widget.passenger.bookingId.trim();
    if (bookingId.isEmpty) {
      if (!mounted) return;
      context.showToast(context.l10n.booking_id_missing);
      return;
    }

    final otp = await showDialog<int>(
      barrierDismissible: false,
      context: context,
      builder: (_) => const OtpVerificationDialog(),
    );

    if (otp == null || !mounted) return;

    setState(() => _isSubmitting = true);

    final otpText = otp.toString().padLeft(6, '0');

    final success = await ref
        .read(carpoolSocketProvider.notifier)
        .pickPassengerByBookingId(bookingId: bookingId, otp: otpText);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    final socketState = ref.read(carpoolSocketProvider);

    context.showToast(
      success
          ? context.l10n.passenger_pick_success
          : (socketState.message ?? context.l10n.passenger_pick_failed),
    );

    if (success) {
      setState(() => _isPicked = true);
    }
  }

  /// ================= END RIDE =================
  Future<void> _handleEndRide() async {
    final bookingId = widget.passenger.bookingId.trim();

    if (bookingId.isEmpty) {
      if (!mounted) return;
      context.showToast(context.l10n.booking_id_missing);
      return;
    }

    final confirmed = await showDropPassengerConfirmation(context);
    if (!confirmed || !mounted) return;

    setState(() => _isSubmitting = true);

    await ref.read(carpoolSocketProvider.notifier).completeRide(bookingId);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    final socketState = ref.read(carpoolSocketProvider);

    final success =
        socketState.status == CarpoolSocketStatus.success &&
        socketState.action == CarpoolSocketAction.ridePassengerDrop;

    if (success) {
      setState(() => _isRideEnded = true);
    }

    if (mounted) {
      context.showToast(
        success
            ? context.l10n.ride_end_success
            : (socketState.message ?? context.l10n.ride_end_failed),
      );
    }
  }

  /// ================= REMOVE =================
  Future<void> _handleRemovePassenger() async {
    final bookingId = widget.passenger.bookingId.trim();

    if (bookingId.isEmpty) {
      if (!mounted) return;
      context.showToast(context.l10n.booking_id_missing);
      return;
    }

    // Capture provider refs before the async gap — the widget may unmount
    // once the passenger is removed from state.
    final carpoolNotifier = ref.read(carpoolProvider.notifier);
    final socketNotifier = ref.read(carpoolSocketProvider.notifier);
    final successMsg = context.l10n.passenger_removed_success;
    final failedMsg = context.l10n.passenger_removed_failed;

    setState(() => _isSubmitting = true);

    final removed = await ref
        .read(carpoolSocketProvider.notifier)
        .respondToIncomingRideRequest(
          BookingActionRequestParams(bookingId: bookingId, action: 'reject'),
        );

    // Remove from local state immediately on success — before any async gap
    // that could let a route_update re-fetch overwrite the removal.
    if (removed) {
      carpoolNotifier.removePassengerByBookingId(bookingId);
    }

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    final socketState = ref.read(carpoolSocketProvider);

    context.showToast(
      removed
          ? successMsg
          : (socketState.message ?? failedMsg),
      type: removed ? ToastType.success : ToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final socketState = ref.watch(carpoolSocketProvider);

    final rideStatus =
        (socketState.lastRideResume?['status'] ??
                socketState.lastRideResume?['type'] ??
                '')
            .toString()
            .trim()
            .toLowerCase();

    /// ================= FIXED LOGIC =================

    final isRideNotStarted =
        rideStatus == 'open' ||
        rideStatus == 'pending' ||
        rideStatus == 'full' ||
        rideStatus == 'waiting';

    final isRideStartedState =
        rideStatus == 'started' ||
        rideStatus == 'in_progress' ||
        rideStatus == 'in-progress' ||
        rideStatus == 'active';

    final isRideCompletedState =
        rideStatus == 'completed' ||
        rideStatus == 'ended' ||
        rideStatus == 'dropped';

    final canShowRemove = isRideNotStarted && !_isRideEnded;

    final canRemove = canShowRemove && !_isSubmitting;

    final showRideAction =
        (isRideStartedState ||
            socketState.isRideStarted ||
            socketState.hasActiveRide) &&
        !_isRideEnded &&
        !isRideCompletedState;

    /// ================= UI =================

    return AppGradientBox(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DriverInfoSection(
            showTopBorder: false,
            profileImage: widget.passenger.profilePicture ?? '',
            userName: widget.passenger.displayName.capitalised,
            rating: widget.passenger.rating,
            showTrailing: true,
            showBadge: ref
                .watch(rideSocketProvider)
                .unreadChatDotForCarpoolPassengerUser(
                  widget.passenger.id,
                  widget.passenger.userSignUpRecord,
                ),
            onTrailing: () {
              final rideId = widget.passenger.bookingId;
              final riderId = widget.passenger.id ?? '';

              if (rideId.isEmpty || riderId.isEmpty) return;

              ref
                  .read(rideSocketProvider.notifier)
                  .clearCarpoolChatBadgesForCanonKeys(<String>[
                    riderId,
                    if ((widget.passenger.userSignUpRecord ?? '')
                        .trim()
                        .isNotEmpty)
                      widget.passenger.userSignUpRecord!.trim(),
                  ]);
              context.pushNamed(
                Routes.chat.name,
                queryParameters: {
                  'rideId': rideId,
                  'riderId': riderId,
                  'riderName': widget.passenger.displayName,
                  'isCarpool': 'true',
                  if ((widget.passenger.profilePicture ?? '').trim().isNotEmpty)
                    'riderProfileImage': widget.passenger.profilePicture!
                        .trim(),
                },
              );
            },
            wantChatIcon: true,
          ),

          const Gap(10),

          VerticleLocationStepper(
            locationList: [widget.passenger.pickup, widget.passenger.dropOff],
          ),

          const Gap(14),

          if (canShowRemove)
            AppButton(
              fontColor: Colors.white,
              backgroundColor: AppColors.error,
              text: _isSubmitting
                  ? context.l10n.removing
                  : context.l10n.remove_passenger,
              onPressed: canRemove ? _handleRemovePassenger : null,
            )
          else if (showRideAction)
            AppButton(
              text: _isRideEnded
                  ? context.l10n.passenger_dropped
                  : _isSubmitting
                  ? (_isPicked ? context.l10n.dropping : context.l10n.picking)
                  : (_isPicked
                        ? context.l10n.drop_passenger
                        : context.l10n.pick_passenger),
              onPressed: _isSubmitting || _isRideEnded
                  ? null
                  : (_isPicked ? _handleEndRide : _handlePickPassenger),
            ),
        ],
      ),
    );
  }
}
