class ReviewsSummaryEntity {
  final double averageRating;
  final int totalReviews;
  final Map<String, int> breakdown;

  const ReviewsSummaryEntity({
    required this.averageRating,
    required this.totalReviews,
    required this.breakdown,
  });
}
