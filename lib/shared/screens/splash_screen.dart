// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/services/app_update_service.dart';
import 'package:driver_app/core/services/device_info_service.dart';
import 'package:driver_app/features/auth/presentation/screens/account_review_status_screen.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_socket_provider.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:driver_app/features/user_profile/domain/entites/user_profile_entity.dart';
import 'package:driver_app/features/user_profile/presentation/providers/user_profile_provider.dart';
import 'package:driver_app/shared/widgets/app_logo.dart';
import 'package:driver_app/shared/widgets/app_update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  bool _animationDone = false;
  bool _logicDone = false;
  bool _hasNavigated = false;

  String? _routeName;
  Object? _extra;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.5, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    _controller.forward().whenComplete(_onAnimationFinish);

    locator<DeviceInfoService>().init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_checkUpdateAndState());
    });
  }

  Future<void> _checkUpdateAndState() async {
    // 1. Check for updates
    final updateStatus = await AppUpdateService.checkUpdateStatus();

    if (updateStatus == UpdateStatus.forceUpdate) {
      if (mounted) {
        await AppUpdateDialog.show(context, isForceUpdate: true);
      }
      return; // Stop everything, force the user to update
    }

    if (updateStatus == UpdateStatus.optionalUpdate) {
      if (mounted) {
        // We don't await here because we want to continue to auth check
        unawaited(AppUpdateDialog.show(context, isForceUpdate: false));
      }
    }

    // 2. Continue with original state check
    await _checkUserState();
  }

  /// -----------------------------
  /// YOUR APP LOGIC (AUTH CHECK)
  /// -----------------------------
  Future<void> _checkUserState() async {
    await Future.delayed(const Duration(seconds: 2)); // optional loading buffer

    final storage = locator<StorageService>();
    final String? token = storage.getToken;

    if (token != null && token.isNotEmpty && mounted) {
      locator<ApiService>().setAuthToken(token);

      await ref
          .read(userProfileProvider.notifier)
          .fetchProfile(
            force: true,
            onSuccess: onSuccess,
            onError: () async {
              if (!mounted) return;

              final rideSocketNotifier = ref.read(rideSocketProvider.notifier);
              await rideSocketNotifier.stop();
              await locator<WakelockService>().setEnabled(false);

              _setNavigation(Routes.login.name);
            },
          );
    } else {
      await locator<WakelockService>().setEnabled(false);
      _setNavigation(Routes.login.name);
    }
  }

  Future<void> onSuccess(UserProfileEntity user) async {
    if (!mounted) return;

    ref.read(carpoolSocketProvider.notifier);

    final rideSocketNotifier = ref.read(rideSocketProvider.notifier);
    await rideSocketNotifier.initialize();

    // final status = user.user.subscriptionInfo.status;

    // if (status == 'active') {
    //   _setNavigation(Routes.home.name);
    // } else {
    //   _setNavigation(Routes.subscriptionStatus.name, extra: status);
    // }

    // if (!user.isOnboarded) {
    // Sub-case 1.1: Token and user data exist (account created)
    // If under review or rejected → go to Review Status screen

    if (user.user.isUserProfileCreated == false) {
      context.clearDriverSession();
      _setNavigation(Routes.accountStatus.name);
      return;
    }
    if (user.user.accountStatus != AccountReviewStatus.approved) {
      context.clearDriverSession();
      _setNavigation(
        Routes.accountReviewStatus.name,
        extra: AccountReviewStatusArgs(status: user.user.accountStatus),
      );
    } else {
      await locator<WakelockService>().setEnabled(true);
      // If approved (but not onboarded) → Home
      _setNavigation(Routes.home.name);
    }

    // Sub-case 1.2: No token & no user → account not created on web
  }

  /// -----------------------------
  /// SET NAVIGATION TARGET
  /// -----------------------------
  void _setNavigation(String routeName, {Object? extra}) {
    _routeName = routeName;
    _extra = extra;
    _logicDone = true;
    _tryNavigate();
  }

  /// -----------------------------
  /// SPLASH ANIMATION FINISH HANDLER
  /// -----------------------------
  void _onAnimationFinish() async {
    _animationDone = true;

    await Future.delayed(const Duration(seconds: 1)); // your 1 sec delay
    _tryNavigate();
  }

  /// -----------------------------
  /// NAVIGATION CHECK
  /// -----------------------------
  void _tryNavigate() async {
    if (!_animationDone || !_logicDone || _hasNavigated || !mounted) return;

    _hasNavigated = true;

    // With driver offers retired there is no pending-offer state to reopen on
    // launch: the driver simply lands where the session says.
    context.goNamed(_routeName ?? Routes.login.name, extra: _extra);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDark ? Colors.black : Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(scale: _scale, child: const AppLogo(size: 120)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
// class SplashScreen extends ConsumerStatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   ConsumerState<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends ConsumerState<SplashScreen> {
//   final Completer<void> _logoAnimationCompleter = Completer<void>();
//   bool _hasNavigated = false;

//   @override
//   void initState() {
//     super.initState();
//     locator<DeviceInfoService>().init();
//     unawaited(GifView.preFetchImage(const AssetImage(AppImages.logoGif)));
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       unawaited(checkUserState());
//     });
//   }

//   Future<void> checkUserState() async {
//     final storage = locator<StorageService>();
//     final String? token = storage.getToken;
//     log('~~~SplashScreen Token Check: $token');

//     if (token != null && mounted) {
//       locator<ApiService>().setAuthToken(token);

//       await ref
//           .read(userProfileProvider.notifier)
//           .fetchProfile(
//             force: true,
//             onSuccess: (user) async {
//               if (!mounted) return;

//               ref.read(carpoolSocketProvider.notifier);
//               final rideSocketNotifier = ref.read(rideSocketProvider.notifier);
//               await rideSocketNotifier.initialize();

//               final String subscriptionStatus =
//                   user.user.subscriptionInfo.status;
//               if (subscriptionStatus == 'active') {
//                 await _navigateAfterSplash(Routes.home.name);
//               } else {
//                 await _navigateAfterSplash(
//                   Routes.subscriptionStatus.name,
//                   extra: subscriptionStatus,
//                 );
//               }
//             },
//             onError: () async {
//               if (!mounted) return;

//               final rideSocketNotifier = ref.read(rideSocketProvider.notifier);
//               await rideSocketNotifier.stop();
//               await _navigateAfterSplash(Routes.login.name);
//             },
//           );
//       return;
//     }
//     await Future.delayed(const Duration(seconds: 5));

//     if (mounted) {
//       await _navigateAfterSplash(Routes.login.name);
//     }
//   }

//   Future<void> _navigateAfterSplash(String routeName, {Object? extra}) async {
//     await _logoAnimationCompleter.future;
//     if (!mounted || _hasNavigated) {
//       return;
//     }

//     final String currentLocation = AppRouter
//         .router
//         .routeInformationProvider
//         .value
//         .uri
//         .toString();
//     if (currentLocation != Routes.root.path) {
//       return;
//     }

//     _hasNavigated = true;
//     context.goNamed(routeName, extra: extra);
//   }

//   void _markAnimationComplete() {
//     if (_logoAnimationCompleter.isCompleted) {
//       return;
//     }
//     _logoAnimationCompleter.complete();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body:
//           Center(
//             child: GifView.asset(
//               AppImages.logoGif,
//               // width: 250,
//               height: context.screenHeight,
//               fit: BoxFit.cover,
//               loop: false,
//               imageRepeat: ImageRepeat.noRepeat,
//               onFinish: _markAnimationComplete,
//               errorBuilder: (context, error, tryAgain) {
//                 _markAnimationComplete();
//                 return Image.asset(
//                   AppImages.logo,
//                   fit: BoxFit.cover,
//                 );
//               },
//             ),
//           ),
//     );
//   }
// }
