import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/core/params/feedback_params.dart';
import 'package:driver_app/core/params/review_request_param.dart';
import 'package:driver_app/features/reviews/data/datasources/feed_back_datasource.dart';
import 'package:driver_app/features/reviews/domain/repositories/feed_back_repository.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/params/report_params.dart';
import '../../domain/entities/review_response_entity.dart';

abstract class FeedBackRepositoryInternal implements FeedBackRepository {}

class FeedBackRepositoryImpl implements FeedBackRepository {
  final FeedbackRemoteDataSource dataSource;

  FeedBackRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, String>> feedback({
    required FeedbackParam params,
  }) async {
    final response = await dataSource.submitFeedback(params: params);
    return response.fold(
      (failure) => Left(ServerFailure(message: failure.message)),
      (message) => Right(message),
    );
  }

  //report
  @override
  Future<Either<Failure, String>> report({required ReportParam params}) async {
    final response = await dataSource.report(params: params);
    return response.fold(
      (failure) => Left(ServerFailure(message: failure.message)),
      (message) => Right(message),
    );
  }

  /// ------------------------------
  /// GET REVIEWS
  /// ------------------------------
  @override
  Future<Either<Failure, ReviewsResponseEntity>> getReviews({
    required ReviewsRequestParams params,
  }) async {
    final response = await dataSource.getReviews(params: params);

    return response.fold(
      (failure) => Left(ServerFailure(message: failure.message)),
      (data) => Right(data),
    );
  }
}
