import 'package:driver_app/features/reviews/domain/entities/review_entity.dart';
import 'package:driver_app/features/reviews/presentation/states/feedback_state.dart';
import 'package:driver_app/features/reviews/presentation/widgets/review_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../ride_history/presentation/widgets/review_widget.dart';
import '../providers/feedback_provider.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({super.key});

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedbackProvider.notifier).fetchReviews();
    });

    // Pagination listener
    _controller.addListener(() {
      final provider = ref.read(feedbackProvider.notifier);
      final state = ref.read(feedbackProvider);

      if (_controller.position.pixels >=
              _controller.position.maxScrollExtent - 200 &&
          state is ReviewsSuccess &&
          state.hasMore &&
          !state.isLoadingMore) {
        provider.loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(feedbackProvider);

    List<ReviewEntity> reviews = [];
    String? errorMessage;
    bool isInitialLoading = false;
    bool hasMore = false;

    bool isLoadingMore = false;

    if (state is FeedbackLoading) {
      isInitialLoading = true;
    } else if (state is FeedbackError) {
      errorMessage = state.message;
    } else if (state is ReviewsSuccess) {
      reviews = state.reviews;
      hasMore = state.hasMore;
      isLoadingMore = state.isLoadingMore;
    }

    final totalReviews = reviews.length;
    final double averageRating = totalReviews == 0
        ? 0
        : reviews.map((r) => r.stars).reduce((a, b) => a + b) / totalReviews;

    int getCount(int star) => reviews.where((r) => r.stars == star).length;

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          l10n.reviews,
        ).animate().fade(duration: 500.ms).slideY(begin: -0.2, end: 0),
      ),
      child: isInitialLoading
          ? ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
              itemCount: 5,
              itemBuilder: (context, index) => const ReviewShimmer(),
            )
          : errorMessage != null
          ? Center(child: Text(errorMessage))
          : reviews.isEmpty
          ? Center(
              child: Text(
                l10n.complete_rides_rating,
                textAlign: TextAlign.center,
              ),
            )
          : CustomScrollView(
              controller: _controller,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p4),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const Gap(AppSizes.p12),

                      /// 🔹 Title
                      Text(
                            l10n.customer_reviews,
                            style: context.textTheme.titleMedium,
                          )
                          .animate()
                          .fade(duration: 300.ms)
                          .slideX(begin: -0.1, end: 0),
                      const Gap(AppSizes.p8),

                      /// ⭐ Average Rating Row
                      Row(
                            children: [
                              ...List.generate(5, (index) {
                                if (index < averageRating.floor()) {
                                  return Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: AppSizes.p12,
                                  );
                                } else if (index < averageRating) {
                                  return Icon(
                                    Icons.star_half,
                                    color: Colors.amber,
                                    size: AppSizes.p12,
                                  );
                                } else {
                                  return Icon(
                                    Icons.star_border,
                                    color: Colors.amber,
                                    size: AppSizes.p12,
                                  );
                                }
                              }),
                              const Gap(AppSizes.p8),
                              Text(
                                "(${averageRating.toStringAsFixed(1)})",
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontSize: AppSizes.p12,
                                ),
                              ),
                              const Gap(AppSizes.p4),
                              Text(
                                "($totalReviews)",
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontSize: AppSizes.p12,
                                ),
                              ),
                            ],
                          )
                          .animate()
                          .fade(delay: 100.ms)
                          .slideX(begin: 0.1, end: 0),
                      const Gap(AppSizes.p12),

                      /// ⭐ Rating Breakdown
                      Column(
                        children: List.generate(5, (index) {
                          int starValue = 5 - index;
                          int count = getCount(starValue);
                          return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSizes.p8,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "$starValue ${context.l10n.stars}",
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(fontSize: 10),
                                    ),
                                    const Gap(AppSizes.p8),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.p16,
                                        ),
                                        child: LinearProgressIndicator(
                                          value: totalReviews == 0
                                              ? 0
                                              : count / totalReviews,
                                          color: Colors.amber,
                                          minHeight: AppSizes.p8,
                                        ),
                                      ),
                                    ),
                                    const Gap(AppSizes.p8),
                                    Text(
                                      "$count",
                                      style: context.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              )
                              .animate(delay: (index * 80).ms)
                              .fade(duration: 300.ms)
                              .slideX(begin: 0.15, end: 0);
                        }),
                      ),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Text(
                      l10n.reviews,
                      style: context.textTheme.titleMedium,
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.15, end: 0),
                  ),
                ),

                /// 📋 Reviews List
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final review = reviews[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p4,
                        vertical: 8,
                      ),
                      child:
                          ReviewWidget(
                                showReview: false,
                                showDriverInfo: true,
                                reviewerImage: review.reviewerImage,
                                reviewerName: review.reviewerName,
                                showline: false,
                                reviewText: review.description,
                                rating: review.stars,
                              )
                              .animate(delay: (index * 100).ms)
                              .fade(duration: 350.ms)
                              .slideY(begin: 0.15, end: 0),
                    );
                  }, childCount: reviews.length),
                ),

                if (isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
              ],
            ),
    );
  }
}
