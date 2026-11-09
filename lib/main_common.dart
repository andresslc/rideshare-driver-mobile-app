import 'dart:async';

import 'package:driver_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/config/remote_config_service.dart';
import 'core/config/ride_config_service.dart';
import 'core/constants/api_endpoints.dart';
import 'core/di/service_locator.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/network_quality_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/theme_notifier.dart';

Future<void> _initializeStripe() async {
  final publishableKey = ApiEndpoints.stripePublishableKey;
  if (publishableKey.isEmpty) {
    if (kDebugMode) {
      debugPrint(
        'STRIPE_PUBLISHABLE_KEY is missing. Bank account attach will not work.',
      );
    }
    return;
  }

  Stripe.publishableKey = publishableKey;

  Stripe.urlScheme = 'driverapp';

  await Stripe.instance.applySettings();
}

void mainCommon({required AppConfig config}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    // Bloc.observer = AppBlocObserver();
  }
  await setup(config);
  await setupLocator();

  // Initialize Remote Config before Stripe and other services
  await locator<RemoteConfigService>().initialize();

  // Distance unit and dispatch texts come from the server. Not awaited: the
  // service serves the cached value meanwhile and never throws.
  unawaited(locator<RideConfigService>().load());

  await _initializeStripe();
  // ConnectivityService.instance.startMonitoring();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // ── Start network monitoring ───────────────────────────────────────────

  await locator<NotificationServices>().init();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    locator<ConnectivityService>().initialize();
    final networkQuality = locator<NetworkQualityService>();
    networkQuality.configure(baseUrl: config.baseUrl);
    networkQuality.startMonitoring();
    unawaited(networkQuality.checkNow());
  });

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // log("APP STARTED  ${await locator<NotificationServices>().getDeviceToken()}");
  runApp(ProviderScope(child: MyApp(themeNotifier: locator<ThemeNotifier>())));
}
