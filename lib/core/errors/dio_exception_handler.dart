import 'package:dio/dio.dart';
import '../utils/app_log.dart';
import 'network_handler.dart';

class CustomDioException extends DioException {
  final String customMessage;
  final dynamic responseData;

  CustomDioException({
    required super.requestOptions,
    required this.customMessage,
    this.responseData,
    super.response,
    super.type,
    super.error,
  });

  @override
  String toString() {
    return 'CustomDioException: $customMessage (Status Code: ${response?.statusCode})';
  }

  /// Converts a DioException to a CustomDioException with enriched error handling.
  static CustomDioException fromDioError(DioException dioError) {
    String errorMessage = NetworkExceptions.handleException(dioError);
    log(errorMessage.toString(), name: 'CustomDioException');
    dynamic responseData;

    if (dioError.response != null) {
      responseData = dioError.response?.data;

      // Handle JSON response
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('message') &&
            responseData['message'] is String) {
          errorMessage = responseData['message'];
        } else if (responseData.containsKey('error') &&
            responseData['error'] is String) {
          errorMessage = responseData['error'];
        } else {
          errorMessage = responseData.toString();
        }
      }
      // Handle plain text response
      else if (responseData is String) {
        errorMessage = responseData;
      }

      log(
        'API Error [${dioError.response?.statusCode}] $responseData',
        name: 'CustomDioException',
      );
    } else {
      // No server response at all (e.g. no internet, timeout)
      log(
        'Dio Error (no response) ${dioError.message}',
        name: 'CustomDioException',
      );
    }

    return CustomDioException(
      requestOptions: dioError.requestOptions,
      response: dioError.response,
      type: dioError.type,
      error: dioError.error,
      customMessage: errorMessage,
      responseData: responseData,
    );
  }
}
