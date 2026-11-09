import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/features/ride_room/presentation/widgets/plain_background_widget.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:driver_app/shared/widgets/ride_driver_info.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ReviewWidget extends StatelessWidget {
  final String reviewText;
  final int rating;
  final bool showDriverInfo;
  final bool showTitleSpacing;
  final String? reviewerName;
  final String? reviewerImage;
  final bool showline;
  final bool showReview;
  const ReviewWidget({
    super.key,
    required this.reviewText,
    this.rating = 5,
    this.showDriverInfo = false,
    this.showTitleSpacing = true,
    this.showline = true,
    this.showReview = true,
    this.reviewerName,
    this.reviewerImage,
  });

  @override
  Widget build(BuildContext context) {
    final hasReviewText = reviewText.trim().isNotEmpty;

    return PlainBackgroundWidget(
      isAllRounded: true,

      isPlain: Theme.of(context).brightness == Brightness.dark,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      radius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showline) Container(height: 1, color: context.appColors.border),

          // ///
          if (showTitleSpacing) const Gap(10),

          if (showReview)
            Text(context.l10n.review, style: context.textTheme.titleSmall),
          const Gap(8),

          /// Gradient Box
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ⭐ Stars Row
              Row(
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 3.0),
                    child: Icon(
                      Icons.star,
                      color: index < rating ? Colors.amber : Colors.grey[400],
                      size: 20,
                    ),
                  ),
                ),
              ),
              if (hasReviewText) const Gap(8),

              /// Review text
              if (hasReviewText)
                Text(
                  reviewText,
                  maxLines: 4,
                  style: context.textTheme.bodyMedium?.copyWith(),
                ),
              if (showDriverInfo)
                DriverInfoSection(
                  profileImage: reviewerImage ?? '',
                  userName: reviewerName ?? "",
                  rating: 1.5,
                  nameTextStyle: context.textTheme.labelSmall,
                  avatarSize: 30,
                  showTopBorder: false,
                  showRating: false,
                ),
              const Gap(8),
            ],
          ),
        ],
      ),
    );
  }
}
