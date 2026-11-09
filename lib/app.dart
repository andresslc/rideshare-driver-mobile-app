import 'dart:async';
import 'package:driver_app/core/di/service_locator.dart';
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/core/location/ride_location_guard.dart';
import 'package:driver_app/core/services/location_service.dart';
import 'package:driver_app/core/services/notification_service.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:driver_app/shared/widgets/custom_dialogue.dart';
import 'package:driver_app/l10n/language_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'package:driver_app/core/services/connectivity_service.dart';
import 'package:driver_app/core/services/network_quality_service.dart';
import 'package:driver_app/shared/widgets/no_internet_screen.dart';
import 'package:driver_app/shared/widgets/slow_connection_screen.dart';
import 'package:driver_app/shared/widgets/slow_connection_banner.dart';
import 'l10n/app_localizations.dart';

/// Root application widget.
///
/// Uses [ValueListenableBuilder] to react to theme mode changes
/// without depending on any specific state management package.
class MyApp extends StatelessWidget {
  final ThemeNotifier themeNotifier;

  const MyApp({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appLanguageNotifier,
      builder: (context, locale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, themeMode, _) {
            return MaterialApp.router(
              title: 'App Template',
              debugShowCheckedModeBanner: false,
              // ── Theme ──────────────────────────────────────────────
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,

              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: locale,
              // ── Routing ────────────────────────────────────────────
              routerConfig: AppRouter.router,

              // ── Global Overlay for No Internet ──────────────────────
              // builder: (context, child) {
              //   return ValueListenableBuilder<bool>(
              //     valueListenable: ConnectivityService.instance.isOnline,
              //     builder: (context, isOnline, _) {
              //       if (!isOnline) {
              //         return const NoInternetScreen();
              //       }
              //       return child!;
              //     },
              //   );
              // },
              builder: (context, child) {
                return AppBlockingOverlays(child: child!);
              },
            );
          },
        );
      },
    );
  }
}

class AppBlockingOverlays extends ConsumerStatefulWidget {
  final Widget child;
  const AppBlockingOverlays({super.key, required this.child});

  @override
  ConsumerState<AppBlockingOverlays> createState() =>
      _AppBlockingOverlaysState();
}

class _AppBlockingOverlaysState extends ConsumerState<AppBlockingOverlays>
    with WidgetsBindingObserver {
  bool _isOnline = true;
  bool _isLocationServiceEnabled = true;
  NetworkQuality _networkQuality = NetworkQuality.good;
  StreamSubscription<bool>? _connectivitySub;
  StreamSubscription<NetworkQuality>? _networkQualitySub;
  StreamSubscription<ServiceStatus>? _locationServiceStatusSub;

  LocationService get _locationService => locator<LocationService>();
  NetworkQualityService get _networkQualityService =>
      locator<NetworkQualityService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isOnline = locator<ConnectivityService>().lastStatus;
    _networkQuality = _networkQualityService.lastQuality;
    _connectivitySub = locator<ConnectivityService>().connectionStream.listen((
      bool isOnline,
    ) {
      if (!mounted) return;
      setState(() => _isOnline = isOnline);
      if (isOnline) {
        unawaited(_networkQualityService.checkNow());
      }
    });
    _networkQualitySub = _networkQualityService.qualityStream.listen((
      NetworkQuality quality,
    ) {
      if (mounted) {
        setState(() => _networkQuality = quality);
      }
    });
    _networkQualityService.setForeground(true);
    _syncLocationServiceStatus();
    _locationServiceStatusSub = _locationService
        .getServiceStatusStream()
        .listen((ServiceStatus status) {
          if (!mounted) return;
          setState(
            () => _isLocationServiceEnabled = status == ServiceStatus.enabled,
          );
        });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _networkQualityService.setForeground(false);
    unawaited(_connectivitySub?.cancel());
    unawaited(_networkQualitySub?.cancel());
    unawaited(_locationServiceStatusSub?.cancel());
    _connectivitySub = null;
    _networkQualitySub = null;
    _locationServiceStatusSub = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncLocationServiceStatus();
      _networkQualityService.setForeground(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _networkQualityService.setForeground(false);
    }
  }

  Future<void> _syncLocationServiceStatus() async {
    final isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return;
    setState(() => _isLocationServiceEnabled = isEnabled);
  }

  /// Keep [child] (router + navigators) mounted at all times. Swapping it out
  /// for [NoInternetScreen] disposes the navigator tree and recreates it on
  /// reconnect, which breaks [GlobalKey]s (e.g. root navigator) and triggers
  /// element lifecycle assertions.
  @override
  Widget build(BuildContext context) {
    final rideState = ref.watch(rideSocketProvider);
    final bool hasActiveRide = RideLocationGuard.hasActiveRideFromState(
      rideState,
    );
    final showRideLocationBlocker =
        RideLocationGuard.shouldBlockForDisabledLocation(
          rideState: rideState,
          isLocationServiceEnabled: _isLocationServiceEnabled,
        );
    final bool showSlowConnection =
        _isOnline && _networkQuality == NetworkQuality.degraded;
    final bool showSlowConnectionBlocker = showSlowConnection && !hasActiveRide;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.child,
        if (!_isOnline) const Positioned.fill(child: NoInternetScreen()),
        if (showSlowConnectionBlocker)
          const Positioned.fill(child: SlowConnectionScreen()),
        if (showSlowConnection && hasActiveRide)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlowConnectionBanner(),
          ),
        if (showRideLocationBlocker)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black54,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PopScope(
                    canPop: false,
                    child: CustomDialogue(
                      title: context.l10n.ride_location_required_title,
                      subtitle: context.l10n.ride_location_required_message,
                      icon: Icons.location_off,
                      buttons: [
                        AppButton(
                          text: context.l10n.open_settings,
                          onPressed: () async {
                            await _locationService.openLocationSettings();
                          },
                          backgroundColor: context.appColors.brand,
                          fontColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
