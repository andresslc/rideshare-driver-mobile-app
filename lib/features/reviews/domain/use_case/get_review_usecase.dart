import 'package:driver_app/features/reviews/domain/repositories/feed_back_repository.dart';

import '../../../../core/params/review_request_param.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/review_response_entity.dart';

class GetReviewUsecase {
  final FeedBackRepository _repository;
  GetReviewUsecase(this._repository);

  FutureEither<ReviewsResponseEntity> fetchReviews({
    required ReviewsRequestParams params,
  }) async {
    return await _repository.getReviews(params: params);
  }
}
