import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/shared/model/api_response_model.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/params/notification_params.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, ApiResponse>> toggleNotification({
    required bool isEnabled,
    required String? fcm,
  });
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    required NotificationParams params,
  });
  Future<Either<Failure, ApiResponse>> deleteNotification({
    required String notificationId,
  });
  Future<Either<Failure, ApiResponse>> deleteAllNotifications();
}
