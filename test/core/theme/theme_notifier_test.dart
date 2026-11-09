import 'package:driver_app/core/services/storage_service.dart';
import 'package:driver_app/core/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeNotifier automatic mode', () {
    testWidgets('uses light mode before 6 PM and dark mode at 6 PM', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      var currentTime = DateTime(2026, 3, 31, 17, 59, 50);
      final notifier = ThemeNotifier(storage, now: () => currentTime);

      await notifier.setAutomatic();
      expect(notifier.value, ThemeMode.light);

      currentTime = DateTime(2026, 3, 31, 18, 00, 00);
      await tester.pump(const Duration(seconds: 10));

      expect(notifier.value, ThemeMode.dark);
      notifier.dispose();
    });

    testWidgets('starts in dark mode after 6 PM', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      final notifier = ThemeNotifier(
        storage,
        now: () => DateTime(2026, 3, 31, 18, 00, 00),
      );

      await notifier.setAutomatic();

      expect(notifier.value, ThemeMode.dark);
      notifier.dispose();
    });
  });
}
