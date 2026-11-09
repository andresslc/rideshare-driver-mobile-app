import 'package:driver_app/core/constants/app_images.dart';
import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/core/navigation/routes.dart';
import 'package:driver_app/features/reviews/presentation/providers/feedback_provider.dart';
import 'package:driver_app/shared/screens/success_screen.dart';
import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:driver_app/shared/widgets/app_scaffold.dart';
import 'package:driver_app/shared/widgets/ride_driver_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/params/feedback_params.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../ride_room/domain/entities/ride_entities.dart';
import '../states/feedback_state.dart';

class FeedBackScreen extends ConsumerStatefulWidget {
  final RideUserEntity user;
  final String? rideId;
  final String? carpoolId;
  const FeedBackScreen({
    super.key,
    required this.user,
    this.rideId,
    this.carpoolId,
  });

  @override
  ConsumerState<FeedBackScreen> createState() => _FeedBackScreenState();
}

class _FeedBackScreenState extends ConsumerState<FeedBackScreen> {
  int rating = 0;

  void submitmethod() {
    final rideId = widget.rideId?.trim() ?? '';
    final carpoolId = widget.carpoolId?.trim() ?? '';

    if (widget.user.id.trim().isEmpty ||
        (rideId.isEmpty && carpoolId.isEmpty)) {
      context.pop();
      context.showToast(context.l10n.unable_to_submit_rating);
      return;
    }

    if (rating == 0) {
      context.showToast(context.l10n.please_select_rating);
      return;
    }

    final param = FeedbackParam(
      receiveId: widget.user.id,
      receiverType: "User",
      stars: rating,
      description: '', // no description
      rideId: rideId.isNotEmpty ? rideId : null,
      carpoolId: carpoolId.isNotEmpty ? carpoolId : null,
    );

    ref.read(feedbackProvider.notifier).submitFeedback(param);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen<FeedbackState>(feedbackProvider, (previous, next) {
      if (next is FeedbackSuccess) {
        context.goNamed(
          Routes.success.name,
          extra: SuccessArgs(
            type: SuccessType.feedbackSubmitted,
            redirectRouteName: Routes.home.name,
          ),
        );
      } else if (next is FeedbackError) {
        context.showToast(next.message);
      }
    });
    return AppScaffold(
      padding: EdgeInsets.all(16),
      scrollable: true,
      appBar: AppBar(
        title: Text(
          l10n.give_rating,
        ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.05, end: 0),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: kToolbarHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              backgroundColor: AppColors.brand,
              text: l10n.submit,
              onPressed: () => submitmethod(),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
            SizedBox(height: 10),
            AppButton(
              fontColor: context.appColors.brand,
              backgroundColor: context.appColors.lightButton,
              text: l10n.skip,
              onPressed: _closeScreen,
            ).animate().fadeIn(delay: 260.ms).slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          Text(
            l10n.rate_passenger,
            style: context.textTheme.titleSmall?.copyWith(fontSize: 16),
          ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.2, end: 0),

          /// Subtitle
          Text(
                l10n.feedback_subtitle,
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              )
              .animate()
              .fadeIn(delay: 220.ms, duration: 250.ms)
              .slideX(begin: 0.3, end: 0),
          const Gap(AppSizes.p8),

          /// Driver Info
          DriverInfoSection(
            profileImage: widget.user.profilePicture,
            userName: widget.user.name.isNotEmpty
                ? widget.user.name
                : 'Passenger',
            rating: widget.user.rating,
            carImage: AppImages.noImage,
            showTrailing: false,
          ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.2, end: 0),
          const Gap(AppSizes.p18),

          /// Star Rating
          Text(
            l10n.your_rating,
            style: context.textTheme.bodyMedium,
          ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.2, end: 0),

          const Gap(AppSizes.p8),
          RatingBar.builder(
                initialRating: rating.toDouble(),
                minRating: 1,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 32,
                itemBuilder: (context, _) =>
                    Icon(Icons.star_rounded, color: AppColors.star),
                onRatingUpdate: (value) {
                  setState(() {
                    rating = value.toInt();
                  });
                },
              )
              .animate()
              .fadeIn(delay: 180.ms)
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                curve: Curves.easeOutBack,
              ),
        ],
      ),
    );
  }

  void _closeScreen() {
    // ref.read(carpoolProvider.notifier).clearCompletedRide();
    if (GoRouter.of(context).canPop()) {
      context.pop();
      return;
    }
    context.goNamed(Routes.home.name);
  }
}
