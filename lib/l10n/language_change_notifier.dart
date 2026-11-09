import 'dart:async';

import 'package:driver_app/core/config/ride_config_service.dart';
import 'package:driver_app/core/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appLanguageNotifier = AppLanguageNotifier();

class AppLanguageNotifier extends ValueNotifier<Locale> {
  final Locale defaultLocale = const Locale('en', 'US');
  AppLanguageNotifier() : super(const Locale('en', 'US')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode =
        prefs.getString('language_code') ?? defaultLocale.languageCode;
    final countryCode =
        prefs.getString('countryCode') ?? defaultLocale.countryCode;
    value = Locale(languageCode, countryCode);
  }

  Future<void> changeLanguage(Locale locale) async {
    if (value == locale) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('countryCode', locale.countryCode ?? '');
    value = locale;

    // The dispatch texts in `GET /config/ride` are localized server side, so
    // they have to be pulled again for the new language.
    if (locator.isRegistered<RideConfigService>()) {
      unawaited(locator<RideConfigService>().load(locale: locale.languageCode));
    }
  }
}
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// final appLanguageNotifier = AppLanguageNotifier();

// class AppLanguageNotifier extends ValueNotifier<Locale?> {
//   AppLanguageNotifier() : super(null) {
//     _loadSavedLocale();
//   }

//   Future<void> _loadSavedLocale() async {
//     final prefs = await SharedPreferences.getInstance();
//     final languageCode = prefs.getString('language_code');
//     final countryCode = prefs.getString('countryCode');

//     // Keep locale null to let Flutter follow device locale when no preference
//     // has been saved yet.
//     if (languageCode == null || languageCode.isEmpty) {
//       value = null;
//       return;
//     }

//     if (countryCode == null || countryCode.isEmpty) {
//       value = Locale(languageCode);
//       return;
//     }

//     value = Locale(languageCode, countryCode);
//   }

//   Future<void> changeLanguage(Locale locale) async {
//     if (value == locale) return;

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('language_code', locale.languageCode);
//     await prefs.setString('countryCode', locale.countryCode ?? '');
//     value = locale;
//   }
// }
