import '../../../../core/errors/failure.dart';
import '../../../../core/params/notification_params.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetNotificationUseCase {
  final NotificationRepository repository;

  GetNotificationUseCase(this.repository);

  Future<Either<Failure, List<NotificationEntity>>> call({
    required NotificationParams params,
  }) {
    return repository.getNotifications(params: params);
  }
}
