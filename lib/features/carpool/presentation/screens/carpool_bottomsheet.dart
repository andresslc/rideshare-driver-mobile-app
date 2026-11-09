import 'dart:async';

import 'package:driver_app/core/di/service_locator.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/core/location/service_region.dart';
import 'package:driver_app/core/services/location_service.dart';
import 'package:driver_app/core/utils/app_log.dart';
import 'package:driver_app/features/carpool/domain/entities/carpool_entity.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_map_provider.dart';
import 'package:driver_app/features/carpool/presentation/widgets/add_stops_sheet.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_socket_provider.dart';
import 'package:driver_app/features/carpool/presentation/states/carpool_map_state.dart';
import 'package:driver_app/features/carpool/presentation/states/carpool_socket_states.dart';
import 'package:driver_app/features/carpool/presentation/widgets/carpool_request_sheet.dart';
import 'package:driver_app/features/carpool/presentation/widgets/components/carpool_bottomsheet_types.dart';
import 'package:driver_app/features/carpool/presentation/widgets/components/carpool_flow_title.dart';
import 'package:driver_app/features/carpool/presentation/widgets/components/carpool_state_helper.dart';
import 'package:driver_app/features/carpool/presentation/widgets/components/map_styles.dart';
import 'package:driver_app/features/carpool/presentation/widgets/ride_progress_sheet.dart';
import 'package:driver_app/features/carpool/presentation/widgets/ride_start_time_seat_sheet.dart';
import 'package:driver_app/features/carpool/presentation/widgets/search_carpool_ride_sheet.dart';
import 'package:driver_app/features/carpool/presentation/screens/carpool_feedback_screen.dart';
import 'package:driver_app/core/navigation/routes.dart';
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/features/ride_room/presentation/screens/drag_handler.dart';
import 'package:driver_app/shared/screens/success_screen.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:driver_app/shared/widgets/map_zoom_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:driver_app/shared/screens/place_picker_screen.dart';
import 'package:driver_app/shared/provider/map_style_provider.dart';

class RideMapScreen extends ConsumerStatefulWidget {
  final SelectedLocation? pickupLocation;
  final SelectedLocation? dropoffLocation;

  const RideMapScreen({super.key, this.pickupLocation, this.dropoffLocation});

  @override
  ConsumerState<RideMapScreen> createState() => _RideMapScreenState();
}

class _RideMapScreenState extends ConsumerState<RideMapScreen>
    with CarpoolStateHelper {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final LocationService _locationService = locator<LocationService>();

  RideBottomSheetType _currentSheet = RideBottomSheetType.addStops;
  List<SelectedLocation?> _rideStops = [];
  DateTime? _selectedRideStartTime;
  int? _selectedAvailableSeats;
  StreamSubscription<Position>? _locationSubscription;
  bool _isNavigatingAfterCarpoolComplete = false;
  bool _isNavigatingAfterCarpoolCancelled = false;
  GoogleMapController? _mapController;
  late final CarpoolMapProvider _carpoolMapNotifier;
  double _currentZoom = 14;

  static const double _minZoom = 3;
  static const double _maxZoom = 20;
  static const double _zoomStep = 1;

  // Auto-arrive state
  static const double _autoArriveDistanceInMeters = 80;
  String? _autoArriveInFlightStopKey;
  String? _lastAutoArrivedStopKey;

  @override
  void initState() {
    super.initState();
    _carpoolMapNotifier = ref.read(carpoolMapProvider.notifier);
    _rideStops = [widget.pickupLocation, widget.dropoffLocation];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_onStopsUpdated(autoFit: false));
      unawaited(_initializeLocationTracking());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _applyState(ref.read(carpoolSocketProvider));
    });
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

  Future<void> _initializeLocationTracking() async {
    final permission = await _locationService.requestLocationPermission();
    if (permission != LocationPermissionResult.granted) return;

    final pos = await _locationService.getCurrentPosition();
    if (pos != null) {
      _updateLocation(LatLng(pos.latitude, pos.longitude), animate: true);
    }

    _locationSubscription = _locationService.getPositionStream().listen((p) {
      _updateLocation(LatLng(p.latitude, p.longitude), animate: false);
    });
  }

  void _updateLocation(LatLng latLng, {required bool animate}) {
    if (!mounted) return;
    final socketState = ref.read(carpoolSocketProvider);
    final isRideStarted =
        socketState.isRideStarted || socketState.hasActiveRide;
    unawaited(
      _carpoolMapNotifier.updateDriverLocation(
        latLng,
        animateCamera: animate,
        isRideStarted: isRideStarted,
      ),
    );
    unawaited(_maybeAutoArrive(latLng));
  }

  Future<void> _maybeAutoArrive(LatLng currentLoc) async {
    final state = ref.read(carpoolSocketProvider);
    if (!state.hasActiveRide) return;

    final carpoolId = state.activeCarpoolId?.trim() ?? '';
    final candidate = _autoArriveCandidate(
      state: state,
      currentLoc: currentLoc,
    );

    if (carpoolId.isEmpty || candidate == null) return;

    final stop = candidate.stop;
    final stopId = stop.routeStopId?.trim() ?? '';
    final key = '${candidate.index}:$stopId';
    if (_autoArriveInFlightStopKey == key || _lastAutoArrivedStopKey == key) {
      return;
    }

    _autoArriveInFlightStopKey = key;
    final arrived = await ref
        .read(carpoolSocketProvider.notifier)
        .arriveAtStop(routeStopId: stopId, carpoolId: carpoolId);
    if (!mounted) return;

    _autoArriveInFlightStopKey = null;
    if (arrived) {
      _lastAutoArrivedStopKey = key;
      final coords = stop.coordinates;
      await _carpoolMapNotifier.animateDriverAlongRoute(
        LatLng(coords[1], coords[0]),
      );
    }
  }

  _AutoArriveCandidate? _autoArriveCandidate({
    required CarpoolSocketState state,
    required LatLng currentLoc,
  }) {
    _AutoArriveCandidate? bestCandidate;

    for (var index = 0; index < state.stopProgress.length; index++) {
      final stop = state.stopProgress[index];
      final stopId = stop.routeStopId?.trim() ?? '';
      final coords = stop.coordinates;
      if (stopId.isEmpty || coords.length < 2 || stop.isCompleted) {
        continue;
      }

      final distance = Geolocator.distanceBetween(
        currentLoc.latitude,
        currentLoc.longitude,
        coords[1],
        coords[0],
      );
      if (distance > _autoArriveDistanceInMeters) {
        continue;
      }

      final candidate = _AutoArriveCandidate(
        index: index,
        stop: stop,
        distanceInMeters: distance,
      );
      if (bestCandidate == null) {
        bestCandidate = candidate;
        continue;
      }

      final isBetterByOrder = candidate.index < bestCandidate.index;
      final isSameOrderButCloser =
          candidate.index == bestCandidate.index &&
          candidate.distanceInMeters < bestCandidate.distanceInMeters;
      if (isBetterByOrder || isSameOrderButCloser) {
        bestCandidate = candidate;
      }
    }

    return bestCandidate;
  }

  Future<void> _onStopsUpdated({bool autoFit = true}) async {
    final stops = _rideStops.whereType<SelectedLocation>().toList();
    await _carpoolMapNotifier.syncStops(stops, autoFit: autoFit);
  }

  void _applyState(CarpoolSocketState state) {
    final isRideStarted = state.isRideStarted || state.hasActiveRide;
    _carpoolMapNotifier.setRideStarted(isRideStarted);

    if ((widget.pickupLocation != null || widget.dropoffLocation != null) &&
        !hasRecoverableRouteState(state)) {
      return;
    }

    final restoredStops = restoredStopsFromSocketState(state);
    final nextSheet = sheetForCarpoolState(state);
    final restoredStartTime = _restoredStartTimeFromState(state);
    final restoredAvailableSeats = _restoredAvailableSeatsFromState(state);
    final shouldUpdateStartTime =
        restoredStartTime != null &&
        !_sameDateTime(_selectedRideStartTime, restoredStartTime);
    final shouldUpdateAvailableSeats =
        restoredAvailableSeats != null &&
        _selectedAvailableSeats != restoredAvailableSeats;
    final shouldUpdateSheet = _currentSheet != nextSheet;

    log(
      'applyState -> currentSheet=$_currentSheet, nextSheet=$nextSheet, action=${state.action}, status=${state.status}, activeCarpoolId=${state.activeCarpoolId}, incoming=${state.incomingRequests.length}, accepted=${state.acceptedRequests.length}, hasActiveRide=${state.hasActiveRide}, isRideStarted=${state.isRideStarted}, payloadType=${(state.lastRideResume?['type'] ?? state.lastRideResume?['status'] ?? '').toString()}',
      name: 'CarpoolRideMap',
    );

    if (shouldReplaceRideStops(_rideStops, restoredStops)) {
      _rideStops = restoredStops.cast<SelectedLocation?>();
      unawaited(_onStopsUpdated());
    }

    if (mounted &&
        (shouldUpdateSheet ||
            shouldUpdateStartTime ||
            shouldUpdateAvailableSeats)) {
      setState(() {
        _currentSheet = nextSheet;
        if (shouldUpdateStartTime) {
          _selectedRideStartTime = restoredStartTime;
        }
        if (shouldUpdateAvailableSeats) {
          _selectedAvailableSeats = restoredAvailableSeats;
        }
      });
    }
  }

  DateTime? _restoredStartTimeFromState(CarpoolSocketState state) {
    final payload = state.lastRideResume ?? const <String, dynamic>{};
    return _readDateTime(payload['graceTime'] ?? payload['startTime']);
  }

  int? _restoredAvailableSeatsFromState(CarpoolSocketState state) {
    final payload = state.lastRideResume ?? const <String, dynamic>{};
    return _readInt(payload['availableSeats'] ?? payload['maxPassengers']);
  }

  DateTime? _readDateTime(dynamic value) {
    if (value is DateTime) {
      return value.toLocal();
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value.trim());
      return parsed?.toLocal();
    }
    return null;
  }

  int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }

  bool _sameDateTime(DateTime? first, DateTime? second) {
    if (first == null && second == null) {
      return true;
    }
    if (first == null || second == null) {
      return false;
    }
    return first.isAtSameMomentAs(second);
  }

  void _goToNext() {
    final state = ref.read(carpoolSocketProvider);
    if (_shouldLockToRideProgress(state)) {
      _goToSheet(RideBottomSheetType.rideProgress);
      return;
    }

    final idx = RideSheetConstants.flow.indexOf(_currentSheet);
    if (idx < RideSheetConstants.flow.length - 1) {
      setState(() => _currentSheet = RideSheetConstants.flow[idx + 1]);
    }
  }

  void _goToSheet(RideBottomSheetType sheet) {
    if (!mounted) return;
    final state = ref.read(carpoolSocketProvider);
    if (_shouldLockToRideProgress(state) &&
        sheet != RideBottomSheetType.rideProgress) {
      setState(() => _currentSheet = RideBottomSheetType.rideProgress);
      return;
    }
    setState(() => _currentSheet = sheet);
  }

  bool _canExitToDashboard() {
    return _currentSheet == RideBottomSheetType.addStops ||
        _currentSheet == RideBottomSheetType.rideStartTimeAndSeat;
  }

  Future<void> _handleBackNavigation() async {
    final state = ref.read(carpoolSocketProvider);
    if (_shouldLockToRideProgress(state)) {
      return;
    }

    if (_currentSheet == RideBottomSheetType.rideProgress) {
      _goToSheet(RideBottomSheetType.searchCarpoolRide);
      return;
    }

    if (_currentSheet == RideBottomSheetType.carpoolRequest) {
      _goToSheet(RideBottomSheetType.searchCarpoolRide);
      return;
    }

    if (_currentSheet == RideBottomSheetType.searchCarpoolRide &&
        hasRecoverableRouteState(state)) {
      return;
    }

    if (_currentSheet == RideBottomSheetType.searchCarpoolRide) {
      // _goToSheet(RideBottomSheetType.rideStartTimeAndSeat);
      return;
    }

    if (_currentSheet == RideBottomSheetType.rideStartTimeAndSeat) {
      _goToSheet(RideBottomSheetType.addStops);
      return;
    }

    if (_canExitToDashboard()) {
      if (!mounted) return;
      context.pop();
      // context.goNamed(Routes.home.name);
    }
  }

  bool _shouldLockToRideProgress(CarpoolSocketState state) {
    final payload = state.lastRideResume ?? const <String, dynamic>{};
    final status = (payload['type'] ?? payload['status'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    return status == 'in_progress' ||
        status == 'in-progress' ||
        status == 'started' ||
        status == 'active' ||
        state.hasActiveRide ||
        state.isRideStarted;
  }

  List<CarpoolIncomingRequestEntity> _feedbackPassengersForCompletion({
    required CarpoolSocketState? previous,
    required CarpoolSocketState current,
  }) {
    if (previous != null && previous.acceptedRequests.isNotEmpty) {
      return previous.acceptedRequests;
    }
    if (current.acceptedRequests.isNotEmpty) {
      return current.acceptedRequests;
    }
    if (previous != null && previous.incomingRequests.isNotEmpty) {
      return previous.incomingRequests;
    }
    return current.incomingRequests;
  }

  @override
  void dispose() {
    _carpoolMapNotifier.detachController(_mapController);
    _mapController = null;
    _locationSubscription?.cancel();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carpoolMapState = ref.watch(carpoolMapProvider);
    final activeRegion = ServiceRegionConfig.active;
    final CameraTargetBounds cameraTargetBounds = activeRegion.isGlobal
        ? CameraTargetBounds.unbounded
        : CameraTargetBounds(activeRegion.bounds);
    ref.listen<CarpoolSocketState>(carpoolSocketProvider, (prev, next) {
      log(
        'listener -> prevAction=${prev?.action}, nextAction=${next.action}, nextStatus=${next.status}',
        name: 'CarpoolRideMap',
      );
      _applyState(next);
      if (next.status == CarpoolSocketStatus.success) {
        if (next.action == CarpoolSocketAction.rideStart ||
            next.action == CarpoolSocketAction.rideArrive ||
            next.action == CarpoolSocketAction.ridePassengerPick ||
            next.action == CarpoolSocketAction.ridePassengerDrop) {
          unawaited(_onStopsUpdated());
        }

        if (next.action == CarpoolSocketAction.rideCancel) {
          if (_isNavigatingAfterCarpoolCancelled) {
            return;
          }
          _isNavigatingAfterCarpoolCancelled = true;
          final rawMessage = next.message?.trim() ?? '';
          final message = rawMessage.isNotEmpty
              ? rawMessage
              : 'Carpool cancelled.';
          ref.read(carpoolSocketProvider.notifier).clearRecoveredCarpoolState();
          context.showSuccessToast(message);
          context.goNamed(Routes.home.name);
        } else if (next.action == CarpoolSocketAction.rideComplete) {
          if (_isNavigatingAfterCarpoolComplete) {
            return;
          }
          _isNavigatingAfterCarpoolComplete = true;
          final nextCarpoolId = next.activeCarpoolId?.trim() ?? '';
          final feedbackRideId = nextCarpoolId.isNotEmpty
              ? nextCarpoolId
              : (prev?.activeCarpoolId ?? '');
          context.goNamed(
            Routes.success.name,
            extra: SuccessArgs(
              titleOverride: context.l10n.ride_completed,
              messageOverride: context.l10n.your_ride_has_been,
              redirectRouteName: Routes.carpoolFeedback.name,
              redirectArgs: CarpoolFeedbackArgs(
                rideId: feedbackRideId,
                passengers: _feedbackPassengersForCompletion(
                  previous: prev,
                  current: next,
                ),
              ),
            ),
          );
        }
      }
    });

    final mapStyleState = ref.watch(mapStyleProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        unawaited(_handleBackNavigation());
      },
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              style: mapStyleState.maybeWhen(
                data: (styleState) =>
                    context.isDark ? styleState.dark : styleState.light,
                orElse: () => context.isDark ? MapStyles.dark : MapStyles.light,
              ),
              cameraTargetBounds: cameraTargetBounds,
              padding: EdgeInsets.only(
                top: 24,
                bottom: MediaQuery.sizeOf(context).height * 0.34,
              ),
              initialCameraPosition: CameraPosition(
                target: carpoolMapState.cameraTarget,
                zoom: 14,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _carpoolMapNotifier.attachController(controller);
              },
              onCameraMove: (position) {
                _currentZoom = position.zoom;
              },
              markers: carpoolMapState.markers,
              polylines: carpoolMapState.polylines,
              circles: carpoolMapState.circles,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              rotateGesturesEnabled: false,
              zoomControlsEnabled: false,
              zoomGesturesEnabled: true,
              buildingsEnabled: false,
              mapToolbarEnabled: false,
              indoorViewEnabled: false,
            ),
            // Custom zoom controls — positioned above the bottom sheet
            Positioned(
              right: 16,
              bottom: MediaQuery.sizeOf(context).height * 0.46,
              child: MapZoomControls(onZoomIn: _zoomIn, onZoomOut: _zoomOut),
            ),

            CarpoolFlowTitle(
              // title: RideSheetConstants.titles[_currentSheet],
              title: RideSheetConstants.title(_currentSheet, context),

              onBack: _handleBackNavigation,
              showBackButton:
                  _currentSheet != RideBottomSheetType.searchCarpoolRide &&
                  !_shouldLockToRideProgress(ref.read(carpoolSocketProvider)),
            ),

            // CarpoolFloatingButtons(
            //   onPrevious: currentIndex == 0 ? null : _goToPrev,
            //   onNext: currentIndex == RideSheetConstants.flow.length - 1
            //       ? null
            //       : _goToNext,
            //   onReset: () =>
            //       setState(() => _currentSheet = RideBottomSheetType.addStops),
            // ),
            DraggableScrollableSheet(
              // initialChildSize: 0.45,
              minChildSize: 0.4,
              maxChildSize:
                  0.92 - kToolbarHeight / MediaQuery.sizeOf(context).height,
              snap: true,
              controller: _sheetController,
              builder: (context, sc) => ColoredBox(
                color: context.appColors.background,
                child: AppGradientBox(
                  isPlain: true,
                  child: Column(
                    children: [
                      DragHandlerWidget(
                        controller: _sheetController,
                        minChildSize: 0.3,
                        maxChildSize: 0.7,
                      ),
                      Expanded(child: _buildSheet(sc, carpoolMapState)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheet(ScrollController sc, CarpoolMapState carpoolMapState) {
    switch (_currentSheet) {
      case RideBottomSheetType.addStops:
        return AddStopsSheet(
          scrollController: sc,
          initialStops: _rideStops,
          onStopsChanged: (s) {
            _rideStops = s;
            unawaited(_onStopsUpdated());
          },
          onNext: (s) {
            _rideStops = s;
            unawaited(_onStopsUpdated());
            _goToNext();
          },
        );
      case RideBottomSheetType.rideStartTimeAndSeat:
        return RideStartTimeSeatSheet(
          stops: _rideStops,
          avgTime: carpoolMapState.routeAvgTimeMinutes,
          distanceMiles: carpoolMapState.routeDistanceMiles,
          scrollController: sc,
          onSelectionConfirmed: (t, s) => setState(() {
            _selectedRideStartTime = t;
            _selectedAvailableSeats = s;
          }),
          onNext: _goToNext,
        );
      case RideBottomSheetType.searchCarpoolRide:
        return SearchCarpoolRideSheet(
          stops: _rideStops,
          startTime: _selectedRideStartTime,
          availableSeats: _selectedAvailableSeats,
          scrollController: sc,
          onNext: _goToNext,
          onGoToRideProgress: () =>
              _goToSheet(RideBottomSheetType.rideProgress),
        );
      case RideBottomSheetType.carpoolRequest:
        return CarpoolRequestSheet(
          scrollController: sc,
          startTime: _selectedRideStartTime,
          availableSeats: _selectedAvailableSeats,
          onBackToSearch: () =>
              _goToSheet(RideBottomSheetType.searchCarpoolRide),
          onNext: _goToNext,
        );
      case RideBottomSheetType.rideProgress:
        return CarpoolRideProgressSheet(
          scrollController: sc,
          routeStops: _rideStops,
          startTime: _selectedRideStartTime,
          availableSeats: _selectedAvailableSeats,
        );
    }
  }
}

class _AutoArriveCandidate {
  final int index;
  final CarpoolStopProgress stop;
  final double distanceInMeters;

  const _AutoArriveCandidate({
    required this.index,
    required this.stop,
    required this.distanceInMeters,
  });
}
