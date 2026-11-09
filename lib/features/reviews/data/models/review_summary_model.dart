import '../../domain/entities/review_summary_entity.dart';

class ReviewsSummaryModel extends ReviewsSummaryEntity {
  ReviewsSummaryModel({
    required super.averageRating,
    required super.totalReviews,
    required super.breakdown,
  });

  factory ReviewsSummaryModel.fromJson(Map<String, dynamic> json) {
    final raw = Map<String, dynamic>.from(json['breakdown'] ?? {});

    return ReviewsSummaryModel(
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: json['totalReviews'],
      breakdown: raw.map((k, v) => MapEntry(k, v as int)),
    );
  }
}
