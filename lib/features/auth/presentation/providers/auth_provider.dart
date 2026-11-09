import 'package:driver_app/core/core.dart';
import 'package:driver_app/features/auth/domain/use_cases/logout_usecase.dart';
import 'package:driver_app/features/auth/domain/use_cases/delete_account_usecase.dart';
import 'package:driver_app/features/auth/presentation/screens/account_review_status_screen.dart';
import 'package:driver_app/features/auth/presentation/states/auth_state.dart';
import 'package:driver_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:driver_app/features/user_profile/presentation/providers/user_profile_provider.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_socket_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/params/auth_params.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/use_cases/send_otp_usecase.dart';
import '../../domain/use_cases/verify_otp_usecase.dart';

final authProvider = NotifierProvider<AuthController, AuthState>(
  () => AuthController(),

  // (locator<StorageService>(), locator<ApiService>()),
);

class AuthController extends Notifier<AuthState> {
  late StorageService storageService;
  late ApiService apiService;

  // AuthController();
  // this.storageService, this.apiService);

  @override
  AuthState build() {
    storageService = locator<StorageService>();
    apiService = locator<ApiService>();
    return AuthInitial(); // initial state
  }

  /// ------------------------------
  /// SEND OTP
  /// ------------------------------
  Future<void> sendOtp(SendOtpParams params) async {
    state = const AuthLoading();

    apiService.clearAuthToken();
    final result = await locator<SendOtpUseCase>().call(params);

    state = result.fold(
      (failure) => AuthError(failure.message),
      (result) => OtpSent(result),
    );
  }

  Future<void> sendDeleteAccountOtp(SendOtpParams params) async {
    state = const AuthLoading();

    // Do NOT clear auth token for account deletion
    final result = await locator<SendOtpUseCase>().call(params);

    state = result.fold(
      (failure) => AuthError(failure.message),
      (result) => OtpSent(result),
    );
  }

  Future<void> resendOtp(SendOtpParams params) async {
    state = const AuthLoading();

    apiService.clearAuthToken();
    final result = await locator<SendOtpUseCase>().call(params);

    state = result.fold(
      (failure) => AuthError(failure.message),
      (result) => OtpResent(result),
    );
  }

  /// ------------------------------
  /// VERIFY OTP
  /// ------------------------------
  /// Token save already handled in datasource
  Future<void> verifyOtp(VerifyOtpParams params) async {
    // Loading state
    state = const AuthLoading();

    final result = await locator<VerifyOtpUseCase>().call(params);

    state = await result.fold<Future<AuthState>>((failure) async {
      return AuthError(failure.message);
    }, (authResponse) async {
      final token = authResponse.token;
      final hasToken = token != null && token.isNotEmpty;
      final subscription = authResponse.user?.subscriptionStatus;

      final bool isApproved =
          authResponse.accountStatus == AccountReviewStatus.approved;
      final bool isProfileCreated = authResponse.isUserProfileCreated;
      final bool isSubscriptionActive =
          subscription != 'inactive' && subscription != 'canceled';
      final bool canAccessDriverApp =
          hasToken &&
          authResponse.user != null &&
          isApproved &&
          isProfileCreated &&
          isSubscriptionActive;

      if (canAccessDriverApp) {
        apiService.setAuthToken(token);
        await storageService.setToken(token);
        await storageService.setLoginStatus(true);
        await locator<WakelockService>().setEnabled(true);

        // Saving user
        await storageService.setUser(authResponse.toJson());

        // Invalidate providers to ensure fresh data for the new user
        ref.invalidate(dashboardProvider);
        ref.invalidate(userProfileProvider);
        ref.invalidate(carpoolSocketProvider);
        ref.invalidate(rideSocketProvider);

        // Connect socket for authenticated user
        await _connectSocketForAuthenticatedUser();
      } else {
        // Defensive cleanup when driver is unapproved/under review/inactive subscription
        apiService.clearAuthToken();
        await storageService.clearAuthSession();
        await locator<WakelockService>().setEnabled(false);
        await ref.read(rideSocketProvider.notifier).stop();
      }

      // Return state
      return OtpVerified(authResponse); // new state class for verified OTP
    });
  }


  /// ------------------------------
  /// LOGOUT
  /// ------------------------------
  Future<void> logout() async {
    // state = const AuthLoading();

    // try {
    await Future.wait([
      locator<LogoutUseCase>().call(),
      ref.read(rideSocketProvider.notifier).stop(),
      storageService.clearAuthSession(),
    ]);

    apiService.clearAuthToken();
    await locator<WakelockService>().setEnabled(false);
    ref.invalidate(dashboardProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(carpoolSocketProvider);
    ref.invalidate(rideSocketProvider);

    // state = LoggedOut();
    // } catch (_) {
    //   // log();
    //   state = const AuthError('Unable to logout right now. Please try again.');
    // }
  }

  /// ------------------------------
  /// DELETE ACCOUNT
  /// ------------------------------
  Future<void> deleteAccount(String otp) async {
    state = const AuthLoading();

    final result = await locator<DeleteAccountUseCase>().call(otp);

    await result.fold<Future<void>>((failure) async {
      state = AuthError(failure.message);
    }, (_) async {
      /// Delete Stored Data
      await Future.wait([
        ref.read(rideSocketProvider.notifier).stop(),
        storageService.clearAuthSession(),
      ]);

      apiService.clearAuthToken();
      await locator<WakelockService>().setEnabled(false);
      ref.invalidate(dashboardProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(carpoolSocketProvider);
      ref.invalidate(rideSocketProvider);
      state = AccountDeleted();
    });
  }

  Future<void> _connectSocketForAuthenticatedUser() async {
    final String? token = storageService.getToken;
    if (token == null || token.isEmpty) return;
    await ref.read(rideSocketProvider.notifier).initialize();
  }
}
