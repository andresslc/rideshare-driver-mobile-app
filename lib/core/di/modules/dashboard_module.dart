import 'package:driver_app/core/di/service_locator.dart';
import 'package:driver_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:driver_app/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:driver_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:driver_app/features/dashboard/domain/usecases/get_dashboard_usecase.dart';

void registerDashboardModule() {
  // Data sources
  locator.registerLazySingleton<DashboardDatasource>(
    () => DashboardDatasourceImpl(),
  );

  // Repositories
  locator.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(locator()),
  );

  // Use cases
  locator.registerLazySingleton(() => GetDashboardUseCase(locator()));
}
