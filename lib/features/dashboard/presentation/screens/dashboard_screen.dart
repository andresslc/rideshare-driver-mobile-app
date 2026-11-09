import 'dart:async';

import 'package:driver_app/core/constants/app_images.dart';
import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/location/ride_location_guard.dart';
import 'package:driver_app/core/location/service_region.dart';
import 'package:driver_app/core/services/location_service.dart';
import 'package:driver_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:driver_app/features/ride_room/presentation/states/ride_state.dart';
import 'package:driver_app/shared/widgets/custom_dialogue.dart';
import 'package:driver_app/features/dashboard/presentation/widgets/balance_widget.dart';
import 'package:driver_app/features/carpool/presentation/widgets/carpool_request_card.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_socket_provider.dart';
import 'package:driver_app/features/carpool/presentation/states/carpool_socket_states.dart';
import 'package:driver_app/features/dashboard/presentation/widgets/dashboard_appbar.dart';
import 'package:driver_app/features/dashboard/presentation/widgets/dashboard_car_and_rating_info_widget.dart';
import 'package:driver_app/features/dashboard/presentation/widgets/dashboard_location_widget.dart';
import 'package:driver_app/features/dashboard/presentation/widgets/dashboard_profile_toogle_widget.dart';
import 'package:driver_app/features/dashboard/presentation/widgets/dashboard_ride_stats.dart';
import 'package:driver_app/features/dashboard/presentation/screens/drawer.dart';
import 'package:driver_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:driver_app/l10n/app_localizations.dart';

import 'package:driver_app/shared/shared.dart';
import 'package:driver_app/core/services/app_update_service.dart';
import 'package:driver_app/shared/widgets/app_update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/google_maps_navigate_button.dart';
import '../../../user_profile/presentation/providers/user_profile_provider.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard>
    with WidgetsBindingObserver {
  bool _isDialogShowing = false;
  bool _isServiceRegionDialogShowing = false;
  bool _isRoutingToRecoveredCarpool = false;
  bool _isOnlineErrorDialogShowing = false;
  bool _openRideRequestsAfterGoingOnline = false;
  String? _currentAddress;
  final ZoomDrawerController zoomController = ZoomDrawerController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() async {
      // Process any pending notification tap from killed or background states
      locator<NotificationServices>().processPendingNotificationIfAny();

      // Check for optional update
      final updateStatus = await AppUpdateService.checkUpdateStatus();
      if (updateStatus == UpdateStatus.optionalUpdate && mounted) {
        unawaited(AppUpdateDialog.show(context, isForceUpdate: false));
      }

      //   ref.read(rideSocketProvider.notifier).initialize();

      if (ref.read(userProfileProvider).profile == null) {
        ref.read(userProfileProvider.notifier).fetchProfile(force: true);
      }
      ref.read(dashboardProvider.notifier).getDashboardData();
      _routeToRecoveredCarpoolIfNeeded(ref.read(carpoolSocketProvider));
      await ref.read(rideSocketProvider.notifier).requestRideResumeFromServer();
      await _checkLocation();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      locator<NotificationServices>().processPendingNotificationIfAny();

      // Small delay to allow the OS to update permission state after returning from settings
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _checkLocation();
          _routeToRecoveredCarpoolIfNeeded(ref.read(carpoolSocketProvider));
          unawaited(
            ref.read(rideSocketProvider.notifier).requestRideResumeFromServer(),
          );
        }
      });
    }
  }

  Future<void> _checkLocation() async {
    final l10n = context.l10n;
    final locationService = locator<LocationService>();

    // First, check basic availability (Service Enabled + Any Permission)
    final isAvailable = await locationService.isLocationAvailable();
    log('Location check: isAvailable=$isAvailable', name: 'DashboardLocation');

    if (isAvailable) {
      final accessStatus = await locationService
          .getCurrentServiceRegionAccessStatus();
      log(
        'Location check: accessStatus=$accessStatus',
        name: 'DashboardLocation',
      );

      if (accessStatus == ServiceRegionAccessStatus.outside) {
        if (mounted) _showServiceRegionDialog();
        return;
      }

      if (_isServiceRegionDialogShowing && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _isServiceRegionDialogShowing = false;
      }

      await _fetchCurrentAddress(locationService);
    } else {
      // If not available, request/check status for specific reason
      final result = await locationService.requestLocationPermission();
      log('Location check: requestResult=$result', name: 'DashboardLocation');

      if (result == LocationPermissionResult.granted) {
        if (_isDialogShowing && mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          _isDialogShowing = false;
        }
        await _fetchCurrentAddress(locationService);
      } else if (mounted) {
        _dismissLocationDialogIfNeeded();
        if (_shouldShowDashboardLocationDialog(result)) {
          if (result == LocationPermissionResult.serviceDisabled) {
            _showLocationDialog(
              title: l10n.location_services_disabled_title,
              subtitle: l10n.location_services_disabled_mesg,
              isServiceError: true,
            );
          } else {
            _showLocationDialog(
              title: l10n.location_permission_title,
              subtitle: result == LocationPermissionResult.permanentlyDenied
                  ? l10n.permanently_denied_mesg
                  : l10n.permission_denied_mesg,
              isServiceError: false,
            );
          }
        }
      }
    }
  }

  Future<void> _fetchCurrentAddress(LocationService locationService) async {
    final l10n = context.l10n;
    if (_isDialogShowing && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      _isDialogShowing = false;
    }

    final position = await locationService.getCurrentPosition();
    if (!mounted) return;

    if (position == null) {
      final accessStatus = await locationService
          .getCurrentServiceRegionAccessStatus();
      if (accessStatus == ServiceRegionAccessStatus.outside) {
        _showServiceRegionDialog();
        return;
      }

      setState(() {
        _currentAddress = l10n.unable_to_fetch_location;
      });
      return;
    }

    final address = await locationService.getAddressFromLatLng(
      position.latitude,
      position.longitude,
      reason: 'initial_position',
    );

    if (!mounted) return;

    setState(() {
      _currentAddress = address ?? l10n.current_location_available;
    });
  }

  void _showLocationDialog({
    required String title,
    required String subtitle,
    required bool isServiceError,
  }) {
    if (!_shouldShowDashboardLocationDialog(
      isServiceError
          ? LocationPermissionResult.serviceDisabled
          : LocationPermissionResult.denied,
    )) {
      return;
    }

    final l10n = context.l10n;
    final locationService = locator<LocationService>();

    _isDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: CustomDialogue(
          title: title,
          subtitle: subtitle,
          icon: isServiceError ? Icons.location_off : Icons.location_on,
          buttons: [
            AppButton(
              text: l10n.open_settings,
              onPressed: () async {
                if (isServiceError) {
                  await locationService.openLocationSettings();
                } else {
                  await locationService.openAppSettings();
                }
              },
              backgroundColor: context.appColors.brand,
              fontColor: Colors.white,
            ),
          ],
        ),
      ),
    ).then((_) => _isDialogShowing = false);
  }

  void _dismissLocationDialog() {
    if (_isDialogShowing && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      _isDialogShowing = false;
    }
  }

  bool get _isDashboardTopRoute =>
      GoRouter.of(context).state.name == Routes.home.name;

  bool get _isRideRequestTopRoute =>
      GoRouter.of(context).state.name == Routes.rideRequest.name;

  bool _shouldShowDashboardLocationDialog(LocationPermissionResult result) {
    if (_isDialogShowing || !_isDashboardTopRoute) {
      return false;
    }

    if (result == LocationPermissionResult.serviceDisabled &&
        RideLocationGuard.shouldBlockForDisabledLocation(
          rideState: ref.read(rideSocketProvider),
          isLocationServiceEnabled: false,
        )) {
      return false;
    }

    return true;
  }

  void _dismissLocationDialogIfNeeded() {
    final shouldDismissForGlobalBlocker =
        RideLocationGuard.shouldBlockForDisabledLocation(
          rideState: ref.read(rideSocketProvider),
          isLocationServiceEnabled: false,
        );

    if (_isDialogShowing &&
        mounted &&
        (!_isDashboardTopRoute || shouldDismissForGlobalBlocker)) {
      _dismissLocationDialog();
    }
  }

  void _showServiceRegionDialog() {
    if (_isServiceRegionDialogShowing || !mounted) {
      return;
    }

    final l10n = context.l10n;
    final regionName = ServiceRegionConfig.active.displayName;
    _isServiceRegionDialogShowing = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(l10n.service_region_title),
          content: Text(l10n.service_region_message(regionName)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _isServiceRegionDialogShowing = false;
                _checkLocation();
              },
              child: Text(l10n.retry),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _isServiceRegionDialogShowing = false;
                _logoutAndExit();
              },
              child: Text(l10n.service_region_logout),
            ),
          ],
        ),
      ),
    ).then((_) {
      _isServiceRegionDialogShowing = false;
    });
  }

  Future<void> _logoutAndExit() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    context.goNamed(Routes.login.name);
  }

  void _routeToRecoveredCarpoolIfNeeded(CarpoolSocketState state) {
    final hasRecoverable = _hasRecoverableCarpool(state);
    log(
      'routeToRecoveredCarpoolIfNeeded -> mounted=$mounted, isRouting=$_isRoutingToRecoveredCarpool, hasRecoverable=$hasRecoverable, action=${state.action}, status=${state.status}, activeCarpoolId=${state.activeCarpoolId}, hasRideResume=${state.lastRideResume != null}',
      name: 'DashboardCarpoolRoute',
    );
    if (_isRoutingToRecoveredCarpool || !hasRecoverable) {
      return;
    }

    _isRoutingToRecoveredCarpool = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _isRoutingToRecoveredCarpool = false;
        return;
      }
      log(
        'Pushing recovered carpool route -> ride_map',
        name: 'DashboardCarpoolRoute',
      );
      context.pushNamed(Routes.rideMap.name).whenComplete(() {
        log(
          'Recovered carpool route completed -> ride_map popped',
          name: 'DashboardCarpoolRoute',
        );
        _isRoutingToRecoveredCarpool = false;
      });
    });
  }

  bool _hasRecoverableCarpool(CarpoolSocketState state) {
    final stateCarpoolId = state.activeCarpoolId?.trim() ?? '';
    if (stateCarpoolId.isNotEmpty && state.lastRideResume != null) {
      return true;
    }

    final payload = state.lastRideResume ?? const <String, dynamic>{};
    final payloadCarpoolId =
        (payload['carpoolId'] ?? payload['_id'] ?? payload['id'] ?? '')
            .toString()
            .trim();
    return payloadCarpoolId.isNotEmpty;
  }

  void _goToCurrentCarpool() {
    context.goNamed(Routes.rideMap.name);
  }

  void _openRideRequests() {
    if (!mounted) {
      return;
    }
    _dismissLocationDialog();
    context.pushNamed(Routes.rideRequest.name);
  }

  void _handleRideRequestsTap() {
    final rideState = ref.read(rideSocketProvider);
    if (rideState.isOnline) {
      _openRideRequestsAfterGoingOnline = false;
      _openRideRequests();
      return;
    }

    final isToggleLoading =
        rideState.status == SocketStatus.loading &&
        rideState.action == SocketAction.driverOnline;
    if (isToggleLoading) {
      return;
    }
    context.showToast(context.l10n.normal_online_before_start);
    // _openRideRequestsAfterGoingOnline = true;
    // ref.read(rideSocketProvider.notifier).toggleDriverOnline(true);
  }

  void _showDriverOnlineErrorDialog(String message) {
    if (_isOnlineErrorDialogShowing || !mounted) {
      return;
    }

    _isOnlineErrorDialogShowing = true;
    showDialog(
      context: context,
      builder: (context) => CustomDialogue(
        title: context.l10n.unable_to_go_online_title,
        subtitle: message,
        icon: Icons.warning_amber_rounded,
        iconColor: context.colorScheme.error,
        buttons: [
          AppButton(
            text: context.l10n.ok,
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: context.appColors.brand,
            fontColor: Colors.white,
          ),
        ],
      ),
    ).then((_) {
      _isOnlineErrorDialogShowing = false;
    });
  }

  bool _isAuthFailureMessage(String message) {
    final normalized = message.trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }

    return normalized.contains('unauthorized') ||
        normalized.contains('re-login') ||
        normalized.contains('please re-login') ||
        normalized.contains('please re-login on a valid device') ||
        normalized.contains('session expired') ||
        normalized.contains('token expired');
  }

  bool get isRideRequestScreen => _isRideRequestTopRoute;
  @override
  Widget build(BuildContext context) {
    final socketState = ref.watch(carpoolSocketProvider);
    final user = ref.watch(userProfileProvider).profile?.user;
    ref.listen<RideSocketState>(rideSocketProvider, (previous, next) {
      if (RideLocationGuard.shouldBlockForDisabledLocation(
        rideState: next,
        isLocationServiceEnabled: false,
      )) {
        _dismissLocationDialogIfNeeded();
      }

      final nextMessage = next.message?.trim();
      final isDriverOnlineSuccess =
          previous?.action == SocketAction.driverOnline &&
          previous?.status == SocketStatus.loading &&
          next.status == SocketStatus.success &&
          next.isOnline;
      final isDriverOnlineError =
          previous?.action == SocketAction.driverOnline &&
          previous?.status == SocketStatus.loading &&
          next.action == SocketAction.driverOnline &&
          next.status == SocketStatus.error &&
          (nextMessage?.isNotEmpty ?? false);

      if (_openRideRequestsAfterGoingOnline && isDriverOnlineSuccess) {
        _openRideRequestsAfterGoingOnline = false;
        _openRideRequests();
        return;
      }

      if (isDriverOnlineError &&
          nextMessage != null &&
          !_isAuthFailureMessage(nextMessage)) {
        _openRideRequestsAfterGoingOnline = false;
        _showDriverOnlineErrorDialog(nextMessage);
      }
      // its driver is online and the ridereques is coming
      final hasNewIncomingRide =
          next.isOnline &&
          next.incomingRides.length > (previous?.incomingRides.length ?? 0);

      if (hasNewIncomingRide) {
        final router = GoRouter.of(context);
        final RouteMatch lastMatch =
            router.routerDelegate.currentConfiguration.last;
        final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
            ? lastMatch.matches
            : router.routerDelegate.currentConfiguration;
        final currentPath = matchList.uri.path;

        // Do not automatically route to the ride request screen if the driver is on:
        // 1. Personal details / profile screens
        // 2. Ride history or passenger details
        // 3. Wallet and bank account screens
        // 4. Carpool flow / map screens
        // 5. Delete account screens
        final isRestrictedPath =
            currentPath.startsWith('/profile') ||
            currentPath.startsWith('/ride-history') ||
            currentPath == Routes.ridehistorydetail.path ||
            currentPath == Routes.passengerdetail.path ||
            currentPath == Routes.ridedetailcarpool.path ||
            currentPath == Routes.wallet.path ||
            currentPath == Routes.bankAccount.path ||
            currentPath == Routes.addBankAccount.path ||
            currentPath == Routes.carpoolCreate.path ||
            currentPath == Routes.passengerList.path ||
            currentPath == Routes.carpoolFeedback.path ||
            currentPath == Routes.rideMap.path ||
            currentPath == Routes.deleteAccountOTP.path ||
            currentPath == Routes.deleteAccountVerify.path;
        if (currentPath != Routes.rideRequest.path && !isRestrictedPath) {
          _openRideRequests();
        }
      }
    });

    final dashboardState = ref.watch(dashboardProvider);
    final isRideOnline = ref.watch(
      rideSocketProvider.select((s) => s.isOnline),
    );
    final hasPendingRideRequests = ref.watch(
      rideSocketProvider.select((s) => s.incomingRides.isNotEmpty),
    );
    final l10n = AppLocalizations.of(context)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        image: context.isDark
            ? const DecorationImage(
                image: AssetImage(AppImages.bgTwo),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: ZoomDrawer(
        controller: zoomController,
        mainScreenTapClose: true,
        menuBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
        angle: 0.0,
        androidCloseOnBackTap: true,
        slideWidth: MediaQuery.of(context).size.width * 0.75,
        borderRadius: 24.0,
        showShadow: true,
        menuScreenWidth: double.infinity,
        drawerShadowsBackgroundColor: AppColors.brandLight,

        /// Drawer
        ///
        menuScreen: AppDrawer(zoomController: zoomController),

        /// AppBar with menu icon
        mainScreen: AppScaffold(
          padding: EdgeInsets.all(0),
          // backgroundColor: Colors.transparent,
          appBar: DashboardAppBar(
            zoomController: zoomController,

            onNotificationTap: () =>
                context.pushNamed(Routes.notificationsScreen.name),
            title: l10n.dashboard,
            isOnline: isRideOnline,
            onAvailableRidesTap: _handleRideRequestsTap,
          ),

          /// Body
          child: dashboardState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (data) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      DashboardLocationWidget(
                        location: _currentAddress ?? l10n.fetching_location,
                      ).animate().fadeIn(duration: 650.ms).slideY(begin: 0.1),

                      Divider(height: AppSizes.p20),

                      ProfileToggleWidget(
                            rating: data.driver.rating.toDouble(),
                            onChanged: (value) {
                              final notifier = ref.read(
                                rideSocketProvider.notifier,
                              );
                              if (value) {
                                notifier.toggleDriverOnline(true);
                              } else {
                                notifier.toggleDriverOffline();
                              }
                            },
                          )
                          .animate()
                          .fadeIn(delay: 100.ms)
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1, 1),
                            curve: Curves.easeOutBack,
                          ),

                      Divider(height: AppSizes.p20),

                      BalanceWidget(
                        balance: data.driver.totalBalance,
                        hasRideRequests: hasPendingRideRequests,
                        isOnline: isRideOnline,
                        onRideRequestsTap: _handleRideRequestsTap,
                      ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),

                      const Gap(AppSizes.p20),

                      DashboardRideStats(
                        totalRides: data.todayRides.toString(),
                        cancelledRides: data.cancelledRides.toString(),
                        compeletedRides: data.completedRides.toString(),
                      ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1),

                      const Gap(AppSizes.p20),

                      DashboardCarInfoCard(
                        title: context.l10n.your_car,
                        make: data.driver.vehicleDetails.make,
                        model: data.driver.vehicleDetails.model,
                        registrationNumber:
                            data.driver.vehicleDetails.registrationNumber,
                        plateNumber: data.driver.vehicleDetails.plateNumber,
                        vehicleType:
                            (user?.vehicleType?.trim().isNotEmpty ?? false)
                            ? user!.vehicleType
                            : user?.vehicleDetails.vehicleType.toUpperCase(),
                        imagePath: AppImages.suv,
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                      const Gap(AppSizes.p20),

                      CarpoolRequestCard(
                        firstTitle: context.l10n.carpool_ride,
                        secondTitle: context.l10n.carpool_promo_subtitle,
                        buttonText: _hasRecoverableCarpool(socketState)
                            ? context.l10n.go_to_ride_progress
                            : context.l10n.carpool_start_button,
                        onPressed: () {
                          if (_hasRecoverableCarpool(
                            ref.read(carpoolSocketProvider),
                          )) {
                            _goToCurrentCarpool();
                            return;
                          }

                          final isOnline = ref
                              .read(rideSocketProvider)
                              .isOnline;
                          if (!isOnline) {
                            context.showToast(
                              context.l10n.carpool_online_before_start,
                            );
                            return;
                          }

                          context.pushNamed(Routes.carpoolCreate.name);
                        },
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
