import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../di/service_locator.dart';
import '../utils/app_log.dart';
import 'storage_service.dart';

/// Automatically injects the auth token into every outgoing request.
/// Calls [onTokenBlacklisted] when a 401 is received.
///
class DioInterceptor extends Interceptor {
  final Function(String?) onTokenBlacklisted;

  DioInterceptor({required this.onTokenBlacklisted});

  bool _shouldBlacklist(Response? response) {
    final message = response?.data['message'];

    // ✅ Skip blacklist for
    if (message == 'Incorrect current password!') return false;

    return response?.statusCode == 401 ||
        message == 'Your subscription is not active - Access denied' ||
        message == 'Your profile is paused' ||
        message == 'Invalid or expired token provided' ||
        message == 'Your profile is incomplete' ||
        message == 'Unauthorized - Please relogin' ||
        message == 'No such User found - Access denied';
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_shouldBlacklist(response)) {
      onTokenBlacklisted(response.data['message']);
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_shouldBlacklist(err.response)) {
      onTokenBlacklisted(err.response?.data['message']);
    }
    super.onError(err, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String? authHeader = options.headers['Authorization'] as String?;
    if (authHeader == null || authHeader.trim().isEmpty) {
      try {
        final String? token = locator<StorageService>().getToken;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        debugPrint("Error fetching stored auth token in interceptor: $e");
      }
    }

    super.onRequest(options, handler);
    debugPrint("Request::::::${options.uri}");
    debugPrint("Method::::::${options.method}");
    debugPrint("Headers::::::${options.headers}");
    debugPrint("QueryParms:::::::${options.queryParameters}");
    debugPrint("Body::::::${options.data}");
  }
}

/// Callback type alias for void callbacks.
typedef VoidCallback = void Function();
