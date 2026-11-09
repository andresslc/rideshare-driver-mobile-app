import 'package:driver_app/core/services/socket_service.dart';
import 'package:driver_app/core/services/api_service.dart';
import 'package:driver_app/features/carpool/data/datasources/carpool_datasource.dart';
import 'package:driver_app/features/carpool/data/repository_impl/carpool_repository_impl.dart';
import 'package:driver_app/features/carpool/data/datasources/carpool_socket_datasource.dart';
import 'package:driver_app/features/carpool/data/datasources/carpool_socket_listener.dart';
import 'package:driver_app/features/carpool/data/repository_impl/carpool_socket_repository_impl.dart';
import 'package:driver_app/features/carpool/domain/repositories/carpool_repository.dart';
import 'package:driver_app/features/carpool/domain/repositories/carpool_socket_repository.dart';
import 'package:driver_app/features/carpool/domain/usecases/carpool_usecase.dart';
import 'package:driver_app/core/di/service_locator.dart';

void registerCarpoolModule() {
  locator.registerLazySingleton<CarpoolDataSource>(
    () => CarpoolDataSourceImpl(locator<ApiService>()),
  );

  locator.registerLazySingleton<CarpoolRepository>(
    () => CarpoolRepositoryImpl(locator<CarpoolDataSource>()),
  );

  locator.registerLazySingleton<ViewPassengerUseCase>(
    () => ViewPassengerUseCase(locator<CarpoolRepository>()),
  );

  locator.registerLazySingleton<CarpoolSocketListener>(
    () => CarpoolSocketListener(socketService: locator<SocketService>()),
  );

  locator.registerLazySingleton<CarpoolSocketDataSource>(
    () => CarpoolSocketDataSourceImpl(
      socketService: locator<SocketService>(),
      listener: locator<CarpoolSocketListener>(),
    ),
  );

  locator.registerLazySingleton<CarpoolSocketRepository>(
    () => CarpoolSocketRepositoryImpl(locator<CarpoolSocketDataSource>()),
  );
}
