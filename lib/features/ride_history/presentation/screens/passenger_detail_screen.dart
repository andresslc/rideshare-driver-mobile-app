import 'package:driver_app/core/extensions/num_extension.dart';
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/core/navigation/routes.dart';
import 'package:driver_app/core/params/feedback_params.dart';
import 'package:driver_app/core/params/passenger_params.dart';
import 'package:driver_app/features/reviews/presentation/providers/feedback_provider.dart';
import 'package:driver_app/features/reviews/presentation/states/feedback_state.dart';
import 'package:driver_app/features/ride_history/presentation/providers/ride_history_provider.dart';
import 'package:driver_app/features/ride_history/presentation/states/ride_history_states.dart';
import 'package:driver_app/features/ride_history/presentation/widgets/review_form_widget.dart';
import 'package:driver_app/features/ride_history/presentation/widgets/review_widget.dart';
import 'package:driver_app/features/ride_room/presentation/widgets/plain_background_widget.dart';
import 'package:driver_app/shared/screens/success_screen.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:driver_app/shared/widgets/app_scaffold.dart';
import 'package:driver_app/shared/widgets/loader.dart';
import 'package:driver_app/shared/widgets/ride_driver_info.dart';
import 'package:driver_app/shared/widgets/ride_stats_row.dart';
import 'package:driver_app/shared/widgets/verticle_location_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/double_extension.dart';

class PassengerDetailScreen extends ConsumerStatefulWidget {
  // final String rideId;
  final String carpoolId;

  const PassengerDetailScreen({
    super.key,
    // required this.rideId,
    required this.carpoolId,
  });

  @override
  ConsumerState<PassengerDetailScreen> createState() =>
      _PassengerDetailScreenState();
}

class _PassengerDetailScreenState extends ConsumerState<PassengerDetailScreen> {
  final CustomLoader loader = CustomLoader();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(passengerProvider.notifier)
          .fetchPassengerDetail(PassengerParams(id: widget.carpoolId));
    });
  }

  void _submitReview(String passengerId, int rating) {
    final carpoolId = widget.carpoolId;

    if (passengerId.trim().isEmpty || carpoolId.trim().isEmpty) {
      context.showToast(context.l10n.unable_to_submit);
      return;
    }

    ref
        .read(feedbackProvider.notifier)
        .submitFeedback(
          FeedbackParam(
            receiveId: passengerId,
            receiverType: "User",
            stars: rating,
            carpoolId: carpoolId,
            description: null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(passengerProvider);

    ref.listen<FeedbackState>(feedbackProvider, (_, next) {
      if (next is FeedbackLoading) {
        loader.showLoader(context);
      } else if (next is FeedbackError) {
        loader.hideLoader();
        context.showToast(next.message);
      } else if (next is FeedbackSuccess) {
        loader.hideLoader();
        context.goNamed(
          Routes.success.name,
          extra: SuccessArgs(
            type: SuccessType.feedbackSubmitted,
            redirectRouteName: Routes.home.name,
          ),
        );
      }
    });

    return AppScaffold(
      padding: EdgeInsets.zero,
      scrollable: false,
      appBar: AppBar(title: Text(l10n.passenger_detail), centerTitle: true),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Builder(
          builder: (_) {
            if (state is PassengerDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PassengerDetailError) {
              return Center(child: Text(state.message));
            }

            if (state is PassengerDetailSuccess) {
              final passengers = state.passengers;

              if (passengers.isEmpty) {
                return Center(child: Text(l10n.noPassengerfound));
              }
              return ListView.builder(
                itemCount: passengers.length,
                itemBuilder: (context, index) {
                  final passenger = passengers[index];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "${l10n.passenger} ${index + 1} ${l10n.detail}", // Passenger 1, Passenger 2 ...
                          style: context.textTheme.titleMedium?.copyWith(
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      PlainBackgroundWidget(
                        isAllRounded: true,
                        radius: 14,
                        isPlain:
                            Theme.of(context).brightness == Brightness.dark,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8.0),
                            DriverInfoSection(
                              profileImage: passenger.profilePicture ?? "",
                              userName: passenger.displayName,
                              rating: passenger.rating ?? 0,
                              showTrailing: false,
                              showTopBorder: false,
                            ),
                            const Gap(16),
                            VerticleLocationStepper(
                              locationList: [
                                passenger.pickupPlace,
                                passenger.dropOffPlace,
                              ],
                              startTime: l10n.pickup_location,
                              endTime: l10n.dropoff_location,
                            ),
                            const Gap(16),
                            //  const Gap(AppSizes.p16),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.seatBooked,
                                  style: context.textTheme.bodyMedium,
                                ),
                                Text(
                                  '${passenger.totalSeatsBooked}',
                                  style: context.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(16),
                            // const Gap(16),
                            RideStatsRow(
                              totalTime: (passenger.avgTime).formatAvgTime(
                                context,
                              ),
                              totalDistance:
                                  passenger.distance.formatDistance(decimalDigits: 2),
                              totalAmount:
                                  "\$${passenger.fareCharged.toStringAsFixed(2)}",
                            ),
                            const Gap(16),

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
                            // const Gap(AppSizes.p12),
                            // const Gap(16),
                            if (passenger.status.toLowerCase() ==
                                'completed') ...[
                              if (passenger.review != null)
                                ReviewWidget(
                                  showTitleSpacing: false,
                                  reviewText: passenger.review!.description,
                                  rating: passenger.review!.stars,
                                  showline: false,
                                )
                              else
                                ReviewForm(
                                  passengerId: passenger.id,
                                  onSubmit: _submitReview,
                                ),
                            ],
                          ],
                        ),
                      ),
                      const Gap(12),
                    ],
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
