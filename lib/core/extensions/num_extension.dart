import 'package:driver_app/core/config/ride_config_model.dart';
import 'package:driver_app/core/config/ride_config_service.dart';
import 'package:driver_app/core/di/service_locator.dart';

/// Distance formatting driven by the server.
///
/// The backend decides the unit (`GET /config/ride` → `distanceUnit`) and sends
/// every distance already expressed in it, so the app only appends the label.
/// Converting client side would fight the panel: it is deliberately not done.
extension NumDistanceExtension on num {
  /// e.g. `8.4` → `"8.4 mi"`, or `"8.4 km"` once the panel says so.
  String formatDistance({int decimalDigits = 1}) {
    return '${toStringAsFixed(decimalDigits)} ${distanceUnitLabel()}';
  }
}

/// Unit every distance is printed in. Falls back to the cached value, and to
/// [RideConfigModel.defaultDistanceUnit] only when nothing was ever fetched.
String distanceUnitLabel() {
  if (!locator.isRegistered<RideConfigService>()) {
    return RideConfigModel.defaultDistanceUnit;
  }
  final String unit = locator<RideConfigService>().distanceUnit.trim();
  return unit.isEmpty ? RideConfigModel.defaultDistanceUnit : unit;
}
