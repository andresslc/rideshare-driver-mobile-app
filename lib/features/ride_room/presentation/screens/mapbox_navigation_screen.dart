import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:driver_app/core/core.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/custom_tap.dart';

class MapboxNavigationScreen extends ConsumerStatefulWidget {
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final String? destinationName;

  const MapboxNavigationScreen({
    super.key,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    this.destinationName,
  });

  @override
  ConsumerState<MapboxNavigationScreen> createState() => _MapboxNavigationScreenState();
}

class _MapboxNavigationScreenState extends ConsumerState<MapboxNavigationScreen> {
  MapBoxNavigationViewController? _controller;
  bool _routeBuilt = false;
  bool _isExiting = false;
  bool _navigationFinished = false;

  /// Performs a safe, ordered shutdown of the Mapbox navigation session.
  ///
  /// Order matters:
  /// 1. Set `_isExiting` so `_onRouteEvent` ignores any late-arriving events.
  /// 2. Grab and null-out `_controller` so no other code path can use it.
  /// 3. Call `dispose()` on the controller to cancel the EventChannel stream
  ///    subscription — this prevents any further events from reaching Flutter.
  /// 4. Call `finishNavigation()` which stops the trip session on the native side
  ///    and emits NAVIGATION_CANCELLED — but since the stream is already dead,
  ///    it won't re-trigger `_exitScreen`.
  /// 5. Call `clearRoute()` which clears route state on the native side
  ///    and also emits NAVIGATION_CANCELLED — harmless for the same reason.
  Future<void> _finishNavigationSafe() async {
    if (_navigationFinished) return;
    _navigationFinished = true;
    _isExiting = true;

    final controller = _controller;
    _controller = null;

    if (controller == null) return;

    try {
      await controller.shutdownNavigation();
    } catch (_) {}
  }

  @override
  void deactivate() {
    // Runs before the platform view is torn down, so the `shutdownNavigation`
    // method-channel call still has a live channel to travel over. Doing this only in
    // `dispose()` is too late when the route is popped from outside this screen — e.g.
    // the ride being cancelled while the driver is still navigating.
    _finishNavigationSafe();
    super.deactivate();
  }

  @override
  void dispose() {
    _finishNavigationSafe();
    super.dispose();
  }

  Future<void> _exitScreen() async {
    if (_isExiting || !mounted) return;
    await _finishNavigationSafe();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _onRouteEvent(RouteEvent e) async {
    if (!mounted || _isExiting) return;
    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        final progressEvent = e.data as RouteProgressEvent?;
        final durationSeconds = progressEvent?.duration;
        if (durationSeconds != null) {
          final minutes = math.max(1, (durationSeconds / 60).round());
          final etaText = "$minutes min";
          ref.read(rideSocketProvider.notifier).updateEta(etaText);
        }
        break;

      case MapBoxEvent.route_built:
        setState(() {
          _routeBuilt = true;
        });
        if (!mounted || _isExiting) return;
        await _controller?.startNavigation();
        break;

      case MapBoxEvent.route_build_failed:
        setState(() {
          _routeBuilt = false;
        });
        context.showErrorToast(context.l10n.navigation_route_failed);
        _exitScreen();
        break;

      case MapBoxEvent.on_arrival:
        ref.read(rideSocketProvider.notifier).updateEta("1 min");
        context.showSuccessToast(
          context.l10n.navigation_arrived,
          duration: Duration(seconds: 8),
        );
        // _exitScreen();
        break;

      case MapBoxEvent.navigation_cancelled:
      case MapBoxEvent.navigation_finished:
        _exitScreen();
        break;

      default:
        break;
    }
  }

  String _getLocaleLanguage(BuildContext context) {
    try {
      return Localizations.localeOf(context).languageCode;
    } catch (_) {
      return "en";
    }
  }

  @override
  Widget build(BuildContext context) {
    final appMapStyle = context.isDark
        ? "mapbox://styles/mapbox/navigation-night-v1"
        : "mapbox://styles/mapbox/navigation-day-v1";

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Stack(
        children: [
          MapBoxNavigationView(
            options: MapBoxOptions(
              zoom: 18.0,
              simulateRoute: false,
              voiceInstructionsEnabled: true,
              bannerInstructionsEnabled: true,
              allowsUTurnAtWayPoints: true,
              mode: MapBoxNavigationMode.drivingWithTraffic,
              language: _getLocaleLanguage(context),
              units: VoiceUnits.imperial,
              mapStyleUrlDay: appMapStyle,
              mapStyleUrlNight: appMapStyle,
              // isDarkTheme: context.isDark,
              showReportFeedbackButton: false,
              showEndOfRouteFeedback: false,
              longPressDestinationEnabled: false,
              arrivalRadius: 150,
            ),
            onRouteEvent: _onRouteEvent,
            onCreated: (controller) async {
              _controller = controller;
              await controller.initialize();
              if (!mounted || _isExiting) return;

              final origin = WayPoint(
                name: 'Start',
                latitude: widget.originLat,
                longitude: widget.originLng,
              );

              final destination = WayPoint(
                name: widget.destinationName ?? 'Destination',
                latitude: widget.destinationLat,
                longitude: widget.destinationLng,
              );

              await controller.buildRoute(
                wayPoints: [origin, destination],
                options: MapBoxOptions(isDarkTheme: context.isDark),
              );
            },
          ),
          if (!_routeBuilt)
            Container(
              color: context.appColors.background.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.navigation_route_calculating,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // if (!Platform.isIOS && _controller != null && _routeBuilt)
          //   Positioned(
          //     bottom: 10,
          //     right: 12,
          //     child: SafeArea(
          //       child: CustomTap(
          //         onTap: _exitScreen,
          //         child: Container(
          //           padding: const EdgeInsets.all(10),
          //           decoration: BoxDecoration(
          //             color: !context.isDark
          //                 ? AppColors.brand.withValues(alpha: .2)
          //                 : AppColors.darkBorder,
          //             borderRadius: const BorderRadius.all(Radius.circular(12)),
          //           ),
          //           child: Icon(
          //             size: 40,
          //             Icons.close,
          //             color: !context.isDark
          //                 ? const Color(0xff0B2700)
          //                 : const Color(0xffFFFFFF),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
