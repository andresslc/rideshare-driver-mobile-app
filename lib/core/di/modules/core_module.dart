import 'dart:async';

import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/services/connectivity_service.dart';
import 'package:driver_app/core/services/device_info_service.dart';
import 'package:driver_app/core/services/location_service.dart';
import 'package:driver_app/core/services/socket_service.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import '../../config/remote_config_model.dart';
import '../../config/remote_config_service.dart';
import '../../constants/constants_data.dart';
import '../../location/service_region.dart';
import '../../services/address_search_diagnostics.dart';
import '../../services/api_service.dart';
import '../../services/network_quality_service.dart';
import '../../services/storage_service.dart';
import '../../theme/theme_notifier.dart';
import '../service_locator.dart';

/// Registers core infrastructure services.
void registerCoreModule() {
  locator.registerLazySingleton<StorageService>(
    () => StorageService(locator<SharedPreferences>()),
  );

  locator.registerLazySingleton<ApiService>(
    () => ApiService(
      locator<StorageService>(),
      locator<DeviceInfoService>(),
      locator<SocketService>(),
      baseUrl: locator<AppConfig>().baseUrl,
    ),
  );

  locator.registerLazySingleton<RideConfigService>(
    () => RideConfigService(
      apiService: locator<ApiService>(),
      storage: locator<StorageService>(),
    ),
  );

  locator.registerLazySingleton<ThemeNotifier>(
    () => ThemeNotifier(locator<StorageService>()),
  );

  locator.registerLazySingleton<SocketService>(
    () => SocketService(
      locator<StorageService>(),
      onAuthRequired: (msg) {
        unawaited(locator<ApiService>().handleAuthFailure(msg));
      },
    ),
  );

  locator.registerLazySingleton<LocationService>(() {
    final diagnostics = AddressSearchDiagnostics();
    unawaited(
      PackageInfo.fromPlatform()
          .then((info) {
            diagnostics.version = info.version;
            diagnostics.build = info.buildNumber;
          })
          .catchError((Object _) {
            /* Metadata cannot block address entry. */
          }),
    );
    return LocationService(
      storage: locator<StorageService>(),
      placesObserver: diagnostics.observe,
    );
  });
  locator.registerSingleton<ConnectivityService>(ConnectivityService());
  locator.registerSingleton<NetworkQualityService>(NetworkQualityService());

  locator.registerLazySingleton<FirebaseRemoteConfig>(
    () => FirebaseRemoteConfig.instance,
  );

  locator.registerLazySingleton<RemoteConfigService>(
    () => RemoteConfigService(
      locator<FirebaseRemoteConfig>(),
      onConfigChanged: _onRemoteConfigChangedInLocator,
    ),
  );
}

void _onRemoteConfigChangedInLocator(RemoteConfigModel config) {
  final invalidateSearch =
      remoteConfigModel.addressSearchV2Enabled !=
          config.addressSearchV2Enabled ||
      remoteConfigModel.mapApiKey != config.mapApiKey ||
      remoteConfigModel.serviceRegionId != config.serviceRegionId;
  remoteConfigModel = config;
  if (invalidateSearch && locator.isRegistered<LocationService>()) {
    locator<LocationService>().invalidateAddressSearches();
  }
  ServiceRegionConfig.setActiveByKey(config.serviceRegionId);

  // Update ApiService if already initialized
  if (locator.isRegistered<ApiService>()) {
    locator<ApiService>().updateBaseUrl(locator<AppConfig>().baseUrl);
  }

  if (locator.isRegistered<NetworkQualityService>()) {
    locator<NetworkQualityService>().configure(
      baseUrl: locator<AppConfig>().baseUrl,
    );
  }

  // Update SocketService if already initialized
  if (locator.isRegistered<SocketService>()) {
    locator<SocketService>().updateSocketUrl(locator<AppConfig>().baseUrl);
  }

  // Update Stripe publishable key at runtime
  if (config.stripePublishableKey.isNotEmpty) {
    Stripe.publishableKey = config.stripePublishableKey;
  }
}
