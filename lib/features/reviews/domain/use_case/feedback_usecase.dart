import 'package:driver_app/core/params/feedback_params.dart';
import 'package:driver_app/features/reviews/domain/repositories/feed_back_repository.dart';

import '../../../../core/params/review_request_param.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/review_response_entity.dart';

class FeedBackUseCase {
  final FeedBackRepository _repository;

  FeedBackUseCase(this._repository);

  FutureEither<String> call(FeedbackParam params) async {
    return await _repository.feedback(params: params);
  }
}
