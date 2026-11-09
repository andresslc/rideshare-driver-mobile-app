// import 'package:driver_app/core/core.dart';
// import 'package:driver_app/core/extensions/context_extension.dart';
// import 'package:driver_app/core/extensions/theme_extension.dart';
// import 'package:driver_app/core/navigation/routes.dart';
// import 'package:driver_app/features/carpool/presentation/providers/carpool_socket_provider.dart';
// import 'package:driver_app/shared/screens/place_picker_screen.dart';
// import 'package:driver_app/shared/widgets/app_button.dart';
// import 'package:driver_app/shared/widgets/custom_dialogue.dart';
// import 'package:driver_app/shared/widgets/custom_tap.dart';
// import 'package:driver_app/shared/widgets/verticle_location_stepper.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';

// class CarpoolRideProgressSheet extends ConsumerWidget {
//   final ScrollController scrollController;
//   final List<SelectedLocation?> routeStops;
//   final DateTime? startTime;
//   final int? availableSeats;

//   const CarpoolRideProgressSheet({
//     super.key,
//     required this.scrollController,
//     required this.routeStops,
//     this.startTime,
//     this.availableSeats,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(carpoolSocketProvider);
//     final notifier = ref.read(carpoolSocketProvider.notifier);

//     final carpoolId = state.activeCarpoolId ?? '';
//     final stops = state.stopProgress;
//     final ridePayload = state.lastRideResume ?? const <String, dynamic>{};

//     final pickupAddress = _locationLabel(ridePayload['startingPoint']);
//     final dropoffAddress = _locationLabel(ridePayload['destination']);

//     final List<String> locations = [
//       if (pickupAddress != null && pickupAddress.isNotEmpty) pickupAddress,
//       ...stops.map((e) => e.stopName),
//       if (dropoffAddress != null && dropoffAddress.isNotEmpty) dropoffAddress,
//     ];

//     final canStartRide = carpoolId.isNotEmpty && state.hasAcceptedPassengers;
//     final l10n = context.l10n;

//     return ListView(
//       controller: scrollController,
//       padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + context.padding.bottom),
//       children: [
//         Text(l10n.ride_in_progress, style: context.textTheme.titleLarge),

//         const SizedBox(height: 12),

//         if (locations.isNotEmpty)
//           VerticleLocationStepper(
//             locationList: locations,
//             backgroundColor: context.colorScheme.surface,
//           )
//         else
//           Text(l10n.ride_progress_no_route),

//         const Divider(height: 24),

//         /// Start Time
//         _infoRow(
//           context,
//           l10n.start_time_label,
//           startTime != null
//               ? startTime!.formatRideDate(context, timeOnly: true)
//               : "--",
//         ),

//         /// Seats
//         _infoRow(
//           context,
//           l10n.available_seats,
//           availableSeats != null ? "$availableSeats" : "--",
//         ),

//         /// Distance
//         _infoRow(
//           context,
//           l10n.total_distance_label,
//           "${(state.lastRideResume?['distance'] as num?)?.toStringAsFixed(2)} ${context.l10n.miles}",
//         ),

//         const Divider(height: 24),

//         /// View passengers
//         CustomTap(
//           onTap: () {
//             if (carpoolId.isNotEmpty) {
//               context.pushNamed(
//                 Routes.passengerList.name,
//                 extra: {"carpoolId": carpoolId},
//               );
//             }
//           },
//           child: Text(
//             l10n.viewPassenger,
//             style: context.textTheme.bodyMedium?.copyWith(
//               color: context.colorScheme.primary,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),

//         const Divider(height: 24),

//         /// Buttons
//         if (!state.hasActiveRide)
//           Column(
//             children: [
//               AppButton(
//                 onPressed: canStartRide
//                     ? () => notifier.startRide(carpoolId)
//                     : null,
//                 text: l10n.start_ride,
//               ),

//               if (!state.hasAcceptedPassengers) ...[
//                 const SizedBox(height: 8),
//                 Text(
//                   l10n.accept_one_passenger_hint,
//                   style: context.textTheme.bodySmall?.copyWith(
//                     color: context.colorScheme.error,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],

//               const SizedBox(height: 10),

//               /// Cancel Ride
//               AppButton(
//                 fontColor: context.appColors.brand,
//                 backgroundColor: context.appColors.border,
//                 onPressed: carpoolId.isNotEmpty
//                     ? () async {
//                         final confirm = await showDialog<bool>(
//                           context: context,
//                           builder: (context) => CustomDialogue(
//                             title: context.l10n.confirm,
//                             subtitle: context.l10n.cancel_ride_confirmation,
//                             icon: Icons.warning_amber_rounded,
//                             buttons: [
//                               AppButton(
//                                 text: context.l10n.no,
//                                 onPressed: () => Navigator.pop(context, false),
//                                 fontColor: context.appColors.brand,
//                                 backgroundColor: context.appColors.border,
//                               ),
//                               AppButton(
//                                 text: context.l10n.yes,
//                                 onPressed: () => Navigator.pop(context, true),
//                                 backgroundColor: context.colorScheme.error,
//                                 fontColor: AppColors.textcolor,
//                               ),
//                             ],
//                           ),
//                         );

//                         if (confirm == true) {
//                           notifier.cancelRide(carpoolId);
//                         }
//                       }
//                     : null,
//                 text: l10n.cancel_carpool,
//               ),
//             ],
//           )
//         else
//           Column(
//             children: [
//               AppButton(
//                 fontColor: context.colorScheme.onError,
//                 backgroundColor: context.colorScheme.error,
//                 onPressed: () async {
//                   final confirm = await showDialog<bool>(
//                     context: context,
//                     builder: (context) => CustomDialogue(
//                       title: context.l10n.confirm,
//                       subtitle: context.l10n.cancel_ride_confirmation,
//                       icon: Icons.warning_amber_rounded,
//                       buttons: [
//                         AppButton(
//                           text: context.l10n.no,
//                           onPressed: () => Navigator.pop(context, false),
//                           fontColor: context.appColors.brand,
//                           backgroundColor: context.appColors.border,
//                         ),
//                         AppButton(
//                           text: context.l10n.yes,
//                           onPressed: () => Navigator.pop(context, true),
//                           backgroundColor: context.colorScheme.error,
//                           fontColor: AppColors.textcolor,
//                         ),
//                       ],
//                     ),
//                   );
//                   if (confirm == true && carpoolId.isNotEmpty) {
//                     await notifier.cancelRide(carpoolId);
//                   }
//                 },
//                 text: l10n.cancel_ride,
//               ),
//               const SizedBox(height: 10),
//               if (kDebugMode) ...[
//                 AppButton(
//                   onPressed:
//                       (carpoolId.isNotEmpty &&
//                           state.currentStop?.routeStopId != null)
//                       ? () => notifier.arriveAtStop(
//                           routeStopId: state.currentStop!.routeStopId!,
//                           carpoolId: carpoolId,
//                         )
//                       : null,
//                   text: l10n.arrive_at_stop(state.currentStopIndex + 1),
//                 ),
//                 const SizedBox(height: 10),
//               ],

//               AppButton(
//                 fontColor: context.appColors.brand,
//                 backgroundColor: context.appColors.border,
//                 onPressed: carpoolId.isNotEmpty
//                     ? () {
//                         context.pushNamed(
//                           Routes.passengerList.name,
//                           extra: {"carpoolId": carpoolId},
//                         );
//                       }
//                     : null,
//                 text: l10n.drop_off_passengers,
//               ),

//               const SizedBox(height: 10),
//             ],
//           ),
//       ],
//     );
//   }

//   Widget _infoRow(BuildContext context, String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title, style: context.textTheme.bodyMedium),
//           Text(value, style: context.textTheme.bodyMedium),
//         ],
//       ),
//     );
//   }

//   String _formatTime(DateTime dateTime) {
//     final localDateTime = dateTime.toLocal();
//     final hour = localDateTime.hour % 12 == 0 ? 12 : localDateTime.hour % 12;
//     final minute = localDateTime.minute.toString().padLeft(2, '0');
//     final period = localDateTime.hour >= 12 ? 'PM' : 'AM';
//     return "$hour:$minute $period";
//   }

//   String? _locationLabel(dynamic rawStop) {
//     if (rawStop is! Map) return null;

//     final stop = Map<String, dynamic>.from(rawStop);
//     final label = (stop['placeName'] ?? stop['name'] ?? '').toString().trim();

//     return label.isEmpty ? null : label;
//   }
// }
import 'package:driver_app/core/core.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_socket_provider.dart';
import 'package:driver_app/shared/screens/place_picker_screen.dart';
import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:driver_app/shared/widgets/custom_dialogue.dart';
import 'package:driver_app/shared/widgets/verticle_location_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CarpoolRideProgressSheet extends ConsumerWidget {
  final ScrollController scrollController;
  final List<SelectedLocation?> routeStops;
  final DateTime? startTime;
  final int? availableSeats;

  const CarpoolRideProgressSheet({
    super.key,
    required this.scrollController,
    required this.routeStops,
    this.startTime,
    this.availableSeats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(carpoolSocketProvider);
    final notifier = ref.read(carpoolSocketProvider.notifier);

    final carpoolId = state.activeCarpoolId ?? '';
    final stops = state.stopProgress;
    final ridePayload = state.lastRideResume ?? const <String, dynamic>{};

    final pickupAddress = _locationLabel(ridePayload['startingPoint']);
    final dropoffAddress = _locationLabel(ridePayload['destination']);

    final List<String> locations = [
      if (pickupAddress != null && pickupAddress.isNotEmpty) pickupAddress,
      ...stops.map((e) => e.stopName),
      if (dropoffAddress != null && dropoffAddress.isNotEmpty) dropoffAddress,
    ];

    final canStartRide = carpoolId.isNotEmpty && state.hasAcceptedPassengers;
    final l10n = context.l10n;

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + context.padding.bottom),
      children: [
        Text(l10n.ride_in_progress, style: context.textTheme.titleLarge),

        const SizedBox(height: 12),

        if (locations.isNotEmpty)
          VerticleLocationStepper(
            locationList: locations,
            // backgroundColor: context.colorScheme.surface,
          )
        else
          Text(l10n.ride_progress_no_route),

        const Divider(height: 24),

        /// Start Time
        _infoRow(
          context,
          l10n.start_time_label,
          startTime != null
              ? startTime!.formatRideDate(context, timeOnly: true)
              : "--",
        ),

        /// Seats
        _infoRow(
          context,
          l10n.available_seats,
          availableSeats != null ? "$availableSeats" : "--",
        ),

        /// Distance
        _infoRow(
          context,
          l10n.total_distance_label,
          "${(state.lastRideResume?['distance'] as num?)?.toStringAsFixed(2)} ${context.l10n.miles}",
        ),

        // const Divider(height: 24),

        // ============================================================
        // View Passengers
        // Commented out as requested.
        // Now the same functionality is handled by the
        // "View Passenger" button below.
        // ============================================================

        // CustomTap(
        //   onTap: () {
        //     if (carpoolId.isNotEmpty) {
        //       context.pushNamed(
        //         Routes.passengerList.name,
        //         extra: {"carpoolId": carpoolId},
        //       );
        //     }
        //   },
        //   child: Text(
        //     l10n.viewPassenger,
        //     style: context.textTheme.bodyMedium?.copyWith(
        //       color: context.colorScheme.primary,
        //       fontWeight: FontWeight.w600,
        //     ),
        //   ),
        // ),
        const Divider(height: 24),

        /// Buttons
        if (!state.hasActiveRide)
          Column(
            children: [
              const SizedBox(height: 10),

              AppButton(
                onPressed: canStartRide
                    ? () => notifier.startRide(carpoolId)
                    : null,
                text: l10n.start_ride,
              ),

              if (!state.hasAcceptedPassengers) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.accept_one_passenger_hint,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 10),

              /// Cancel Ride
              AppButton(
                fontColor: context.appColors.brand,
                backgroundColor: context.appColors.border,
                onPressed: carpoolId.isNotEmpty
                    ? () async {
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
                                fontColor: context.appColors.brand,
                                backgroundColor: context.appColors.border,
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

                        if (confirm == true) {
                          notifier.cancelRide(carpoolId);
                        }
                      }
                    : null,
                text: l10n.cancel_carpool,
              ),
            ],
          )
        else
          Column(
            children: [
              AppButton(
                // fontColor: Colors.white,
                // backgroundColor: context.appColors.brand,
                onPressed: carpoolId.isNotEmpty
                    ? () {
                        context.pushNamed(
                          Routes.passengerList.name,
                          extra: {"carpoolId": carpoolId},
                        );
                      }
                    : null,
                text: l10n.viewPassenger,
              ),
              const SizedBox(height: 10),

              AppButton(
                fontColor: AppColors.textcolor,
                backgroundColor: context.colorScheme.error,
                onPressed: () async {
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
                          fontColor: context.appColors.brand,
                          backgroundColor: context.appColors.border,
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

                  if (confirm == true && carpoolId.isNotEmpty) {
                    await notifier.cancelRide(carpoolId);
                  }
                },
                text: l10n.cancel_ride,
              ),

              // ========================================================
              // Arrive Stop
              // ========================================================

              // if (kDebugMode) ...[
              //   AppButton(
              //     onPressed:
              //         (carpoolId.isNotEmpty &&
              //                 state.currentStop?.routeStopId != null)
              //             ? () => notifier.arriveAtStop(
              //                 routeStopId:
              //                     state.currentStop!.routeStopId!,
              //                 carpoolId: carpoolId,
              //               )
              //             : null,
              //     text: l10n.arrive_at_stop(
              //       state.currentStopIndex + 1,
              //     ),
              //   ),
              //   const SizedBox(height: 10),
              // ],

              /// View Passenger
              /// Same functionality that was previously on
              /// the Drop Passenger button.
              const SizedBox(height: 10),
            ],
          ),

        const SizedBox(height: 10),

        // ========================================================
        // Arrive Stop
        // ========================================================

        // if (kDebugMode) ...[
        //   AppButton(
        //     onPressed:
        //         (carpoolId.isNotEmpty &&
        //                 state.currentStop?.routeStopId != null)
        //             ? () => notifier.arriveAtStop(
        //                 routeStopId:
        //                     state.currentStop!.routeStopId!,
        //                 carpoolId: carpoolId,
        //               )
        //             : null,
        //     text: l10n.arrive_at_stop(
        //       state.currentStopIndex + 1,
        //     ),
        //   ),
        //   const SizedBox(height: 10),
        // ],

        /// View Passenger
        /// Same functionality that was previously on
        /// the Drop Passenger button.
        // AppButton(
        //   fontColor: context.appColors.brand,
        //   backgroundColor: context.appColors.border,
        //   onPressed: carpoolId.isNotEmpty
        //       ? () {
        //           context.pushNamed(
        //             Routes.passengerList.name,
        //             extra: {"carpoolId": carpoolId},
        //           );
        //         }
        //       : null,
        //   text: l10n.viewPassenger,
        // ),0
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _infoRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: context.textTheme.bodyMedium),
          Text(value, style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }

  // String _formatTime(DateTime dateTime) {
  //   final localDateTime = dateTime.toLocal();
  //   final hour = localDateTime.hour % 12 == 0 ? 12 : localDateTime.hour % 12;
  //   final minute = localDateTime.minute.toString().padLeft(2, '0');
  //   final period = localDateTime.hour >= 12 ? 'PM' : 'AM';

  //   return "$hour:$minute $period";
  // }

  String? _locationLabel(dynamic rawStop) {
    if (rawStop is! Map) return null;

    final stop = Map<String, dynamic>.from(rawStop);
    final label = (stop['placeName'] ?? stop['name'] ?? '').toString().trim();

    return label.isEmpty ? null : label;
  }
}
