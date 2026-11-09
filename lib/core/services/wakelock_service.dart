import 'package:wakelock_plus/wakelock_plus.dart';

/// Keeps the device screen awake while the driver is actively logged in.
class WakelockService {
  Future<void> setEnabled(bool enabled) {
    return enabled ? WakelockPlus.enable() : WakelockPlus.disable();
  }
}
