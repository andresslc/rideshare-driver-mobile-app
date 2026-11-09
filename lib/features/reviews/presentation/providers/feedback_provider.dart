import 'package:driver_app/core/params/report_params.dart';
import 'package:driver_app/features/reviews/domain/use_case/get_review_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import '../../../../core/params/feedback_params.dart';
import '../../../../core/params/review_request_param.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/use_case/feedback_usecase.dart';
import '../../domain/use_case/report_usecase.dart';
import '../states/feedback_state.dart';

// // final feedbackProvider = NotifierProvider<FeedbackController, FeedbackState>(
// //   () => FeedbackController.new,
// // );

// // class FeedbackController extends Notifier<FeedbackState> {
// //   late FeedBackUseCase _feedbackUseCase;

// //   @override
// //   FeedbackState build() {
// //     _feedbackUseCase = locator<FeedBackUseCase>();
// //     return const FeedbackInitial();
// //   }

// //   /// ------------------------------
// //   /// SUBMIT FEEDBACK
// //   /// ------------------------------
// //   Future<void> submitFeedback(FeedbackParam params) async {
// //     state = const FeedbackLoading();

// //     final result = await _feedbackUseCase.call(params);

// //     result.fold(
// //       (failure) => state = FeedbackError(failure.message),
// //       (message) => state = FeedbackSuccess(message),
// //     );
// //   }
// // }
// final feedbackProvider = NotifierProvider<FeedbackController, FeedbackState>(
//   FeedbackController.new,
// );

// class FeedbackController extends Notifier<FeedbackState> {
//   FeedBackUseCase get _feedbackUseCase => locator<FeedBackUseCase>();
//   int _currentPage = 1;
//   bool _hasMore = true;
//   bool _isLoadingMore = false;
//   List<ReviewEntity> _reviews = [];

//   @override
//   FeedbackState build() {
//     return const FeedbackInitial();
//   }

//   Future<void> submitFeedback(FeedbackParam params) async {
//     state = const FeedbackLoading();

//     final result = await _feedbackUseCase.call(params);

//     result.fold(
//       (failure) => state = FeedbackError(failure.message),
//       (message) => state = FeedbackSuccess(message),
//     );
//   }

//   /// ------------------------------
//   /// GET REVIEWS
//   /// ------------------------------
//   Future<void> fetchReviews({
//     required String receiverId,
//     required String receiverType,
//   }) async {
//     _currentPage = 1;
//     _reviews.clear();
//     state = const FeedbackLoading();

//     final result = await _feedbackUseCase.fetchReviews(
//       receiverId: receiverId,
//       receiverType: receiverType,
//       page: _currentPage,
//     );

//     result.fold(
//       (failure) => state = FeedbackError(failure.message),
//       (reviews) => state = ReviewsSuccess(reviews),
//     );
//   }
// }
final feedbackProvider = NotifierProvider<FeedbackController, FeedbackState>(
  FeedbackController.new,
);

class FeedbackController extends Notifier<FeedbackState> {
  FeedBackUseCase get _feedbackUseCase => locator<FeedBackUseCase>();
  GetReviewUsecase get _getreviewUseCase => locator<GetReviewUsecase>();

  // 🔹 Pagination Variables
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  List<ReviewEntity> _reviews = [];

  @override
  FeedbackState build() {
    return const FeedbackInitial();
  }

  /// ------------------------------
  /// SUBMIT FEEDBACK
  /// ------------------------------
  Future<void> submitFeedback(FeedbackParam params) async {
    state = const FeedbackLoading();

    final result = await _feedbackUseCase.call(params);

    result.fold(
      (failure) => state = FeedbackError(failure.message),
      (message) => state = FeedbackSuccess(message),
    );
  }

  /// ------------------------------
  /// FIRST PAGE LOAD
  /// ------------------------------
  Future<void> fetchReviews() async {
    _currentPage = 1;
    _reviews.clear();
    state = const FeedbackLoading();

    final result = await _getreviewUseCase.fetchReviews(
      params: ReviewsRequestParams(page: _currentPage),
    );

    result.fold((failure) => state = ReviewError(failure.message), (
      response,
    ) {
      _reviews = response.reviews;

      _hasMore =
          response.pagination.currentPage < response.pagination.totalPages;

      state = ReviewsSuccess(reviews: _reviews, hasMore: _hasMore);
    });
  }

  /// ------------------------------
  /// LOAD MORE (Pagination)
  /// ------------------------------
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    _currentPage++;

    final result = await _getreviewUseCase.fetchReviews(
      params: ReviewsRequestParams(page: _currentPage),
    );

    result.fold((failure) {}, (response) {
      _reviews.addAll(response.reviews);

      _hasMore =
          response.pagination.currentPage < response.pagination.totalPages;

      state = ReviewsSuccess(reviews: _reviews, hasMore: _hasMore);
    });

    _isLoadingMore = false;
  }
}
