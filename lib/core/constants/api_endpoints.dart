import 'package:driver_app/core/constants/constants_data.dart';

/// Centralised API endpoint constants.
/// Base URL is driven by Firebase Remote Config.
class ApiEndpoints {
  ApiEndpoints._();

  // static String get baseUrl => remoteConfigModel.baseUrl;
  // static String get socketUrl => remoteConfigModel.socketUrl;
  static String get mapApiKey => remoteConfigModel.mapApiKey;
  static String get stripePublishableKey =>
      remoteConfigModel.stripePublishableKey;

  static String get termsUrl => remoteConfigModel.termsURL;
  static String get privacyPolicyUrl => remoteConfigModel.privacyURL;
  static bool get useOsrmInDebug => remoteConfigModel.useOsrmInDebug;

  // ── Auth ────────────────────────────────────────────────────────────────
  // static const String register = '/auth/register';
  static const String sendOtp = '/api/auth/send-otp';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String logout = '/api/auth/logout';

  // static const String toggleNotification = '/api/notification/user/toggle';
  static const String toggleNotification = '/api/notification/driver/toggle';

  // static const String logout = '/auth/logout';
  // static const String refreshToken = '/auth/refresh';

  // ── User ────────────────────────────────────────────────────────────────

  static const String deleteAccount = '/api/driver/delete';

  static const String profile = '/api/driver/me';
  static const String updateProfile = '/api/driver/edit/';
  static const String vehicleTypes = '/api/admin/vehicle-types';

  // ── Wallet ──────────────────────────────────────────────────────────────
  static const String transactionHistory = '/api/driver/transaction-history';
  static const String setupAccount = '/api/driver/setup-account';
  static const String withdraw = '/api/driver/withdraw';
  static const String banksList = '/api/driver/banks-list';
  static const String attachBankAccount = '/api/driver/attach-bank';
  static const String deleteBankAccount = '/api/driver/delete-bank';
  static const String changeLanguage = '/api/user/change-locale';

  // ── Driver referral ─────────────────────────────────────────────────────
  static const String driverReferralSummary = '/api/driver-referral/driver/me';
  static const String driverReferralHistory =
      '/api/driver-referral/driver/history';

  // ── Ride ────────────────────────────────────────────────────────────────
  static const String availableRides = '/api/rides';

  /// Public: dispatch rings, distance unit and server-side texts.
  static const String rideConfig = '/api/config/ride';
  static String rideById(String id) => '/api/rides/$id';
  static const String dashBoard = '/api/driver/dashboard';

  //review
  static const String review = '/api/review';
  static const String getreview = '/api/review';
  static const String report = '/api/report';

  //ridehistory

  static const String ridehistory = "/api/rides/history";
  static const String ridedetail = "/api/rides/";
  static const String carpoolhistory = "/api/carpool/history";
  //   static const String carpooldetail = "/api/carpool/";
  static String passenger(String id) => "/api/carpool/$id/passengers/details";

  //Carpool
  static const String viewPassenger = "/api/carpool/";

  //Ride Chat
  static String getChatHistory(String rideId) => '/api/chat/$rideId/history';
  static const String sendMessage = "/api/chat/send";

  // Notifications
  static const String getNotifications = "/api/notification";
  static const String deleteAllNotifications = "/api/notification";
  static String deleteNotification(String id) => "/api/notification/$id";
}
