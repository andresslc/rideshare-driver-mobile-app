import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/extensions/strings_extensions.dart';
import 'package:driver_app/core/extensions/num_extension.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_socket_provider.dart';
import 'package:driver_app/features/carpool/presentation/widgets/location_step_widget.dart';
import 'package:driver_app/l10n/app_localizations.dart';
import 'package:driver_app/shared/screens/place_picker_screen.dart';
import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:driver_app/shared/widgets/custom_dialogue.dart';
import 'package:driver_app/shared/widgets/verticle_location_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/double_extension.dart';
import '../states/carpool_socket_states.dart';

class SearchCarpoolRideSheet extends ConsumerStatefulWidget {
  final List<SelectedLocation?> stops; // receive stops from previous screen
  final DateTime? startTime;
  final int? availableSeats;
  final VoidCallback onNext;
  final VoidCallback onGoToRideProgress;
  final ScrollController scrollController;

  const SearchCarpoolRideSheet({
    super.key,
    required this.stops,
    this.startTime,
    this.availableSeats,
    required this.onNext,
    required this.onGoToRideProgress,
    required this.scrollController,
  });

  @override
  ConsumerState<SearchCarpoolRideSheet> createState() =>
      _SearchCarpoolRideSheetState();
}

class _SearchCarpoolRideSheetState
    extends ConsumerState<SearchCarpoolRideSheet> {
  @override
  Widget build(BuildContext context) {
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';

    final textTheme = context.textTheme;
    final colors = context.colorScheme;
    final l10n = context.l10n;
    final carpoolState = ref.watch(carpoolSocketProvider);
    final requestCount = carpoolState.incomingRequestCount;
    final payload = carpoolState.lastRideResume ?? const <String, dynamic>{};
    final isCancelling =
        carpoolState.status == CarpoolSocketStatus.loading &&
        carpoolState.action == CarpoolSocketAction.rideCancel;

    final startTimeText = widget.startTime == null
        ? '--:--'
        : widget.startTime!.formatRideDate(context, timeOnly: true);
    final availableSeatsText = widget.availableSeats == null
        ? '--'
        : '${widget.availableSeats} Seats';
    final avgTime = _readDouble(payload['avgTime']);
    final distance = _readDouble(payload['distance']);
    final avgTimeText = avgTime == null
        ? '--'
        : (avgTime).formatAvgTime(context);
    // final distanceText = distance == null ? '--' : _formatDistance(distance);
    // final avgTimeText = avgTime == null ? '--' : _formatAvgTime(avgTime);
    final distanceText = distance == null
        ? '--'
        : "${distance.toStringAsFixed(2)} ${context.l10n.miles}";

    final locations = widget.stops
        .map((e) => e?.formattedAddress ?? '')
        .toList();
    // distance.formatDistance();

    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + context.padding.bottom),
      children: [
        Text(
          l10n.search_carpool_title,
          style: textTheme.titleLarge,

          textAlign: TextAlign.start,
        ),
        // Divider(color: colors.outlineVariant),
        Divider(),
        const SizedBox(height: 4),

        // Display all stops passed from previous screen
        VerticleLocationStepper(
          showTopBorder: false,
          locationList: locations,
          // backgroundColor: colors.background,
        ),

        // const SizedBox(height: 4),
        Divider(),
        const SizedBox(height: 4),

        // Ride Start Time
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.ride_start_time_label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              startTimeText,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Divider(),
        const SizedBox(height: 4),

        // Available Seats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.available_seats_label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              availableSeatsText,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Divider(),
        const SizedBox(height: 4),

        // Avg Time & Distance
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Avg. Time left
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // "Avg. Time",
                  context.l10n.avg_time,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  avgTimeText,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Vertical Divider
            Container(height: 48, width: 1.5, color: context.appColors.border),

            // Total Distance right
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.total_distance_label,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  distanceText,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        Divider(),

        // Search Status
        Row(
          children: [
            Text(
              l10n.requests_found(requestCount),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),
        // Buttons
        Row(
          children: [
            Expanded(
              child: AppButton(
                // TODO: Disable if no requests found after search completes
                // isDisable: requestCount == 0,
                onPressed: widget.onNext,
                text: l10n.view_requests(requestCount),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                text: AppLocalizations.of(context)!.go_to_ride_progress,

                fontColor: context.appColors.brand,
                backgroundColor: context.appColors.border,
                onPressed: widget.onGoToRideProgress,
                // text: l10n.go_to_ride_progress,
                fontSize: isSpanish ? 12 : 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            fontColor: context.appColors.brand,
            backgroundColor: context.appColors.border,

            text: isCancelling
                ? context.l10n.cancelling
                : context.l10n.cancel_carpool,

            // 'Cancel Carpool',
            onPressed: isCancelling
                ? null
                : () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => CustomDialogue(
                        title: context.l10n.confirm,
                        subtitle: context.l10n.cancel_ride_confirmation,
                        icon: Icons.warning_amber_rounded,
                        buttons: [
                          AppButton(
                            text: context.l10n.no,
                            onPressed: () => Navigator.pop(context, false),
                            backgroundColor: context.appColors.border,
                            fontColor: context.appColors.brand,
                          ),
                          AppButton(
                            text: context.l10n.yes,
                            onPressed: () => Navigator.pop(context, true),
                            backgroundColor: context.colorScheme.error,
                            fontColor: AppColors.textcolor,
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    final cancelled = await ref
                        .read(carpoolSocketProvider.notifier)
                        .cancelCurrentRoute();
                    if (!context.mounted || cancelled) {
                      return;
                    }

                    final message =
                        ref.read(carpoolSocketProvider).message ??
                        l10n.unable_cancel_carpool;
                    context.showToast(message);
                  },
            // backgroundColor: colors.error,
            // fontColor: colors.onError,
          ),
        ),
      ],
    );
  }

  String _formatStartTime(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    final hour = localDateTime.hour % 12 == 0 ? 12 : localDateTime.hour % 12;
    final minute = localDateTime.minute.toString().padLeft(2, '0');
    final period = localDateTime.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  // String _formatDistance(double kilometers) {
  //   const kmToMiles = 0.621371;
  //   final miles = kilometers * kmToMiles;
  //   return '${miles.toStringAsFixed(2)} ${context.l10n.miles}';
  // }
  // String _formatAvgTime(double minutes) {
  //   final totalMinutes = minutes.round();
  //   final hours = totalMinutes ~/ 60;
  //   final remainingMinutes = totalMinutes % 60;
  //   if (hours <= 0) {
  //     return '${remainingMinutes} min';
  //   }
  //   if (remainingMinutes == 0) {
  //     return '${hours} hr';
  //   }
  //   return '${hours} hr ${remainingMinutes} min';
  // }

  double? _readDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim());
    }
    return null;
  }
}
