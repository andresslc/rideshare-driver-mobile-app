import 'package:driver_app/core/di/modules/bank_account_module.dart';
import 'package:driver_app/core/di/modules/carpool_module.dart';
import 'package:driver_app/core/di/modules/change_language_module.dart';
import 'package:driver_app/core/di/modules/feedback_module.dart';
import 'package:driver_app/core/di/modules/notification_module.dart';
import 'package:driver_app/core/di/modules/ride_history_module.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../services/device_info_service.dart';
import '../services/image_service.dart';
import '../services/notification_route_service.dart';
import '../services/notification_service.dart';
import '../services/sound_service.dart';
import '../services/wakelock_service.dart';
import 'modules/auth_module.dart';
import 'modules/core_module.dart';
import 'modules/dashboard_module.dart';
import 'modules/driver_referral_module.dart';
import 'modules/ride_room_module.dart';
import 'modules/user_profile_module.dart';
import 'modules/wallet_module.dart';

/// Global service-locator instance.
final GetIt locator = GetIt.instance;

/// Initialise all dependency injection modules.
///
/// Call this once in `main()` before running the app.
Future<void> setupLocator() async {
  // ── Async singletons ──────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(prefs);
  locator.registerLazySingleton(() => ImageService());
  locator.registerLazySingleton(() => NotificationServices());
  locator.registerLazySingleton(() => NotificationRouteService());
  locator.registerLazySingleton(() => SoundService());
  locator.registerLazySingleton(() => WakelockService());
  locator.registerSingleton(DeviceInfoService());
  // ── Core services ─────────────────────────────────────────────────────
  registerCoreModule();

  // ── Feature modules ───────────────────────────────────────────────────
  registerAuthModule();
  registerBankAccountModule();
  registerWalletModule();
  registerNotificationModule();
  registerUserProfileModule();
  registerLanguageModule();
  registerRideRoomModule();
  registerCarpoolModule();
  registerDashboardModule();
  registerFeedBackModule();
  registerRideHistoryModule();
  registerDriverReferralModule();
}

Future<void> setup(AppConfig config) async {
  locator.registerSingleton<AppConfig>(config);
}
