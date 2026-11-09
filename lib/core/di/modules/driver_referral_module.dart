import '../../../features/driver_referral/data/datasources/driver_referral_datasource.dart';
import '../../../features/driver_referral/data/repositories/driver_referral_repository_impl.dart';
import '../../../features/driver_referral/domain/repositories/driver_referral_repository.dart';
import '../../../features/driver_referral/domain/usecases/get_driver_referral_history_usecase.dart';
import '../../../features/driver_referral/domain/usecases/get_driver_referral_summary_usecase.dart';
import '../service_locator.dart';

void registerDriverReferralModule() {
  // Data source
  locator.registerLazySingleton<DriverReferralDataSource>(
    () => DriverReferralDataSourceImpl(),
  );

  // Repository
  locator.registerLazySingleton<DriverReferralRepository>(
    () => DriverReferralRepositoryImpl(locator<DriverReferralDataSource>()),
  );

  // Use cases
  locator.registerLazySingleton<GetDriverReferralSummaryUseCase>(
    () => GetDriverReferralSummaryUseCase(locator<DriverReferralRepository>()),
  );
  locator.registerLazySingleton<GetDriverReferralHistoryUseCase>(
    () => GetDriverReferralHistoryUseCase(locator<DriverReferralRepository>()),
  );
}
