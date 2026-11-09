import 'package:driver_app/features/auth/domain/use_cases/logout_usecase.dart';
import 'package:driver_app/features/auth/domain/use_cases/delete_account_usecase.dart';
import 'package:driver_app/features/auth/domain/use_cases/send_otp_usecase.dart';
import '../../../features/auth/data/datasources/auth_data_sources.dart';
import '../../../features/auth/data/repositories/auth_repositories_impl.dart';
import '../../../features/auth/domain/repositories/auth_repositories.dart';
import '../../../features/auth/domain/use_cases/verify_otp_usecase.dart';
import '../service_locator.dart';

/// Registers auth feature dependencies.
void registerAuthModule() {
  // Data source
  locator.registerLazySingleton<AuthDatasource>(() => AuthDatasourceImpl());

  // // Repository
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(locator<AuthDatasource>()),
  );

  // // Use cases
  locator.registerLazySingleton<SendOtpUseCase>(
    () => SendOtpUseCase(locator<AuthRepository>()),
  );
  locator.registerLazySingleton<VerifyOtpUseCase>(
    () => VerifyOtpUseCase(locator<AuthRepository>()),
  );
  locator.registerLazySingleton(() => LogoutUseCase(locator<AuthRepository>()));

  // // BLoC (factory — new instance each time)
  // locator.registerFactory(
  //   () => AuthBloc(
  //     loginUseCase: locator<LoginUseCase>(),
  //     registerUseCase: locator<RegisterUseCase>(),
  //   ),
  // );
  locator.registerLazySingleton<DeleteAccountUseCase>(
    () => DeleteAccountUseCase(locator<AuthRepository>()),
  );
  
}
