import 'package:driver_app/features/reviews/data/models/pagination_model.dart';
import 'package:driver_app/features/reviews/data/models/review_model.dart';
import 'package:driver_app/features/reviews/data/models/review_summary_model.dart';

import '../../domain/entities/review_response_entity.dart';

class ReviewsResponseModel extends ReviewsResponseEntity {
  ReviewsResponseModel({
    required super.summary,
    required super.reviews,
    required super.pagination,
  });

  factory ReviewsResponseModel.fromJson(Map<String, dynamic> json) {
    return ReviewsResponseModel(
      summary: ReviewsSummaryModel.fromJson(json['data']['summary']),
      reviews: (json['data']['reviews'] as List)
          .map((e) => ReviewModel.fromJson(e))
          .toList(),
      pagination: PaginationModel.fromJson(json['pagination']),
    );
  }
}
