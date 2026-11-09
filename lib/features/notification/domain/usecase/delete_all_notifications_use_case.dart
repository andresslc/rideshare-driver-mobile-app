import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/shared/model/api_response_model.dart';
import 'package:fpdart/fpdart.dart';

import '../repositories/notification_repository.dart';

class DeleteAllNotificationsUseCase {
  final NotificationRepository repository;

  DeleteAllNotificationsUseCase(this.repository);

  Future<Either<Failure, ApiResponse>> call() {
    return repository.deleteAllNotifications();
  }
}
