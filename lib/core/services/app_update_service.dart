import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../constants/constants_data.dart';
import '../di/service_locator.dart';
import '../utils/app_log.dart';

enum UpdateStatus { upToDate, optionalUpdate, forceUpdate }

class AppUpdateService {
  static bool _hasPromptedOptionalUpdate = false;

  static bool get _isAllowtoCheckUpdate {
    if (!locator.isRegistered<AppConfig>()) return false;
    return locator<AppConfig>().flavor == Flavor.dev ||
        locator<AppConfig>().flavor == Flavor.staging;
  }

  static Future<UpdateStatus> checkUpdateStatus() async {
    if (_isAllowtoCheckUpdate) {
      return UpdateStatus.upToDate;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final minRequired = remoteConfigModel.minRequiredVersion;
      final latest = remoteConfigModel.latestVersion;

      log(
        "Current Version: $currentVersion, Min Required: $minRequired, Latest: $latest",
        name: "AppUpdateService",
      );

      if (_isVersionLower(currentVersion, minRequired)) {
        return UpdateStatus.forceUpdate;
      } else if (_isVersionLower(currentVersion, latest)) {
        if (_hasPromptedOptionalUpdate) return UpdateStatus.upToDate;

        _hasPromptedOptionalUpdate = true;
        return UpdateStatus.optionalUpdate;
      }
    } catch (e) {
      log("Error checking update status: $e", name: "AppUpdateService");
    }
    return UpdateStatus.upToDate;
  }

  static bool _isVersionLower(String current, String target) {
    if (target.isEmpty) return false;

    List<int> currentParts = current
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    List<int> targetParts = target
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    // Pad with zeros if necessary
    int maxLength = currentParts.length > targetParts.length
        ? currentParts.length
        : targetParts.length;
    while (currentParts.length < maxLength) {
      currentParts.add(0);
    }
    while (targetParts.length < maxLength) {
      targetParts.add(0);
    }

    for (int i = 0; i < maxLength; i++) {
      if (currentParts[i] < targetParts[i]) return true;
      if (currentParts[i] > targetParts[i]) return false;
    }
    return false;
  }

  static Future<void> launchStore() async {
    final url = Platform.isIOS
        ? remoteConfigModel.appStoreUrl
        : remoteConfigModel.playStoreUrl;

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      log("Could not launch store URL: $url", name: "AppUpdateService");
    }
  }
}
