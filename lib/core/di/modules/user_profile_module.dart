import 'package:driver_app/features/user_profile/data/datasources/user_profile_datasource.dart';
import 'package:driver_app/features/user_profile/data/repositories/user_profile_impl.dart';
import 'package:driver_app/features/user_profile/domain/repositories/user_repositories.dart';
import 'package:driver_app/features/user_profile/domain/usecase/fetch_vehicle_types_usecase.dart';
import 'package:driver_app/features/user_profile/domain/usecase/update_profile_usecase.dart';
import 'package:driver_app/features/user_profile/domain/usecase/user_profile_usecase.dart';

import '../service_locator.dart';

void registerUserProfileModule() {
  locator.registerLazySingleton<UserProfileDatasource>(
    () => UserProfileDatasourceImpl(locator()),
  );

  locator.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(locator()),
  );

  locator.registerLazySingleton<UserProfileUseCase>(
    () => UserProfileUseCase(locator()),
  );

  locator.registerLazySingleton<FetchVehicleTypesUseCase>(
    () => FetchVehicleTypesUseCase(locator()),
  );

  locator.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(locator()),
  );
}
