import 'package:geolocator/geolocator.dart';
import 'package:driver_app/core/core.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_socket_provider.dart';
import 'package:driver_app/l10n/app_localizations.dart';
import 'package:driver_app/shared/screens/place_picker_screen.dart';
import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/params/carpool_params.dart';
import '../../../../shared/widgets/custom_tap.dart';

class RideStartTimeSeatSheet extends ConsumerStatefulWidget {
  final List<SelectedLocation?> stops;
  final double avgTime;
  final double distanceMiles;
  final ScrollController scrollController;
  final VoidCallback onNext;
  final void Function(DateTime startTime, int availableSeats)?
  onSelectionConfirmed;

  const RideStartTimeSeatSheet({
    super.key,
    required this.stops,
    required this.avgTime,
    required this.distanceMiles,
    required this.scrollController,
    required this.onNext,
    this.onSelectionConfirmed,
  });

  @override
  ConsumerState<RideStartTimeSeatSheet> createState() =>
      _RideStartTimeSeatSheetState();
}

class _RideStartTimeSeatSheetState
    extends ConsumerState<RideStartTimeSeatSheet> {
  static const Duration _maximumLeadTime = Duration(hours: 1);

  static const int _maxSeatCount = 8;
  final ValueNotifier<int> _passengerCountNotifier = ValueNotifier<int>(1);

  int get passengerCount => _passengerCountNotifier.value;

  int selectedMinute = 5;
  DateTime? _selectedStartTime;

  bool isTimeSelected = false;

  DateTime get _maximumAllowedStartTime => DateTime.now().add(_maximumLeadTime);

  bool _isWithinMaximumLeadTime(DateTime selectedStartTime) {
    final now = DateTime.now();
    return selectedStartTime.isAfter(now) &&
        !selectedStartTime.isAfter(_maximumAllowedStartTime);
  }

  void _openTimePicker() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: AppGradientBox(
          cornerRadius: 16,
          child: SizedBox(
            height: 320,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  l10n.selectTime,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      final nextMinute = index + 1;
                      if (selectedMinute == nextMinute) {
                        return;
                      }
                      selectedMinute = nextMinute;
                      HapticFeedback.lightImpact();
                    },
                    children: List.generate(
                      59,
                      (i) => Center(child: Text("${i + 1} ${l10n.min}")),
                    ),
                  ),
                ),
                const Divider(),
                TextButton(
                  onPressed: () {
                    final selected = DateTime.now().add(
                      Duration(minutes: selectedMinute),
                    );
                    if (!_isWithinMaximumLeadTime(selected)) {
                      context.showToast(l10n.start_time_within_hour);
                      return;
                    }

                    setState(() {
                      _selectedStartTime = selected;
                      isTimeSelected = true;
                    });

                    Navigator.pop(context);
                  },
                  child: Text(l10n.done),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime _resolvedStartTime() {
    return _selectedStartTime ??
        DateTime.now().add(Duration(minutes: selectedMinute));
  }

  // String _formatStartTime(DateTime dateTime) {
  //   final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  //   final minute = dateTime.minute.toString().padLeft(2, '0');
  //   final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  //   return '$hour:$minute $period';
  // }

  void _increment() {
    if (passengerCount >= _maxSeatCount) {
      return;
    }
    _passengerCountNotifier.value = passengerCount + 1;
  }

  void _decrement() {
    if (passengerCount > 1) {
      _passengerCountNotifier.value = passengerCount - 1;
    }
  }

  @override
  void dispose() {
    _passengerCountNotifier.dispose();
    super.dispose();
  }

  CarpoolRideParams getCarpoolParams(double farePerSeat) {
    final start = widget.stops.first!;
    final end = widget.stops.last!;

    final intermediateStops = widget.stops
        .sublist(1, widget.stops.length - 1)
        .whereType<SelectedLocation>()
        .toList();

    final List<RoutePoint> routes = [];

    routes.add(
      RoutePoint(
        placeName: start.formattedAddress,
        coordinates: [start.longitude, start.latitude],
        order: 1,
      ),
    );

    for (var i = 0; i < intermediateStops.length; i++) {
      final stop = intermediateStops[i];

      routes.add(
        RoutePoint(
          placeName: stop.formattedAddress,
          coordinates: [stop.longitude, stop.latitude],
          order: i + 2,
        ),
      );
    }

    routes.add(
      RoutePoint(
        placeName: end.formattedAddress,
        coordinates: [end.longitude, end.latitude],
        order: routes.length + 1,
      ),
    );

    return CarpoolRideParams(
      startingPointName: start.formattedAddress,
      startingPointCoordinates: [start.longitude, start.latitude],
      destinationName: end.formattedAddress,
      destinationCoordinates: [end.longitude, end.latitude],
      routes: routes,
      avgTime: widget.avgTime,
      distance: widget.distanceMiles,
      maxPassengers: passengerCount,
      farePerSeat: farePerSeat,
      graceTime: _resolvedStartTime(),
    );
  }

  @override
  Widget build(BuildContext context) {
    log("~~~~~~~~~~~~");
    final textTheme = context.textTheme;
    final colors = context.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Text(l10n.rideStartTimeSeats, style: textTheme.titleLarge),

        const SizedBox(height: 12),

        Text(
          l10n.whenStartRide,
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),

        const SizedBox(height: 8),
        Divider(color: colors.outlineVariant),

        Text(
          l10n.chooseStartTime,
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.selectStartTime,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            CustomTap(
              onTap: _openTimePicker,
              child: Row(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Icon(
                    CupertinoIcons.clock_solid,
                    size: 20,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isTimeSelected
                        ? _resolvedStartTime().formatRideDate(
                            context,
                            timeOnly: true,
                          )
                        : "00:00",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        Divider(color: colors.outlineVariant),

        Text(
          l10n.howManyPassengers,
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),

        const SizedBox(height: 8),

        Text(
          l10n.numberPassengers,
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),

        const SizedBox(height: 8),

        ValueListenableBuilder<int>(
          valueListenable: _passengerCountNotifier,
          builder: (context, passengerCount, _) {
            return Row(
              children: [
                CustomTap(
                  onTap: _decrement,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: AppColors.brandLight,
                    child: Icon(Icons.remove, color: colors.primary, size: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    passengerCount.toString(),
                    style: textTheme.titleMedium,
                  ),
                ),
                CustomTap(
                  onTap: _increment,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: AppColors.brandLight,
                    child: Icon(Icons.add, color: colors.primary, size: 18),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 8),

        Text(
          l10n.vehicleSeatLimit,
          style: textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),

        const SizedBox(height: 16),

        AppButton(
          text: l10n.continueSearch,
          onPressed: () async {
            if (!isTimeSelected) {
              context.showToast(l10n.select_time_valid);
              return;
            }
            if (passengerCount < 1) {
              context.showToast(l10n.minimumSeatRequired);
              return;
            }
            final selectedStartTime = _resolvedStartTime();
            if (!_isWithinMaximumLeadTime(selectedStartTime)) {
              context.showToast(l10n.start_time_within_hour);
              return;
            }
            // Validate stops sequence
            if (widget.stops.length < 2) {
              context.showToast('Please select pickup and drop-off locations.');
              return;
            }

            // Check if round trip without intermediate stops
            if (widget.stops.length == 2) {
              final start = widget.stops.first;
              final end = widget.stops.last;
              if (start != null &&
                  end != null &&
                  (start.formattedAddress.trim().toLowerCase() ==
                          end.formattedAddress.trim().toLowerCase() ||
                      Geolocator.distanceBetween(
                            start.latitude,
                            start.longitude,
                            end.latitude,
                            end.longitude,
                          ) <
                          50)) {
                context.showToast(
                  'Please add at least one intermediate stop for a round trip.',
                );
                return;
              }
            }

            // Check consecutive stops
            for (var i = 0; i < widget.stops.length - 1; i++) {
              final current = widget.stops[i];
              final next = widget.stops[i + 1];
              if (current != null &&
                  next != null &&
                  (current.formattedAddress.trim().toLowerCase() ==
                          next.formattedAddress.trim().toLowerCase() ||
                      Geolocator.distanceBetween(
                            current.latitude,
                            current.longitude,
                            next.latitude,
                            next.longitude,
                          ) <
                          50)) {
                context.showToast(
                  'Consecutive stops cannot be the same location.',
                );
                return;
              }
            }

            widget.onSelectionConfirmed?.call(
              selectedStartTime,
              passengerCount,
            );
            final params = getCarpoolParams(50.0);
            final created = await ref
                .read(carpoolSocketProvider.notifier)
                .createRoute(params);
            if (!context.mounted) return;
            if (created) {
              widget.onNext();
              return;
            }

            final socketState = ref.read(carpoolSocketProvider);
            final message =
                socketState.message ?? l10n.unable_to_create_carpool_route;
            context.showToast(message);
          },
        ),
      ],
    );
  }
}
