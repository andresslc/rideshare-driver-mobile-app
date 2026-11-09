import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/features/notification/domain/repositories/notification_repository.dart';
import 'package:driver_app/shared/model/api_response_model.dart';
import 'package:fpdart/fpdart.dart';

class ToggleNotificationUsecase {
  final NotificationRepository repository;

  ToggleNotificationUsecase(this.repository);

  Future<Either<Failure, ApiResponse>> call({
    required bool isEnabled,
    required String? fcm,
  }) {
    return repository.toggleNotification(isEnabled: isEnabled, fcm: fcm);
  }
}
