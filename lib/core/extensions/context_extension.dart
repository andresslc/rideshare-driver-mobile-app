import 'dart:async';

import 'package:driver_app/core/utils/toast_manager.dart';
import 'package:driver_app/shared/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/auth_user_entity.dart';
import '../../features/auth/presentation/screens/account_review_status_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/custom_dialogue.dart';
import '../core.dart';

/// Quick access to [MediaQuery] dimensions.
extension ContextExtension on BuildContext {
  double get screenHeight => MediaQuery.sizeOf(this).height;
  double get screenWidth => MediaQuery.sizeOf(this).width;
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  // localization
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension LoaderExtension on BuildContext {
  void showLoader() {
    CustomLoader().showLoader(this);
  }

  void hideLoader() {
    CustomLoader().hideLoader();
  }
}

extension ClearUserSession on BuildContext {
  void clearDriverSession() {
    locator<StorageService>().clearAuthSession();
    locator<ApiService>().clearAuthToken();
  }
}

extension CheckUserState on BuildContext {
  void whereToGo(AuthResponseEntity authEntity, {String? phoneNumber}) {
    log("WHERE TO GO $authEntity");
    // Case 1: User has NOT completed onboarding
    if (!authEntity.isOnboarded) {
      // Sub-case 1.1: Token and user data exist (account created)
      if (authEntity.user != null) {
        // If under review or rejected → go to Review Status screen

        if (authEntity.isUserProfileCreated == false) {
          // locator<ApiService>().clearAuthToken();
          // unawaited(locator<StorageService>().clearAuthSession());
          clearDriverSession();
          // Redirect to Login screen with info flag via query parameter for robustness
          goNamed(Routes.accountStatus.name);
          return;
        }
        if (authEntity.accountStatus != AccountReviewStatus.approved) {
          // locator<ApiService>().clearAuthToken();
          // unawaited(locator<StorageService>().clearAuthSession());
          clearDriverSession();

          goNamed(
            Routes.accountReviewStatus.name,
            extra: AccountReviewStatusArgs(status: authEntity.accountStatus),
          );
        } else {
          // If approved (but not onboarded) → Home
          goNamed(Routes.home.name);
        }

        // Sub-case 1.2: No token & no user → account not created on web
      } else {
        // Flag to indicate: Driver account not created yet
        // Defensive cleanup for partially persisted sessions.
        locator<ApiService>().clearAuthToken();
        unawaited(locator<StorageService>().clearAuthSession());

        // Redirect to Login screen with info flag via query parameter for robustness
        goNamed(
          Routes.login.name,
          queryParameters: {
            'show_warning': DateTime.now().millisecondsSinceEpoch.toString(),
          },
        );
      }

      // Case 2: User HAS completed onboarding
    } else {
      final String? subscriptionStatus = authEntity.user?.subscriptionStatus;

      if (subscriptionStatus == 'inactive' ||
          subscriptionStatus == 'canceled') {
        clearDriverSession();
        goNamed(Routes.subscriptionStatus.name, extra: subscriptionStatus);
        return;
      }

      /// Account not approved → Review Screen
      if (authEntity.accountStatus != AccountReviewStatus.approved) {
        clearDriverSession();

        goNamed(
          Routes.accountReviewStatus.name,
          extra: AccountReviewStatusArgs(status: authEntity.accountStatus),
        );
        return;
      }

      goNamed(Routes.home.name);
      return;

      /// Subscription NOT active / null → Status Screen
      // goNamed(Routes.subscriptionStatus.name, extra: subscriptionStatus);
      // return;
    }

    // else {
    //   // (Optional) Future: Check subscription status here
    //   if (user.user?.subscriptionStatus == 'active') {
    //     goNamed(Routes.home.name);
    //   } else {
    //     goNamed(Routes.home.name);
    //   }

    //   // Go directly to Home screen
    // }
  }

  // // Returns the route name based on user's onboarding and account status
  // String whereToGoRouteName(AuthResponseEntity user) {
  //   // Log response for debugging navigation decisions
  //   log("WHERE TO GO $user");

  //   // Case 1: User has NOT completed onboarding
  //   if (!user.isOnboarded) {
  //     // If account/documents are approved → go to Home
  //     if (user.accountStatus == AccountReviewStatus.approved) {
  //       return Routes.home.name;

  //       // If under review or rejected → go to Review Status screen
  //     } else {
  //       return Routes.accountReviewStatus.name;
  //     }

  //     // Case 2: User HAS completed onboarding
  //   } else {
  //     // Go directly to Home screen
  //     return Routes.home.name;
  //   }
  // }
}

extension ToastExtension on BuildContext {
  void showToast(
    String message, {
    Duration duration = const Duration(seconds: 3),
    ToastType type = ToastType.info,
  }) {
    ToastManager.showToast(
      this,
      message: message,
      duration: duration,
      type: type,
    );
  }

  void showSuccessToast(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showToast(message, duration: duration, type: ToastType.success);
  }

  void showWarningToast(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showToast(message, duration: duration, type: ToastType.warning);
  }

  void showErrorToast(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showToast(message, duration: duration, type: ToastType.error);
  }
}

extension AppDialogExtension on BuildContext {
  void showReReviewWarning(VoidCallback onConfirm) {
    showDialog(
      context: this,
      builder: (context) => CustomDialogue(
        title: l10n.warning,
        subtitle: l10n.under_review_subtitle,
        // "Updating these details will put your account back under review. You won't be able to accept rides until you are re-approved. Do you want to continue?",
        icon: Icons.info_outline_rounded,
        iconColor: context.appColors.brand,
        buttons: [
          AppButton(
            text: context.l10n.cancel,
            onPressed: () => Navigator.pop(context),
            backgroundColor: context.appColors.fieldFill,
            fontColor: context.appColors.textPrimary,
          ),
          AppButton(
            text: context.l10n.confirm,
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            backgroundColor: context.appColors.brand,
            fontColor: Colors.white,
          ),
        ],
      ),
    );
  }

  void showGoBackWarning(VoidCallback onConfirm) {
    showDialog(
      context: this,
      builder: (context) => CustomDialogue(
        title: l10n.warning,
        subtitle: l10n.going_back_under_review,
        // "Going back will put you in under review. Are you sure you want to go back? You can update these details if you want.",
        icon: Icons.info_outline_rounded,
        iconColor: context.appColors.brand,
        buttons: [
          AppButton(
            text: context.l10n.cancel,
            onPressed: () => Navigator.pop(context),
            backgroundColor: context.appColors.fieldFill,
            fontColor: context.appColors.textPrimary,
          ),
          AppButton(
            text: context.l10n.confirm,
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            backgroundColor: context.appColors.brand,
            fontColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
