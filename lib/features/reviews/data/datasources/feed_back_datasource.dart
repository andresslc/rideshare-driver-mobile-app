import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/params/feedback_params.dart';
import 'package:driver_app/core/params/report_params.dart';
import 'package:driver_app/features/reviews/data/models/review_response_model.dart';
import 'package:driver_app/features/reviews/domain/entities/review_response_entity.dart';
import 'package:driver_app/shared/model/api_response_model.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/params/review_request_param.dart';

/// Custom exception for feedback submission
// class FeedbackSubmissionException implements Exception {
//   final String message;
//   const FeedbackSubmissionException(this.message);

//   @override
//   String toString() => message;
// }

/// Abstract DataSource
abstract class FeedbackRemoteDataSource {
  Future<Either<Failure, String>> submitFeedback({
    required FeedbackParam params,
  });
  Future<Either<Failure, String>> report({required ReportParam params});
  Future<Either<Failure, ReviewsResponseEntity>> getReviews({
    required ReviewsRequestParams params,
  });
}

/// Implementation
// class FeedbackRemoteDataSourceImpl implements FeedbackRemoteDataSource {
//   final ApiService _apiService;
//   FeedbackRemoteDataSourceImpl(this._apiService);

//   @override
//   Future<Either<Failure, String>> submitFeedback({
//     required FeedbackParam params,
//   }) async {
//     return handleNetworkError(() async {
//       final res = await _apiService.post(
//         ApiEndpoints.review,
//         data: params.toJson(),
//       );
//       final ApiResponse response = ApiResponse.fromMap(res.data);
//       return response.message ?? '';
//     });
//   }

//   @override
//   Future<Either<Failure, ReviewsResponseEntity>> getReviews({
//     required String receiverId,
//     required String receiverType,
//   }) async {
//     return handleNetworkError(() async {
//       final res = await _apiService.get(
//         ApiEndpoints.review,
//         queryParameters: {
//           "receiverId": receiverId,
//           "receiverType": receiverType, // Driver | User
//         },
//       );

//       final ApiResponse response = ApiResponse.fromMap(res.data);
//       return ReviewsResponseModel.fromJson(response.data);
//     });
//   }
// }

class FeedbackRemoteDataSourceImpl implements FeedbackRemoteDataSource {
  final ApiService _apiService;
  FeedbackRemoteDataSourceImpl(this._apiService);

  @override
  Future<Either<Failure, String>> submitFeedback({
    required FeedbackParam params,
  }) async {
    return handleNetworkError(() async {
      final res = await _apiService.post(
        ApiEndpoints.review,
        data: params.toJson(),
      );
      final ApiResponse response = ApiResponse.fromMap(res.data);
      return response.message ?? '';
    });
  }

  //report

  @override
  Future<Either<Failure, String>> report({required ReportParam params}) async {
    return handleNetworkError(() async {
      final res = await _apiService.post(
        ApiEndpoints.report,
        data: params.toJson(),
      );
      final ApiResponse response = ApiResponse.fromMap(res.data);
      return response.message ?? '';
    });
  }

  @override
  Future<Either<Failure, ReviewsResponseEntity>> getReviews({
    required ReviewsRequestParams params,
  }) async {
    return handleNetworkError(() async {
      final res = await _apiService.get(
        ApiEndpoints.review,
        queryParameters: params.toJson(),
      );
      // final ApiResponse response = ApiResponse.fromMap(res.data);
      return ReviewsResponseModel.fromJson(res.data);
    });
  }
}
