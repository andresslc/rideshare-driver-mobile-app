// import 'dart:async';

// import 'package:driver_app/app.dart';
// import 'package:driver_app/core/constants/api_endpoints.dart';
// import 'package:driver_app/core/di/service_locator.dart';
// import 'package:driver_app/core/services/api_service.dart';
// import 'package:driver_app/core/services/connectivity_service.dart';
// import 'package:driver_app/core/services/device_info_service.dart';
// import 'package:driver_app/core/services/socket_service.dart';
// import 'package:driver_app/core/services/storage_service.dart';
// import 'package:driver_app/core/theme/theme_notifier.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   TestWidgetsFlutterBinding.ensureInitialized();

//   tearDown(() async {
//     await locator.reset();
//   });

//   testWidgets('MyApp builds under ProviderScope with test services', (
//     WidgetTester tester,
//   ) async {
//     await locator.reset();

//     // Avoid ThemeNotifier automatic-mode timers during the test.
//     SharedPreferences.setMockInitialValues(const {'theme_mode': 'dark'});
//     final prefs = await SharedPreferences.getInstance();

//     locator.registerSingleton<SharedPreferences>(prefs);
//     locator.registerSingleton<StorageService>(StorageService(prefs));
//     locator.registerSingleton<ConnectivityService>(ConnectivityService());
//     locator.registerSingleton<DeviceInfoService>(DeviceInfoService());

//     locator.registerLazySingleton<SocketService>(
//       () => SocketService(
//         locator<StorageService>(),
//         onAuthRequired: (msg) {
//           unawaited(locator<ApiService>().handleAuthFailure(msg));
//         },
//       ),
//     );
//     locator.registerLazySingleton<ApiService>(
//       () => ApiService(
//         locator<StorageService>(),
//         locator<DeviceInfoService>(),
//         locator<SocketService>(),
//         baseUrl: ApiEndpoints.baseUrl,
//       ),
//     );

//     final themeNotifier = ThemeNotifier(StorageService(prefs));
//     addTearDown(themeNotifier.dispose);

//     await tester.pumpWidget(
//       ProviderScope(
//         child: MyApp(themeNotifier: themeNotifier),
//       ),
//     );
//     await tester.pump();

//     // SplashScreen schedules 4s delays; advance past them so no timers remain.
//     await tester.pump(const Duration(seconds: 4));
//     await tester.pump(const Duration(seconds: 1));
//     await tester.pump();

//     expect(tester.takeException(), isNull);
//     expect(find.byType(MaterialApp), findsOneWidget);
//   });
// }

void main() {}

