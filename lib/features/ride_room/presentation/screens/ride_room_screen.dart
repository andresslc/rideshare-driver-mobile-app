import 'dart:async';
import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/location/service_region.dart';
import 'package:driver_app/core/utils/mapbox_navigation_launcher.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_map_provider.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:driver_app/features/ride_room/presentation/screens/pickup_details_sheet.dart';
import 'package:driver_app/features/ride_room/presentation/screens/reached_destination_sheet.dart';
import 'package:driver_app/features/ride_room/presentation/screens/reached_pickup_sheet.dart';
import 'package:driver_app/features/ride_room/presentation/screens/ride_inprogress_sheet.dart';
import 'package:driver_app/features/ride_room/presentation/states/ride_state.dart';
import 'package:driver_app/shared/screens/success_screen.dart';
import 'package:driver_app/shared/widgets/map_zoom_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/navigation/routes.dart';
import '../../../../shared/provider/map_style_provider.dart';
import '../../../carpool/presentation/widgets/components/map_styles.dart';
import '../enums/ride_enum.dart';

// import '../../../../core/extensions/theme_extension.dart';

class RideRoomScreen extends ConsumerStatefulWidget {
  const RideRoomScreen({super.key});

  @override
  ConsumerState<RideRoomScreen> createState() => _RideRoomScreenState();
}

class _RideRoomScreenState extends ConsumerState<RideRoomScreen> {
  bool _isNavigatingAfterRideComplete = false;
  bool _isNavigatingAfterRideCancel = false;
  String? _autoLaunchedForRideId;
  GoogleMapController? _mapController;
  late final RideMapProvider _rideMapNotifier;
  double _currentZoom = 15;

  static const double _minZoom = 3;
  static const double _maxZoom = 20;
  static const double _zoomStep = 1;

  @override
  void initState() {
    super.initState();
    _rideMapNotifier = ref.read(rideMapProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rideMapNotifier.syncWithSocketState(ref.read(rideSocketProvider));
    });
  }

  @override
  void dispose() {
    _rideMapNotifier.detachController(_mapController);
    _mapController = null;
    super.dispose();
  }

  // ---------------- Zoom helpers ----------------

  Future<void> _zoomIn() async {
    final controller = _mapController;
    if (controller == null) return;
    final newZoom = (_currentZoom + _zoomStep).clamp(_minZoom, _maxZoom);
    await controller.animateCamera(CameraUpdate.zoomTo(newZoom));
    _currentZoom = newZoom;
  }

  Future<void> _zoomOut() async {
    final controller = _mapController;
    if (controller == null) return;
    final newZoom = (_currentZoom - _zoomStep).clamp(_minZoom, _maxZoom);
    await controller.animateCamera(CameraUpdate.zoomTo(newZoom));
    _currentZoom = newZoom;
  }

  // -----------------------------------------------

  Widget getSheet(RideSheetsType currentSheet) {
    final Widget sheet;
    switch (currentSheet) {
      case RideSheetsType.pickupDetails:
        sheet = PickupDetailsSheet();
        break;

      case RideSheetsType.reachedPickup:
        sheet = ReachedPickupSheet();
        break;
      case RideSheetsType.rideInProgress:
        sheet = RideInprogressSheet();
        break;
      case RideSheetsType.reachedDestination:
        sheet = ReachedDestinationSheet();
        break;
    }
    return sheet;
  }

  @override
  Widget build(BuildContext context) {
    final mapStyle = ref.watch(mapStyleProvider);
    final rideMapState = ref.watch(rideMapProvider);
    final activeRegion = ServiceRegionConfig.active;

    final CameraTargetBounds cameraTargetBounds = activeRegion.isGlobal
        ? CameraTargetBounds.unbounded
        : CameraTargetBounds(activeRegion.bounds);
    // final CameraTargetBounds cameraTargetBounds = activeRegion.isGlobal
    //     ? CameraTargetBounds.unbounded
    //     : CameraTargetBounds(activeRegion.bounds);
    final l10n = context.l10n;

    // Listen for socket actions in RideRoom
    ref.listen<RideSocketState>(rideSocketProvider, (previous, next) {
      unawaited(ref.read(rideMapProvider.notifier).syncWithSocketState(next));

      // Auto-launch Mapbox once the ride flips to in-progress. Flag is set
      // pre-launch so returning from Mapbox to the ride room does not relaunch;
      // a silent launch failure is intentionally non-retriable for that ride.
      final autoLaunchRide = next.ride;
      final autoLaunchDropoff = autoLaunchRide?.dropOffPointRequested?.location;
      if (next.currentSheet != RideSheetsType.rideInProgress ||
          autoLaunchRide == null) {
        _autoLaunchedForRideId = null;
      } else if (autoLaunchRide.id != _autoLaunchedForRideId &&
          autoLaunchDropoff != null) {
        _autoLaunchedForRideId = autoLaunchRide.id;
        unawaited(
          openMapboxNavigation(
            context,
            ref: ref,
            destinationLat: autoLaunchDropoff.latitude,
            destinationLng: autoLaunchDropoff.longitude,
            destinationName: autoLaunchRide.dropOffPointRequested?.placeName,
          ),
        );
      }

      final String rideStatus = (next.ride?.rideStatus ?? '')
          .trim()
          .toLowerCase();
      final bool isTerminalFromSocket =
          next.action == SocketAction.rideStatusUpdate &&
          (rideStatus == 'completed' || rideStatus == 'cancelled');

      if (next.action == SocketAction.driverArrive ||
          next.action == SocketAction.rideCancel ||
          next.action == SocketAction.rideStart ||
          next.action == SocketAction.rideComplete ||
          isTerminalFromSocket) {
        if (next.status == SocketStatus.loading) {
          // context.showLoader();
        } else {
          // context.hideLoader();

          if (next.status == SocketStatus.success) {
            final bool isCompletedTerminal =
                next.action == SocketAction.rideComplete ||
                (isTerminalFromSocket && rideStatus == 'completed');
            final bool isCancelledTerminal =
                next.action == SocketAction.rideCancel ||
                (isTerminalFromSocket && rideStatus == 'cancelled');

            if (isCompletedTerminal) {
              if (_isNavigatingAfterRideComplete) return;
              _isNavigatingAfterRideComplete = true;
              final completedRide = next.ride;
              ref.read(rideSocketProvider.notifier).clearRideState();
              if (completedRide?.user == null) {
                context.pop();
                return;
              }
              context.goNamed(
                Routes.success.name,
                extra: SuccessArgs(
                  titleOverride: l10n.ride_completed,
                  messageOverride: l10n.your_ride_has_been,
                  redirectRouteName: Routes.feedback.name,
                  redirectArgs: {
                    'rideId': completedRide?.id ?? '',
                    'user': completedRide!.user,
                  },
                ),
              );
              return;
            }

            if (isCancelledTerminal) {
              if (_isNavigatingAfterRideCancel) return;
              _isNavigatingAfterRideCancel = true;
              ref.read(rideSocketProvider.notifier).clearRideState();
              context.goNamed(Routes.home.name);
              return;
            }

            // The OTP was accepted but the ride only turns `in-progress` once
            // the payment settles. With 3-D Secure that takes a while, and
            // without this the screen would sit there saying nothing.
            if (next.action == SocketAction.rideStart &&
                next.message?.trim().isNotEmpty == true) {
              context.showToast(next.message!.trim());
            }
          } else if (next.status == SocketStatus.error) {
            if (next.message != null) context.showWarningToast(next.message!);
          }
        }
      }
    });

    final currentSheet = ref.watch(
      rideSocketProvider.select((s) => s.currentSheet),
    );

    // Prevent the driver from navigating back during an active ride.
    // GoRouter.goNamed() (used by ride-complete / cancel) replaces the entire
    // route stack and is NOT affected by PopScope, so this is safe.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          // context.showWarningToast(l10n.cancel_ride_confirmation);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            mapStyle.when(
              data: (state) {
                if (!rideMapState.showMap) {
                  return Container(
                    color: context.isDark
                        ? const Color(0xFF1A1A2E)
                        : Colors.grey[200],
                  );
                }
                final double mapBottomPadding =
                    MediaQuery.sizeOf(context).height * 0.34;
                return GoogleMap(
                  style: context.isDark
                      ? (state.dark.isNotEmpty ? state.dark : MapStyles.dark)
                      : (state.light.isNotEmpty
                            ? state.light
                            : MapStyles.light),
                  // style: style,
                  cameraTargetBounds: cameraTargetBounds,
                  padding: EdgeInsets.only(top: 24, bottom: mapBottomPadding),
                  initialCameraPosition: CameraPosition(
                    target: rideMapState.cameraTarget,
                    zoom: 15,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    ref
                        .read(rideMapProvider.notifier)
                        .attachController(controller);
                  },
                  onCameraMove: (position) {
                    _currentZoom = position.zoom;
                  },
                  markers: rideMapState.markers,
                  polylines: rideMapState.polylines,
                  circles: rideMapState.circles,
                  myLocationEnabled: false,
                  rotateGesturesEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: true,
                  buildingsEnabled: false,
                  mapToolbarEnabled: false,
                  indoorViewEnabled: false,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l10n.map_load_error(e))),
            ),
            // Custom zoom controls — positioned above the bottom sheet
            Positioned(
              right: 16,
              bottom: MediaQuery.sizeOf(context).height * 0.46,
              child: MapZoomControls(onZoomIn: _zoomIn, onZoomOut: _zoomOut),
            ),
            getSheet(currentSheet),
          ],
        ),
      ),
    );
  }
}
