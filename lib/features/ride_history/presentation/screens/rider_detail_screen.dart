// import 'package:driver_app/features/ride_history.dart/presentation/widgets/review_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import '../../../../core/constants/app_images.dart';
// import '../../../../core/constants/app_sizes.dart';
// import '../../../../core/extensions/context_extension.dart';
// import '../../../../core/extensions/theme_extension.dart';
// import '../../../../core/navigation/routes.dart';
// import '../../../../core/params/feedback_params.dart';
// import '../../../../core/params/ride_history_detail_params.dart';
// import '../../../../shared/screens/success_screen.dart';
// import '../../../../shared/widgets/app_button.dart';
// import '../../../../shared/widgets/app_gradient_box.dart';
// import '../../../../shared/widgets/app_scaffold.dart';
// import '../../../../shared/widgets/loader.dart';
// import '../../../../shared/widgets/ride_driver_info.dart';
// import '../../../../shared/widgets/ride_stats_row.dart';
// import '../../../../shared/widgets/verticle_location_stepper.dart';
// import '../../../reviews/presentation/providers/feedback_provider.dart';
// import '../../../reviews/presentation/states/feedback_state.dart';
// import '../providers/ride_history_provider.dart';
// import '../states/ride_history_states.dart';
// import '../widgets/info_card_widget.dart';

// class RiderDetailScreen extends ConsumerStatefulWidget {
//   final String rideId;
//   final String userId;

//   final String rideLabel;
//   final String? specialRequest;
//   final String? cancellationReason;
//   final String? cancelledBy;
//   final String? rideStatus;

//   const RiderDetailScreen({
//     super.key,
//     required this.userId,
//     required this.rideId,
//     required this.rideLabel,
//     this.specialRequest,
//     this.cancellationReason,
//     this.cancelledBy,
//     this.rideStatus,
//   });

//   @override
//   ConsumerState<RiderDetailScreen> createState() => _RiderDetailScreenState();
// }

// class _RiderDetailScreenState extends ConsumerState<RiderDetailScreen> {
//   final TextEditingController reviewController = TextEditingController();
//   final CustomLoader loader = CustomLoader();

//   int rating = 0;

//   @override
//   void initState() {
//     super.initState();

//     /// Screen open hote hi ride detail API hit hogi
//     Future.microtask(() {
//       ref
//           .read(rideDetailProvider.notifier)
//           .fetchRideDetail(RideHistoryDetailParams(id: widget.rideId));
//     });
//   }

//   String formatTime(DateTime date) {
//     return DateFormat('hh:mm a').format(date);
//   }

//   void submitmethod() {
//     final l10n = context.l10n;

//     if (widget.userId.trim().isEmpty || widget.rideId.trim().isEmpty) {
//       context.showToast('Unable to submit feedback.');
//       return;
//     }

//     if (rating == 0) {
//       context.showToast("Please select rating");
//       return;
//     }

//     if (reviewController.text.trim().isEmpty) {
//       context.showToast(l10n.hint_description);
//       return;
//     }
//     final param = FeedbackParam(
//       receiveId: widget.userId,
//       receiverType: "User",
//       stars: rating,
//       description: reviewController.text.trim(),
//       rideId: widget.rideId,
//     );

//     ref.read(feedbackProvider.notifier).submitFeedback(param);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(rideDetailProvider);
//     final l10n = context.l10n;
//     ref.listen<FeedbackState>(feedbackProvider, (previous, next) {
//       if (next is FeedbackLoading) {
//         loader.showLoader(context);
//       } else if (next is FeedbackError) {
//         loader.hideLoader();
//         context.showToast(next.message);
//       } else if (next is FeedbackSuccess) {
//         loader.hideLoader();
//         context.goNamed(
//           Routes.success.name,
//           extra: SuccessArgs(
//             type: SuccessType.feedbackSubmitted,
//             redirectRouteName: Routes.home.name,
//           ),
//         );
//       } else if (next is FeedbackInitial) {
//         // do nothing
//       }
//     });

//     /// Loading State
//     if (state is RideHistoryLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     /// Error State
//     if (state is RideHistoryError) {
//       return Scaffold(body: Center(child: Text(state.message)));
//     }

//     /// Success State
//     if (state is RideDetailSuccess) {
//       final ride = state.ride;

//       /// Payment Card
//       // final cards = [
//       //   BankCardModel(
//       //     id: ride.transaction.card.id,
//       //     brandImage: ride.transaction.card.brand,
//       //     // cardNumber: ride.transaction.card.last4,
//       //     isDefault: true,
//       //     cardNumber: "**** **** **** ${ride.transaction.card.last4}",
//       //   ),
//       // ];

//       return AppScaffold(
//         padding: EdgeInsets.zero,
//         scrollable: true,
//         appBar: AppBar(
//           title: Text(widget.rideLabel, style: context.textTheme.titleMedium),
//           centerTitle: true,
//         ),

//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               /// Driver Info
//               DriverInfoSection(
//                 profileImage: ride.user.profilePicture ?? "",
//                 userName: ride.user.name,
//                 rating: ride.user.rating.toDouble(),
//                 carImage: AppImages.sedan,
//                 carName:
//                     "${ride.driver.vehicleDetails.make} ${ride.driver.vehicleDetails.licensePlateNumber}",
//                 vehicleType: ride.driver.vehicleDetails.model,
//                 showTopBorder: false,
//                 showTrailing: false,
//               ),
//               const Gap(AppSizes.p12),

//               /// Ride Details Box
//               AppGradientBox(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       l10n.rideDetails,
//                       style: context.textTheme.headlineMedium,
//                     ),

//                     const Gap(AppSizes.p8),

//                     /// Pickup → Dropoff
//                     VerticleLocationStepper(
//                       locationList: [
//                         ride.pickupPoint.placeName,
//                         ride.dropOffPointRequested.placeName,
//                       ],
//                       startTime: formatTime(ride.createdAt),
//                       endTime: formatTime(ride.updatedAt),
//                     ),

//                     const Gap(AppSizes.p12),
//                     if (widget.specialRequest != null &&
//                         widget.specialRequest!.isNotEmpty)
//                       /// Special Request or Cancellation Reason
//                       Column(
//                         children: [
//                           InfoCard(
//                             description:
//                                 widget.specialRequest != null &&
//                                     widget.specialRequest!.isNotEmpty
//                                 ? widget.specialRequest!
//                                 : l10n.noSpecialRequest,
//                             // description:
//                             //     widget.specialRequest ?? "No special request",
//                           ),
//                           const Gap(AppSizes.p12),
//                         ],
//                       ),

//                     /// Payment Method Label
//                     Text(
//                       l10n.paymentMethod,
//                       style: context.textTheme.labelSmall?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const Gap(AppSizes.p8),

//                     /// Payment Method
//                     // ...cards.map(
//                     //   (card) => Column(
//                     //     children: [
//                     //       CardWidget(
//                     //         card: card,
//                     //         // title: "Payment Method",
//                     //         // showIcons: false,
//                     //         onTap: () {},
//                     //       ),
//                     // SizedBox(
//                     //   width: double.infinity,

//                     //   child: AppGradientBox(
//                     //     cornerRadius: 12,
//                     //     child: Padding(
//                     //       padding: const EdgeInsets.symmetric(
//                     //         vertical: 8.0,
//                     //       ).copyWith(left: 16),
//                     //       child: Text(
//                     //         ride.transaction.type == 'debit'
//                     //             ? "Via Card"
//                     //             : "Via Wallet",
//                     //         style: context.textTheme.bodyMedium,
//                     //         textAlign: TextAlign.start,
//                     //       ),
//                     //     ),
//                     //   ),
//                     // ),
//                     const Gap(AppSizes.p12),

//                     /// Ride Stats
//                     RideStatsRow(
//                       totalTime: "${ride.averageTime} min",
//                       totalDistance:
//                           ride.rideDistance.formatDistance(decimalDigits: 2),
//                       totalAmount: "\$${ride.rideFare}",
//                     ),
//                     Container(height: 1.5, color: context.appColors.border),

//                     const Gap(AppSizes.p12),

//                     /// Review Section (Only for Completed Rides)
//                     /// Review Section (Only for Completed Rides)
//                     if (ride.rideStatus == "completed") ...[
//                       if (ride.reviewhistory != null &&
//                           ride.reviewhistory.id.isNotEmpty)
//                         ReviewWidget(
//                           reviewText:
//                               ride.reviewhistory?.description ??
//                               ride.driver.reviewsReceived.toString(),
//                           rating:
//                               ride.reviewhistory?.stars ??
//                               ride.driver.rating
//                                   .toInt(), // review stars agar hai, warna driver rating
//                         )
//                       else
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               l10n.reviews,
//                               style: context.textTheme.titleSmall,
//                             ),
//                             const Gap(10),
//                             AppGradientBox(
//                               cornerRadius: 10,
//                               padding: const EdgeInsets.all(8),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   /// ⭐ Rating bar upar
//                                   RatingBar.builder(
//                                     initialRating: rating.toDouble(),
//                                     minRating: 1,
//                                     allowHalfRating: false,
//                                     itemCount: 5,
//                                     itemSize: 25,
//                                     itemPadding: const EdgeInsets.symmetric(
//                                       horizontal: 2,
//                                     ),
//                                     itemBuilder: (context, _) => const Icon(
//                                       Icons.star_rounded,
//                                       color: Colors.amber,
//                                     ),
//                                     onRatingUpdate: (value) {
//                                       setState(() {
//                                         rating = value.toInt();
//                                       });
//                                     },
//                                   ),

//                                   /// Review / Description TextField
//                                   TextField(
//                                     controller: reviewController,
//                                     maxLines: 3,
//                                     textCapitalization:
//                                         TextCapitalization.sentences,
//                                     decoration: InputDecoration(
//                                       hintText: l10n.addReviewHere, // hint text
//                                       border: InputBorder.none,
//                                       isDense: true,
//                                       contentPadding: EdgeInsets.symmetric(
//                                         vertical: 4,
//                                         horizontal: 6,
//                                       ),
//                                     ),
//                                     style: const TextStyle(fontSize: 14),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             /// Submit Button (only for completed rides)
//                             const Gap(8),
//                             AppButton(
//                               text: l10n.submitReview,
//                               onPressed: () => submitmethod(),
//                             ),

//                             /// Cancellation Section (Only for Cancelled Rides)
//                           ],
//                         ),
//                     ],
//                   ],
//                 ),
//               ),

//               const Gap(8),

//               if (ride.rideStatus == 'cancelled')
//                 if (widget.cancellationReason != null &&
//                     widget.cancellationReason!.isNotEmpty)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         l10n.cancellationReason,
//                         style: context.textTheme.labelMedium?.copyWith(
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const Gap(6),

//                       /// Reason Text
//                       SizedBox(
//                         width: double.infinity,
//                         height: MediaQuery.of(context).size.height * 0.15,
//                         child: AppGradientBox(
//                           cornerRadius: 8,
//                           padding: const EdgeInsets.all(12),
//                           child: Text(
//                             widget.cancellationReason ?? l10n.noReasonProvided,
//                             style: context.textTheme.bodySmall?.copyWith(
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                         ),
//                       ),
//                       const Gap(AppSizes.p12),
//                     ],
//                   ),
//             ],
//           ),
//         ),
//       );
//     }

//     return const SizedBox();
//   }
// }
import 'package:driver_app/core/extensions/num_extension.dart';
import 'package:driver_app/core/theme/app_colors.dart';
import 'package:driver_app/features/ride_history/presentation/widgets/review_widget.dart';
import 'package:driver_app/features/ride_room/presentation/widgets/plain_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/extensions/double_extension.dart';
import '../../../../core/extensions/date_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/navigation/routes.dart';
import '../../../../core/params/feedback_params.dart';
import '../../../../core/params/ride_history_detail_params.dart';
import '../../../../shared/screens/success_screen.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_gradient_box.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/loader.dart';
import '../../../../shared/widgets/ride_driver_info.dart';
import '../../../../shared/widgets/ride_stats_row.dart';
import '../../../../shared/widgets/verticle_location_stepper.dart';
import '../../../reviews/presentation/providers/feedback_provider.dart';
import '../../../reviews/presentation/states/feedback_state.dart';
import '../../domain/enitities/ride_history_detail_entities.dart';
import '../providers/ride_history_provider.dart';
import '../states/ride_history_states.dart';
import '../widgets/info_card_widget.dart';

class RiderDetailScreen extends ConsumerStatefulWidget {
  final String rideId;
  final String userId;
  final String rideLabel;
  final String? specialRequest;
  final String? cancellationReason;
  final String? cancelledBy;
  final String? rideStatus;

  const RiderDetailScreen({
    super.key,
    required this.userId,
    required this.rideId,
    required this.rideLabel,
    this.specialRequest,
    this.cancellationReason,
    this.cancelledBy,
    this.rideStatus,
  });

  @override
  ConsumerState<RiderDetailScreen> createState() => _RiderDetailScreenState();
}

class _RiderDetailScreenState extends ConsumerState<RiderDetailScreen> {
  final TextEditingController reviewController = TextEditingController();
  final CustomLoader loader = CustomLoader();
  int rating = 0;

  //calling api in init
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(rideDetailProvider.notifier)
          .fetchRideDetail(RideHistoryDetailParams(id: widget.rideId));
    });
  }

  // only show time no today yesterday
  String formatTime(DateTime date) => date.toLocal().formatTimeWithFixedAmPm(
    localeName: context.l10n.localeName,
  );

  final receiverType = "Driver";
  ReviewHistoryEntity? _findDriverReview(RideDetailEntity ride) {
    for (final review in ride.reviews) {
      final reviewerType = review.reviewerType.toLowerCase();
      final isDriverReviewer =
          review.reviewer == ride.driver.id || reviewerType == receiverType;
      if (isDriverReviewer) {
        return review;
      }
    }

    return null;
  }

  //submit button
  void submitmethod() {
    if (widget.userId.trim().isEmpty || widget.rideId.trim().isEmpty) {
      context.showToast(context.l10n.unabletosubmitfeedback);
      return;
    }

    if (rating == 0) {
      context.showToast(context.l10n.pleaseselectrating);
      return;
    }

    // final description = reviewController.text.trim();

    final param = FeedbackParam(
      receiveId: widget.userId,
      receiverType: "User",
      stars: rating,
      // description: description.isEmpty ? null : description,
      rideId: widget.rideId,
    );
    ref.read(feedbackProvider.notifier).submitFeedback(param);
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideDetailProvider);

    ref.listen<FeedbackState>(feedbackProvider, (previous, next) {
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
      appBar: AppBar(
        title: Text(widget.rideLabel, style: context.textTheme.titleMedium),
        centerTitle: true,
      ),
      child: Builder(
        builder: (_) {
          if (state is RideHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RideHistoryError) {
            return Center(child: Text(state.message));
          }

          if (state is RideDetailSuccess) {
            final ride = state.ride;
            final driverReview = _findDriverReview(ride);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DriverInfoSection(
                      profileImage: ride.user.profilePicture,
                      userName: ride.user.displayName,
                      rating: ride.user.rating.toDouble(),
                      carImage: AppImages.sedan,
                      carName:
                          "${ride.driver.vehicleDetails.make} ${ride.driver.vehicleDetails.model}"
                              .trim(),
                      vehicleType:
                          ride.driver.vehicleDetails.licensePlateNumber,
                      showTopBorder: false,
                      showTrailing: false,
                    ),
                    const Gap(AppSizes.p12),

                    PlainBackgroundWidget(
                      isAllRounded: true,
                      radius: 14,
                      isPlain: Theme.of(context).brightness == Brightness.dark,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.rideDetails,
                            style: context.textTheme.headlineMedium,
                          ),
                          const Gap(AppSizes.p8),

                          VerticleLocationStepper(
                            locationList: [
                              ride.pickupPoint.placeName,
                              ride.dropOffPointRequested.placeName,
                            ],
                            startTime: formatTime(ride.createdAt),
                            endTime: formatTime(ride.updatedAt),
                          ),
                          const Gap(AppSizes.p12),

                          if (widget.specialRequest != null &&
                              widget.specialRequest!.isNotEmpty)
                            Column(
                              children: [
                                InfoCard(
                                  description:
                                      widget.specialRequest ??
                                      context.l10n.noSpecialRequest,
                                ),
                                const Gap(AppSizes.p12),
                              ],
                            ),

                          const Gap(AppSizes.p12),
                          RideStatsRow(
                            totalTime: ride.averageTime.formatAvgTime(context),
                            // "${ride.averageTime} ${context.l10n.min}",
                            totalDistance:
                                ride.rideDistance.formatDistance(decimalDigits: 2),
                            totalAmount: "\$${ride.rideFare}",
                          ),

                          const Gap(AppSizes.p8),
                          if (ride.rideStatus == "completed") ...[
                            if (driverReview != null &&
                                driverReview.id.isNotEmpty)
                              ReviewWidget(
                                reviewText: driverReview.description,
                                rating: driverReview.stars,
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.reviews,
                                    style: context.textTheme.titleSmall,
                                  ),
                                  const Gap(10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RatingBar.builder(
                                        initialRating: rating.toDouble(),
                                        minRating: 1,
                                        allowHalfRating: false,
                                        itemCount: 5,
                                        itemSize: 25,
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star_rounded,
                                          color: AppColors.star,
                                        ),
                                        onRatingUpdate: (value) {
                                          setState(() {
                                            rating = value.toInt();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  const Gap(12),
                                  AppButton(
                                    text: context.l10n.submitReview,
                                    onPressed: submitmethod,
                                  ),
                                ],
                              ),
                          ],

                          if (ride.rideStatus == 'cancelled' &&
                              widget.cancellationReason != null &&
                              widget.cancellationReason!.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.cancellationReason,
                                  style: context.textTheme.labelMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const Gap(6),
                                SizedBox(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.15,
                                  child: AppGradientBox(
                                    cornerRadius: 8,
                                    padding: const EdgeInsets.all(12),
                                    child: Text(widget.cancellationReason!),
                                  ),
                                ),
                                const Gap(AppSizes.p12),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
