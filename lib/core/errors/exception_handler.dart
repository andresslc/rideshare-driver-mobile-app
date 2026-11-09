import 'package:dio/dio.dart';
import '../utils/app_log.dart';
import 'dio_exception_handler.dart';
import 'failure.dart';
import 'exceptions.dart';

Failure handleException(dynamic e) {
  log(name: "Exception", e.toString());
  if (e is ServerException) {
    return ServerFailure(message: e.message ?? "Server Error!");
  } else if (e is DioException) {
    final customError = CustomDioException.fromDioError(e);
    return TokenFailure(message: customError.customMessage);
  } else if (e is InvalidTokenException) {
    return TokenFailure(message: e.message);
  } else if (e is CacheException) {
    return CacheFailure(message: "Cache error occurred.");
  } else if (e is DioException) {
    return ServerFailure(message: e.message ?? "Network error");
  } else if (e is FormatException || e is TypeError || e is NoSuchMethodError) {
    return SyntaxFailure(message: "Parsing/Syntax error occurred.");
  } else {
    return SyntaxFailure(message: "Something went wrong: $e");
  }
}
