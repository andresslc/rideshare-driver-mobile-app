import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fpdart/fpdart.dart';
import '../utils/app_log.dart';
import 'dio_exception_handler.dart';
import 'exceptions.dart';
import 'failure.dart';

class ErrorHandler {
  const ErrorHandler._();

  static Failure handleDioError(DioException e) {
    if (CancelToken.isCancel(e)) {
      return ServerFailure(message: 'Request cancelled');
    }

    final customError = CustomDioException.fromDioError(e);
    return ServerFailure(
      message: customError.customMessage,
      error: customError.responseData,
    );
  }

  static Failure handleError(dynamic error) {
    if (error is FirebaseException) {
      return ServerFailure(message: error.message.toString());
    } else if (error is ServerException) {
      return ServerFailure(message: error.message.toString());
    }

    return ServerFailure(message: 'Something went wrong: ${error.toString()} ');
  }
}

Future<Either<Failure, T>> handleNetworkError<T>(
  Future<T> Function() apiCall,
) async {
  try {
    final response = await apiCall();
    return Right(response);
  } catch (e, stackTrace) {
    log(name: 'api error data handling error', "${e.toString()}  $stackTrace");
    if (e is DioException) {
      return Left(ErrorHandler.handleDioError(e));
    }

    return Left(ErrorHandler.handleError(e));
  }
}
