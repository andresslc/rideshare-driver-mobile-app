import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/extensions/double_extension.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/core/params/carpool_params.dart';
import 'package:driver_app/core/theme/app_colors.dart';
import 'package:driver_app/features/carpool/domain/entities/view_carpool_passenger_entity.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_provider.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_socket_provider.dart';
import 'package:driver_app/features/carpool/presentation/states/carpool_socket_states.dart';
import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:driver_app/shared/widgets/ride_driver_info.dart';
import 'package:driver_app/shared/widgets/ride_stats_row.dart';
import 'package:driver_app/shared/widgets/verticle_location_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class CarpoolRequestSheet extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBackToSearch;
  final ScrollController scrollController;
  final DateTime? startTime;
  final int? availableSeats;

  const CarpoolRequestSheet({
    super.key,
    required this.onNext,
    required this.onBackToSearch,
    required this.scrollController,
    this.startTime,
    this.availableSeats,
  });

  @override
  ConsumerState<CarpoolRequestSheet> createState() =>
      _CarpoolRequestSheetState();
}

class _CarpoolRequestSheetState extends ConsumerState<CarpoolRequestSheet> {
  String? _lastLoadedCarpoolId;
  final Set<String> _busyBookingIds = <String>{};
  bool _fetchScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _schedulePassengerSync();
    });
  }

  Future<void> _syncPassengersInternal({required bool force}) async {
    final carpoolId = _resolvedCarpoolId();
    if (carpoolId == null) {
      return;
    }
    if (!force && carpoolId == _lastLoadedCarpoolId) {
      return;
    }
    _lastLoadedCarpoolId = carpoolId;
    await ref.read(carpoolProvider.notifier).viewPassenger(carpoolId);
  }

  void _schedulePassengerSync({bool force = false}) {
    if (_fetchScheduled) {
      return;
    }
    _fetchScheduled = true;
    Future<void>(() async {
      _fetchScheduled = false;
      if (!mounted) {
        return;
      }
      await _syncPassengersInternal(force: force);
    });
  }

  String? _resolvedCarpoolId() {
    final socketState = ref.read(carpoolSocketProvider);
    final activeCarpoolId = socketState.activeCarpoolId?.trim();
    if (activeCarpoolId != null && activeCarpoolId.isNotEmpty) {
      return activeCarpoolId;
    }

    final payload = socketState.lastRideResume ?? const <String, dynamic>{};
    final fallbackId =
        (payload['carpoolId'] ?? payload['_id'] ?? payload['id'] ?? '')
            .toString()
            .trim();
    return fallbackId.isEmpty ? null : fallbackId;
  }

  Future<void> _reloadPassengers() async {
    final carpoolId = _resolvedCarpoolId();
    if (carpoolId == null) {
      return;
    }
    _lastLoadedCarpoolId = carpoolId;
    await ref.read(carpoolProvider.notifier).viewPassenger(carpoolId);
  }

  Future<void> _handleRequestAction({
    required CarpoolPassengerEntity passenger,
    required String action,
  }) async {
    final bookingId = passenger.bookingId.trim();
    if (bookingId.isEmpty) {
      if (!mounted) return;
      context.showToast(context.l10n.booking_id_missing);
      return;
    }

    setState(() {
      _busyBookingIds.add(bookingId);
    });

    final success = await ref
        .read(carpoolSocketProvider.notifier)
        .respondToIncomingRideRequest(
          BookingActionRequestParams(bookingId: bookingId, action: action),
        );

    if (success) {
      if (action == 'reject') {
        // Remove locally — no need to hit the API again.
        ref.read(carpoolProvider.notifier).removePassengerByBookingId(bookingId);
      } else {
        // Accept changes the status server-side, so reload.
        await _reloadPassengers();
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _busyBookingIds.remove(bookingId);
    });

    final socketState = ref.read(carpoolSocketProvider);
    if (!success) {
      context.showToast(
        socketState.message ??
            context.l10n.request_action_failed(
              action == 'accept'
                  ? context.l10n.accept.toLowerCase()
                  : context.l10n.reject.toLowerCase(),
            ),
      );
      return;
    }

    context.showToast(
      action == 'accept'
          ? context.l10n.request_accept_success
          : context.l10n.request_reject_success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colors = context.colorScheme;
    final l10n = context.l10n;
    ref.listen<CarpoolSocketState>(carpoolSocketProvider, (previous, next) {
      final previousIncomingBookingId = previous?.lastIncomingRequest?.bookingId
          .trim();
      final nextIncomingBookingId = next.lastIncomingRequest?.bookingId.trim();
      final previousCancelledBookingId = previous?.lastCancelledBookingId
          ?.trim();
      final nextCancelledBookingId = next.lastCancelledBookingId?.trim();
      final hasNewIncomingRequest =
          next.status == CarpoolSocketStatus.success &&
          next.action == CarpoolSocketAction.rideIncoming &&
          nextIncomingBookingId != null &&
          nextIncomingBookingId.isNotEmpty &&
          nextIncomingBookingId != previousIncomingBookingId;
      final hasCancelledBookingUpdate =
          nextCancelledBookingId != null &&
          nextCancelledBookingId.isNotEmpty &&
          nextCancelledBookingId != previousCancelledBookingId;

      if (hasNewIncomingRequest || hasCancelledBookingUpdate) {
        _schedulePassengerSync(force: true);
      }
    });
    final socketState = ref.watch(carpoolSocketProvider);
    final carpoolState = ref.watch(carpoolProvider);
    final passengers = carpoolState.passengers;
    final pendingPassengers = passengers
        .where((item) => item.status.trim().toLowerCase() == 'pending')
        .toList(growable: false);
    final acceptedPassengers = passengers
        .where((item) => item.status.trim().toLowerCase() == 'accepted')
        .toList(growable: false);
    final isLoading = carpoolState.isLoading && passengers.isEmpty;
    final carpoolId = _resolvedCarpoolId();

    _schedulePassengerSync();

    return RefreshIndicator(
      onRefresh: _reloadPassengers,
      child: ListView(
        controller: widget.scrollController,
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + context.padding.bottom),
        children: [
          Text(
            l10n.carpool_requests_title,
            style: textTheme.titleLarge,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.carpool_requests_counts(
              pendingPassengers.length,
              acceptedPassengers.length,
            ),
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (carpoolId == null)
            _InfoCard(message: l10n.carpool_missing_id)
          else if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            if (carpoolState.error != null && passengers.isEmpty)
              _InfoCard(message: carpoolState.error!),
            if (pendingPassengers.isNotEmpty) ...[
              _SectionHeader(
                title: l10n.carpool_pending_requests,
                count: pendingPassengers.length,
                color: colors.primary,
              ),
              const Gap(12),
              ...pendingPassengers.map((passenger) {
                final isBusy = _busyBookingIds.contains(passenger.bookingId);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PendingPassengerCard(
                    passenger: passenger,
                    onAccept: isBusy
                        ? null
                        : () => _handleRequestAction(
                            passenger: passenger,
                            action: 'accept',
                          ),
                    onReject: isBusy
                        ? null
                        : () => _handleRequestAction(
                            passenger: passenger,
                            action: 'reject',
                          ),
                  ),
                );
              }),
            ] else
              _InfoCard(message: l10n.carpool_no_pending),
            const Gap(16),
            if (acceptedPassengers.isNotEmpty) ...[
              _SectionHeader(
                title: l10n.carpool_accepted_passengers,
                count: acceptedPassengers.length,
                color: Colors.green,
              ),
              const Gap(12),
              ...acceptedPassengers.map(
                (passenger) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AcceptedPassengerCard(passenger: passenger),
                ),
              ),
            ] else
              _InfoCard(message: l10n.carpool_no_accepted),
            if (carpoolState.error != null && passengers.isNotEmpty) ...[
              const Gap(12),
              Text(
                carpoolState.error!,
                style: textTheme.bodySmall?.copyWith(color: colors.error),
              ),
            ],
            if (acceptedPassengers.isNotEmpty &&
                !socketState.hasActiveRide &&
                !socketState.isRideStarted) ...[
              const Gap(16),
              AppButton(
                text: l10n.carpool_continue_progress,
                onPressed: widget.onNext,
              ),
            ],
            const Gap(12),
            AppButton(
              text: l10n.carpool_back_to_search,
              // backgroundColor: AppColors.brandLight,
              backgroundColor: context.appColors.border,

              fontColor: context.appColors.brand,
              onPressed: widget.onBackToSearch,
            ),
          ],
        ],
      ),
    );
  }
}

class _PendingPassengerCard extends StatelessWidget {
  final CarpoolPassengerEntity passenger;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _PendingPassengerCard({
    required this.passenger,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final distanceText = passenger.distance == null
        ? '--'
        : '${passenger.distance!.toStringAsFixed(2)} ${context.l10n.miles}';

    return AppGradientBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DriverInfoSection(
            showTopBorder: false,
            profileImage: passenger.profilePicture ?? '',
            userName: passenger.displayName,
            rating: passenger.rating,
          ),
          const Gap(10),
          VerticleLocationStepper(
            locationList: [passenger.pickup, passenger.dropOff],
          ),
          if (passenger.requiredSeats != null) ...[
            const Gap(8),
            _PassengerCountRow(passengerCount: passenger.requiredSeats!),
          ],
          const Gap(8),
          RideStatsRow(
            totalDistance: distanceText,
            totalAmount: '\$${passenger.fareCharged.toStringAsFixed(2)}',
          ),
          const Gap(14),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  backgroundColor: context.colorScheme.error,
                  text: context.l10n.reject,
                  fontColor: context.colorScheme.onPrimary,
                  onPressed: onReject,
                ),
              ),
              const Gap(12),
              Expanded(
                child: AppButton(
                  text: context.l10n.accept,
                  onPressed: onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AcceptedPassengerCard extends StatelessWidget {
  final CarpoolPassengerEntity passenger;

  const _AcceptedPassengerCard({required this.passenger});

  @override
  Widget build(BuildContext context) {
    final distanceText = passenger.distance == null
        ? '--'
        : '${passenger.distance!.toStringAsFixed(2)} ${context.l10n.miles}';
    final avgTimeText = passenger.avgTime == null
        ? '--'
        : passenger.avgTime!.formatAvgTime(context);

    return AppGradientBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DriverInfoSection(
                  showTopBorder: false,
                  profileImage: passenger.profilePicture ?? '',
                  userName: passenger.displayName,
                  rating: passenger.rating,
                ),
              ),
              const Gap(12),
              _StatusChip(
                label: passenger.otpVerified
                    ? context.l10n.otp_verified
                    : context.l10n.accepted,
                backgroundColor: context.appColors.brand.withValues(
                  alpha: 0.14,
                ),
                foregroundColor: context.appColors.brand,
              ),
            ],
          ),
          const Gap(10),
          VerticleLocationStepper(
            locationList: [passenger.pickup, passenger.dropOff],
          ),
          if (passenger.requiredSeats != null) ...[
            const Gap(8),
            _PassengerCountRow(passengerCount: passenger.requiredSeats!),
          ],
          const Gap(8),
          RideStatsRow(
            padding: EdgeInsets.all(0),
            totalTime: avgTimeText,
            totalDistance: distanceText,
            totalAmount: '\$${passenger.fareCharged.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }
}

class _PassengerCountRow extends StatelessWidget {
  final int passengerCount;

  const _PassengerCountRow({required this.passengerCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.l10n.no_of_passengers,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          passengerCount.toString(),
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _StatusChip(
          label: count.toString(),
          backgroundColor: color.withValues(alpha: 0.12),
          foregroundColor: color,
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const _StatusChip({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String message;

  const _InfoCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return AppGradientBox(
      padding: const EdgeInsets.all(16),
      child: Text(
        message,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
