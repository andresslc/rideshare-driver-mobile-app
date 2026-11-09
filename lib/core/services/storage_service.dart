import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Generic SharedPreferences wrapper for common persistence needs.
///
/// Add domain-specific keys/methods as your app grows —
/// but keep this class free of business logic.
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // ── Auth ────────────────────────────────────────────────────────────────

  static const String _keyToken = 'token';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUID = 'uid';
  static const String _keyUser = 'user';
  static const String _keyLanguageCode = 'language_code';

  /// Last good `GET /config/ride` payload, used while the endpoint is
  /// unreachable so the app never falls back to compiled-in units or texts.
  static const String _keyRideConfig = 'ride_config';

  Future<void> setRideConfig(String encoded) async =>
      _prefs.setString(_keyRideConfig, encoded);

  String? get getRideConfig => _prefs.getString(_keyRideConfig);

  Future<void> setToken(String token) async =>
      _prefs.setString(_keyToken, token);

  String? get getToken => _prefs.getString(_keyToken);

  Future<void> setLoginStatus(bool loggedIn) async =>
      _prefs.setBool(_keyIsLoggedIn, loggedIn);

  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;

  Future<void> setUID(String uid) async => _prefs.setString(_keyUID, uid);

  String? get getUID => _prefs.getString(_keyUID);

  Future<bool> setUser(Map<String, dynamic>? val) async =>
      _prefs.setString(_keyUser, jsonEncode(val));

  // String? get getUser => _prefs.getString(_keyUser);
  Map<String, dynamic>? get getUser {
    final data = _prefs.getString(_keyUser);

    if (data == null) return null;

    return jsonDecode(data) as Map<String, dynamic>;
  }

  /// Clears only authentication/session related keys.
  Future<void> clearAuthSession() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUser);
    await _prefs.remove(_keyUID);
    await _prefs.remove(_keyFCM);
    await _prefs.remove(_keyThemeMode);
    await clearPickupWaitWindow();
    await clearRideChatUnreadState();
    await clearCarpoolChatUnreadState();
    await _prefs.setBool(_keyIsLoggedIn, false);
  }

  // ── Pickup wait timer (reached pickup) ───────────────────────────────────

  static const String _keyPickupWaitRideId = 'pickup_wait_ride_id';
  static const String _keyPickupWaitEndsAtMs = 'pickup_wait_ends_at_ms';
  static const String _keyPickupWaitDurationMs = 'pickup_wait_duration_ms';
  static const String _keyUnreadRideChatRideId = 'unread_ride_chat_ride_id';
  static const String _keyUnreadRideChatHasUnread =
      'unread_ride_chat_has_unread';
  static const String _keyUnreadCarpoolChatCarpoolId =
      'unread_carpool_chat_carpool_id';
  static const String _keyUnreadCarpoolChatPassengerIds =
      'unread_carpool_chat_passenger_ids';

  /// Persists wall-clock end time so the wait countdown survives app restarts.
  Future<void> savePickupWaitWindow({
    required String rideId,
    required DateTime endsAt,
    required Duration duration,
  }) async {
    await _prefs.setString(_keyPickupWaitRideId, rideId);
    await _prefs.setInt(_keyPickupWaitEndsAtMs, endsAt.millisecondsSinceEpoch);
    await _prefs.setInt(_keyPickupWaitDurationMs, duration.inMilliseconds);
  }

  Future<void> clearPickupWaitWindow() async {
    await _prefs.remove(_keyPickupWaitRideId);
    await _prefs.remove(_keyPickupWaitEndsAtMs);
    await _prefs.remove(_keyPickupWaitDurationMs);
  }

  // ── Chat unread indicators ────────────────────────────────────────────────

  /// Persists unread-dot state for an active normal ride.
  Future<void> saveRideChatUnreadState({
    required String rideId,
    required bool hasUnread,
  }) async {
    await _prefs.setString(_keyUnreadRideChatRideId, rideId);
    await _prefs.setBool(_keyUnreadRideChatHasUnread, hasUnread);
  }

  RideChatUnreadPersisted? getRideChatUnreadState() {
    final rideId = _prefs.getString(_keyUnreadRideChatRideId);
    final hasUnread = _prefs.getBool(_keyUnreadRideChatHasUnread);
    if (rideId == null || rideId.isEmpty || hasUnread == null) {
      return null;
    }
    return RideChatUnreadPersisted(rideId: rideId, hasUnread: hasUnread);
  }

  Future<void> clearRideChatUnreadState() async {
    await _prefs.remove(_keyUnreadRideChatRideId);
    await _prefs.remove(_keyUnreadRideChatHasUnread);
  }

  /// Persists unread passenger-user ids for an active carpool route.
  Future<void> saveCarpoolChatUnreadState({
    required String carpoolId,
    required Set<String> unreadPassengerUserIds,
  }) async {
    await _prefs.setString(_keyUnreadCarpoolChatCarpoolId, carpoolId);
    await _prefs.setStringList(
      _keyUnreadCarpoolChatPassengerIds,
      unreadPassengerUserIds.toList(growable: false),
    );
  }

  CarpoolChatUnreadPersisted? getCarpoolChatUnreadState() {
    final carpoolId = _prefs.getString(_keyUnreadCarpoolChatCarpoolId);
    final ids = _prefs.getStringList(_keyUnreadCarpoolChatPassengerIds);
    if (carpoolId == null || carpoolId.isEmpty || ids == null) {
      return null;
    }
    return CarpoolChatUnreadPersisted(
      carpoolId: carpoolId,
      unreadPassengerUserIds: ids
          .map((id) => id.trim().toLowerCase())
          .where((id) => id.isNotEmpty)
          .toSet(),
    );
  }

  Future<void> clearCarpoolChatUnreadState() async {
    await _prefs.remove(_keyUnreadCarpoolChatCarpoolId);
    await _prefs.remove(_keyUnreadCarpoolChatPassengerIds);
  }

  /// Stored pickup wait for the active ride, if any.
  PickupWaitPersisted? getPickupWaitWindow() {
    final rideId = _prefs.getString(_keyPickupWaitRideId);
    final endsAtMs = _prefs.getInt(_keyPickupWaitEndsAtMs);
    final durationMs = _prefs.getInt(_keyPickupWaitDurationMs);
    if (rideId == null ||
        rideId.isEmpty ||
        endsAtMs == null ||
        durationMs == null) {
      return null;
    }
    return PickupWaitPersisted(
      rideId: rideId,
      endsAt: DateTime.fromMillisecondsSinceEpoch(endsAtMs),
      duration: Duration(milliseconds: durationMs),
    );
  }

  // ── Theme ───────────────────────────────────────────────────────────────

  static const String _keyThemeMode = 'theme_mode';

  Future<void> setThemeMode(String mode) async =>
      _prefs.setString(_keyThemeMode, mode);

  String? get getThemeMode => _prefs.getString(_keyThemeMode);

  // ── FCM ─────────────────────────────────────────────────────────────────

  static const String _keyFCM = 'fcm_token';

  Future<void> setFCMToken(String token) async =>
      _prefs.setString(_keyFCM, token);

  String? get getFCMToken => _prefs.getString(_keyFCM);

  // ── Generic helpers ─────────────────────────────────────────────────────

  Future<bool> setString(String key, String value) async =>
      _prefs.setString(key, value);

  String? getString(String key) => _prefs.getString(key);

  Future<void> clear() async => _prefs.clear();

  Future<bool> remove(String key) async => _prefs.remove(key);

  String? get getLanguageCode => _prefs.getString(_keyLanguageCode);
}

/// Values read from [StorageService.getPickupWaitWindow].
class PickupWaitPersisted {
  final String rideId;
  final DateTime endsAt;
  final Duration duration;

  const PickupWaitPersisted({
    required this.rideId,
    required this.endsAt,
    required this.duration,
  });
}

class RideChatUnreadPersisted {
  final String rideId;
  final bool hasUnread;

  const RideChatUnreadPersisted({
    required this.rideId,
    required this.hasUnread,
  });
}

class CarpoolChatUnreadPersisted {
  final String carpoolId;
  final Set<String> unreadPassengerUserIds;

  const CarpoolChatUnreadPersisted({
    required this.carpoolId,
    required this.unreadPassengerUserIds,
  });
}
