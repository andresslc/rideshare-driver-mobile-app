import 'package:driver_app/features/notification/data/datasources/notification_datascource.dart';
import 'package:driver_app/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:driver_app/features/notification/domain/repositories/notification_repository.dart';
import 'package:driver_app/features/notification/domain/usecase/delete_all_notifications_use_case.dart';
import 'package:driver_app/features/notification/domain/usecase/delete_notification_use_case.dart';
import 'package:driver_app/features/notification/domain/usecase/toggle_notification_usecase.dart';

import '../../../features/notification/domain/usecase/get_notification_use_case.dart';
import '../service_locator.dart';

/// Registers notification feature dependencies.
void registerNotificationModule() {
  // Data source
  locator.registerLazySingleton<NotificationDatasource>(
    () => NotificationDatasourceImpl(),
  );

  // Repository
  locator.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(locator<NotificationDatasource>()),
  );

  // Use cases
  locator.registerLazySingleton(
    () => ToggleNotificationUsecase(locator<NotificationRepository>()),
  );
  locator.registerLazySingleton(
    () => GetNotificationUseCase(locator<NotificationRepository>()),
  );
  locator.registerLazySingleton(
    () => DeleteNotificationUseCase(locator<NotificationRepository>()),
  );
  locator.registerLazySingleton(
    () => DeleteAllNotificationsUseCase(locator<NotificationRepository>()),
  );
}
