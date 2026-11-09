import 'package:driver_app/features/ride_room/data/datasources/ride_socket_datasource.dart';
import 'package:driver_app/features/ride_room/data/datasources/ride_socket_listener.dart';
import 'package:driver_app/features/ride_room/data/repository_impl/ride_socket_repository_impl.dart';
import 'package:driver_app/features/ride_room/domain/repositories/ride_socket_repository.dart';
import 'package:driver_app/features/ride_room/domain/usecases/ride_socket_usecase.dart';
import 'package:driver_app/features/ride_room/data/datasources/ride_datasource.dart';
import 'package:driver_app/features/ride_room/domain/repositories/ride_repository.dart';
import 'package:driver_app/features/ride_room/data/repository_impl/ride_repository_impl.dart';
import 'package:driver_app/features/ride_room/domain/usecases/ride_usecase.dart';
import 'package:driver_app/core/services/api_service.dart';
import 'package:driver_app/features/ride_room/domain/usecases/send_message_use_case.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/socket_service.dart';
import '../../../features/ride_room/domain/usecases/get_chat_history_use_case.dart';

void registerRideRoomModule() {
  // Listeners
  locator.registerLazySingleton<RideSocketListener>(
    () => RideSocketListener(socketService: locator<SocketService>()),
  );

  // Data sources
  locator.registerLazySingleton<RideSocketDataSource>(
    () => RideSocketDataSourceImpl(
      socketService: locator<SocketService>(),
      listener: locator<RideSocketListener>(),
    ),
  );

  locator.registerLazySingleton<RideDataSource>(
    () => RideDataSourceImpl(locator<ApiService>()),
  );

  // Repositories
  locator.registerLazySingleton<RideSocketRepository>(
    () => RideSocketRepositoryImpl(locator<RideSocketDataSource>()),
  );

  locator.registerLazySingleton<RideRepository>(
    () => RideRepositoryImpl(locator<RideDataSource>()),
  );

  // Use cases
  locator.registerLazySingleton<RideSocketUseCase>(
    () => RideSocketUseCase(locator<RideSocketRepository>()),
  );

  locator.registerLazySingleton<AvailableRideUseCase>(
    () => AvailableRideUseCase(locator<RideRepository>()),
  );

  locator.registerLazySingleton<GetRideByIdUseCase>(
    () => GetRideByIdUseCase(locator<RideRepository>()),
  );
  locator.registerLazySingleton<GetChatHistoryUseCase>(
    () => GetChatHistoryUseCase(locator<RideRepository>()),
  );
  locator.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(locator<RideRepository>()),
  );
}
