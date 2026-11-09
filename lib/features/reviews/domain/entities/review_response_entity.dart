import 'package:driver_app/features/reviews/domain/entities/pagination_entity.dart';
import 'package:driver_app/features/reviews/domain/entities/review_entity.dart';
import 'package:driver_app/features/reviews/domain/entities/review_summary_entity.dart';

class ReviewsResponseEntity {
  final ReviewsSummaryEntity summary;
  final List<ReviewEntity> reviews;
  final PaginationEntity pagination;

  const ReviewsResponseEntity({
    required this.summary,
    required this.reviews,
    required this.pagination,
  });
}
