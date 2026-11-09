import 'package:driver_app/core/constants/api_endpoints.dart';
import 'package:driver_app/core/di/service_locator.dart';
import 'package:driver_app/core/errors/error_handler.dart';
import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/core/services/api_service.dart';
import 'package:driver_app/shared/model/api_response_model.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/params/notification_params.dart';
import '../models/notification_model.dart';

abstract class NotificationDatasource {
  Future<Either<Failure, ApiResponse>> toggleNotification({
    required bool isEnabled,
    required String? fcm,
  });
  Future<Either<Failure, List<NotificationModel>>> getNotifications({
    required NotificationParams params,
  });
  Future<Either<Failure, ApiResponse>> deleteNotification({
    required String notificationId,
  });
  Future<Either<Failure, ApiResponse>> deleteAllNotifications();
}

class NotificationDatasourceImpl implements NotificationDatasource {
  final ApiService apiService = locator<ApiService>();

  @override
  Future<Either<Failure, ApiResponse>> toggleNotification({
    required bool isEnabled,
    required String? fcm,
  }) {
    return handleNetworkError(() async {
      final res = await apiService.post(
        ApiEndpoints.toggleNotification,
        data: {"fcm": fcm, "isEnabled": isEnabled},
      );
      return ApiResponse.fromMap(res.data);
    });
  }
  @override
  Future<Either<Failure, List<NotificationModel>>> getNotifications({
    required NotificationParams params,
  }) {
    return handleNetworkError(() async {
      final res = await apiService.get(
        ApiEndpoints.getNotifications,
        queryParameters: params.toJson(),
      );
      final data = res.data['data'] as List? ?? [];
      final notifications = data
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return notifications;
    });
  }

  @override
  Future<Either<Failure, ApiResponse>> deleteNotification({
    required String notificationId,
  }) {
    return handleNetworkError(() async {
      final res = await apiService.delete(
        ApiEndpoints.deleteNotification(notificationId),
      );
      return ApiResponse.fromMap(res.data);
    });
  }

  @override
  Future<Either<Failure, ApiResponse>> deleteAllNotifications() {
    return handleNetworkError(() async {
      final res = await apiService.delete(
        ApiEndpoints.deleteAllNotifications,
      );
      return ApiResponse.fromMap(res.data);
    });
  }
}
