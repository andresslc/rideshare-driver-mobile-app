import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../di/service_locator.dart';
import 'app_config.dart';
import 'env.dart';

/// Model class to hold all remote configuration values
class RemoteConfigModel {
  /// Pass with `--dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...`.
  static const String stripeTestKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
  );

  static bool _isDevOrStaging() {
    if (locator.isRegistered<AppConfig>()) {
      return locator<AppConfig>().isDevOrStaging;
    }
    return Env.current.isDev || Env.current.isStaging || kDebugMode;
  }

  final String baseUrlDev;
  final String baseUrlStaging;
  final String baseUrlProd;
  // final String baseUrl;
  // final String socketUrl;
  final String serviceRegionId;
  final String mapApiKey;
  final String stripePublishableKey;
  final String termsURL;
  final String privacyURL;
  final String supportEmail;
  final String appDomain;
  final String websiteURL;
  final bool addressSearchV2Enabled;
  final bool useOsrmInDebug;

  // Update related fields
  final String minRequiredVersion;
  final String latestVersion;
  final String updateTitle;
  final String updateMessage;
  final String appStoreUrl;
  final String playStoreUrl;

  const RemoteConfigModel({
    this.addressSearchV2Enabled = false,
    required this.baseUrlDev,
    required this.baseUrlStaging,
    required this.baseUrlProd,
    // required this.baseUrl,
    // required this.socketUrl,
    required this.serviceRegionId,
    required this.mapApiKey,
    required this.stripePublishableKey,
    required this.termsURL,
    required this.privacyURL,
    required this.supportEmail,
    required this.appDomain,
    required this.websiteURL,
    required this.useOsrmInDebug,
    required this.minRequiredVersion,
    required this.latestVersion,
    required this.updateTitle,
    required this.updateMessage,
    required this.appStoreUrl,
    required this.playStoreUrl,
  });

  /// Static async method to create from Firebase Remote Config
  static Future<RemoteConfigModel> fromRemoteConfig(
    FirebaseRemoteConfig remoteConfig,
  ) async {
    try {
      final String configString = remoteConfig.getString("app_config");
      return RemoteConfigModel.fromConfigString(configString);
    } catch (e) {
      return RemoteConfigModel.defaults();
    }
  }

  /// Parse from a raw JSON config string (synchronous).
  factory RemoteConfigModel.fromConfigString(String configString) {
    try {
      if (configString.isEmpty || configString == '{}') {
        return RemoteConfigModel.defaults();
      }

      final Map<String, dynamic> configMap = jsonDecode(configString);
      final defaults = RemoteConfigModel.defaults();

      return RemoteConfigModel(
        addressSearchV2Enabled: configMap['addressSearchV2Enabled'] == true,
        baseUrlDev: configMap['BASE_URL_DEV'] ?? defaults.baseUrlDev,
        baseUrlStaging:
            configMap['BASE_URL_STAGING'] ?? defaults.baseUrlStaging,
        baseUrlProd: configMap['BASE_URL_PROD'] ?? defaults.baseUrlProd,
        // baseUrl: rawBaseUrl.isNotEmpty ? rawBaseUrl : defaults.baseUrl,
        // socketUrl: rawSocketUrl.isNotEmpty ? rawSocketUrl : defaults.socketUrl,
        serviceRegionId: _nonEmpty(
          configMap['serviceRegionId'] ?? configMap['service_region_id'],
          defaults.serviceRegionId,
        ),
        mapApiKey: _nonEmpty(configMap['MapApiKey'], defaults.mapApiKey),
        stripePublishableKey: _isDevOrStaging()
            ? stripeTestKey
            : _nonEmpty(
                configMap['stripePublishableKey'] ??
                    configMap['stripe_publishable_key'],
                defaults.stripePublishableKey,
              ),
        termsURL: _nonEmpty(configMap['termsURL'], defaults.termsURL),
        privacyURL: _nonEmpty(configMap['privacyURL'], defaults.privacyURL),
        supportEmail: _nonEmpty(
          configMap['supportEmail'],
          defaults.supportEmail,
        ),
        appDomain: _nonEmpty(configMap['appDomain'], defaults.appDomain),
        websiteURL: _nonEmpty(configMap['websiteURL'], defaults.websiteURL),
        useOsrmInDebug: configMap['useOsrmInDebug'] ?? true,
        minRequiredVersion: _nonEmpty(
          configMap['minRequiredVersion'] ?? configMap['force_update_version'],
          defaults.minRequiredVersion,
        ),
        latestVersion: _nonEmpty(
          configMap['latestVersion'] ?? configMap['latest_app_version'],
          defaults.latestVersion,
        ),
        updateTitle: _nonEmpty(
          configMap['updateTitle'] ?? configMap['update_title'],
          defaults.updateTitle,
        ),
        updateMessage: _nonEmpty(
          configMap['updateMessage'] ?? configMap['update_message'],
          defaults.updateMessage,
        ),
        appStoreUrl: _nonEmpty(
          configMap['appStoreUrl'] ?? configMap['app_store_url'],
          defaults.appStoreUrl,
        ),
        playStoreUrl: _nonEmpty(
          configMap['playStoreUrl'] ?? configMap['play_store_url'],
          defaults.playStoreUrl,
        ),
      );
    } catch (e) {
      return RemoteConfigModel.defaults();
    }
  }

  /// Returns [value] if it is a non-null, non-empty string; otherwise [fallback].
  static String _nonEmpty(dynamic value, String fallback) {
    if (value is String && value.isNotEmpty) return value;
    return fallback;
  }

  /// Factory constructor with hardcoded default values
  factory RemoteConfigModel.defaults() {
    return RemoteConfigModel(
      baseUrlDev: 'https://api.dev.example.com',
      baseUrlStaging: 'https://api.staging.example.com',
      baseUrlProd: 'https://api.example.com',
      serviceRegionId: (kDebugMode || _isDevOrStaging()) ? 'global' : 'florida',
      // Pass with `--dart-define=MAPS_API_KEY=...`.
      mapApiKey: const String.fromEnvironment('MAPS_API_KEY'),
      stripePublishableKey: stripeTestKey,
      termsURL: 'https://example.com/terms-of-service',
      privacyURL: 'https://example.com/privacy-policy',
      supportEmail: 'support@example.com',
      appDomain: 'example.com',
      websiteURL: 'https://onboarding.example.com',
      useOsrmInDebug: true,
      minRequiredVersion: '1.0.1',
      latestVersion: '1.0.1',
      updateTitle: 'Update Available',
      updateMessage:
          'A new version of the app is available. Please update to continue using the app.',
      appStoreUrl: 'https://apps.apple.com/',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=com.example.driverapp',
    );
  }

  RemoteConfigModel copyWith({
    bool? addressSearchV2Enabled,
    String? baseUrlDev,
    String? baseUrlStaging,
    String? baseUrlProd,
    // String? baseUrl,
    // String? socketUrl,
    String? serviceRegionId,
    String? mapApiKey,
    String? stripePublishableKey,
    String? termsURL,
    String? privacyURL,
    String? supportEmail,
    String? appDomain,
    String? websiteURL,
    bool? useOsrmInDebug,
    String? minRequiredVersion,
    String? latestVersion,
    String? updateTitle,
    String? updateMessage,
    String? appStoreUrl,
    String? playStoreUrl,
  }) {
    return RemoteConfigModel(
      addressSearchV2Enabled:
          addressSearchV2Enabled ?? this.addressSearchV2Enabled,
      baseUrlDev: baseUrlDev ?? this.baseUrlDev,
      baseUrlStaging: baseUrlStaging ?? this.baseUrlStaging,
      baseUrlProd: baseUrlProd ?? this.baseUrlProd,
      // baseUrl: baseUrl ?? this.baseUrl,
      // socketUrl: socketUrl ?? this.socketUrl,
      serviceRegionId: serviceRegionId ?? this.serviceRegionId,
      mapApiKey: mapApiKey ?? this.mapApiKey,
      stripePublishableKey: stripePublishableKey ?? this.stripePublishableKey,
      termsURL: termsURL ?? this.termsURL,
      privacyURL: privacyURL ?? this.privacyURL,
      supportEmail: supportEmail ?? this.supportEmail,
      appDomain: appDomain ?? this.appDomain,
      websiteURL: websiteURL ?? this.websiteURL,
      useOsrmInDebug: useOsrmInDebug ?? this.useOsrmInDebug,
      minRequiredVersion: minRequiredVersion ?? this.minRequiredVersion,
      latestVersion: latestVersion ?? this.latestVersion,
      updateTitle: updateTitle ?? this.updateTitle,
      updateMessage: updateMessage ?? this.updateMessage,
      appStoreUrl: appStoreUrl ?? this.appStoreUrl,
      playStoreUrl: playStoreUrl ?? this.playStoreUrl,
    );
  }

  @override
  String toString() {
    return 'RemoteConfigModel(baseUrlDev: $baseUrlDev, baseUrlStaging: $baseUrlStaging, baseUrlProd: $baseUrlProd, serviceRegionId: $serviceRegionId, minRequiredVersion: $minRequiredVersion, latestVersion: $latestVersion)';
  }
}
