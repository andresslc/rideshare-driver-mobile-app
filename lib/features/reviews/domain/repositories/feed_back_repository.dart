import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/core/params/feedback_params.dart';
import 'package:driver_app/core/params/report_params.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/params/review_request_param.dart';
import '../entities/review_response_entity.dart';

abstract class FeedBackRepository {
  Future<Either<Failure, String>> feedback({required FeedbackParam params});
  Future<Either<Failure, String>> report({required ReportParam params});

  Future<Either<Failure, ReviewsResponseEntity>> getReviews({
    required ReviewsRequestParams params,
  });
}
