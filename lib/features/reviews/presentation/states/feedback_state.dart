import '../../domain/entities/review_entity.dart';
import '../../domain/entities/review_response_entity.dart';

sealed class FeedbackState {
  const FeedbackState();
}

class FeedbackInitial extends FeedbackState {
  const FeedbackInitial();
}

class FeedbackLoading extends FeedbackState {
  const FeedbackLoading();
}

class FeedbackError extends FeedbackState {
  final String message;
  const FeedbackError(this.message);
}

class FeedbackSuccess extends FeedbackState {
  final String message;
  const FeedbackSuccess(this.message);
}

// class ReportError extends FeedbackState {
//   final String message;
//   const ReportError(this.message);
// }

class ReportSuccess extends FeedbackState {
  final String message;
  const ReportSuccess(this.message);
}

/// Reviews fetched successfully
class ReviewError extends FeedbackState {
  final String message;
  const ReviewError(this.message);
}

///
///
///
class ReviewsSuccess extends FeedbackState {
  // final ReviewsResponseEntity reviews;
  final List<ReviewEntity> reviews;
  final bool hasMore;
  final bool isLoadingMore;

  const ReviewsSuccess({
    required this.reviews,
    required this.hasMore,
    this.isLoadingMore = false,
  });
}
