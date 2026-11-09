import 'dart:async';

import 'package:driver_app/core/constants/socket_events.dart';
import 'package:driver_app/core/di/service_locator.dart';
import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/core/services/sound_service.dart';
import 'package:driver_app/core/services/storage_service.dart';
import 'package:driver_app/core/params/driver_location_params.dart';
import 'package:driver_app/core/services/location_service.dart';
import 'package:driver_app/core/services/notification_service.dart';
import 'package:driver_app/core/services/socket_service.dart';
import 'package:driver_app/core/usecase/usecase.dart';
import 'package:driver_app/core/utils/app_log.dart';
import 'package:driver_app/core/navigation/app_router.dart';
import 'package:driver_app/core/navigation/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:driver_app/features/ride_room/domain/entities/chat_entity.dart';
import 'package:driver_app/features/ride_room/domain/entities/driver_location_entity.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_entities.dart';
import 'package:driver_app/features/ride_room/data/models/ride_models.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_response_entity.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_taken_entity.dart';
import 'package:driver_app/features/ride_room/domain/usecases/ride_socket_usecase.dart';
import 'package:driver_app/features/ride_room/domain/usecases/ride_usecase.dart';
import 'package:driver_app/features/ride_room/data/datasources/ride_socket_listener.dart';
import 'package:driver_app/features/ride_room/presentation/enums/ride_enum.dart';
import 'package:driver_app/features/ride_room/presentation/providers/chat_history_provider.dart';
import 'package:driver_app/features/ride_room/presentation/states/ride_state.dart';
import 'package:driver_app/features/user_profile/presentation/providers/user_profile_provider.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_socket_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../carpool/presentation/states/carpool_socket_states.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../ride_history/data/models/ride_history_model.dart';

final rideSocketProvider = NotifierProvider<RideRoomProvider, RideSocketState>(
  RideRoomProvider.new,
);

class RideRoomProvider extends Notifier<RideSocketState> {
  late RideSocketUseCase _useCase;
  late LocationService _locationService;
  late AvailableRideUseCase _availableRideUseCase;
  late GetRideByIdUseCase _getRideByIdUseCase;
  late SocketService _socketService;
  late StorageService _storage;

  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  StreamSubscription<Map<String, dynamic>>? _notificationPayloadSub;
  StreamSubscription<SocketConnectionStatus>? _connectionStatusSub;
  StreamSubscription<Position>? _locationStreamSub;

  /// Re-announces the driver's position while the car is not moving.
  Timer? _locationHeartbeatTimer;
  static const Duration _locationHeartbeatInterval = Duration(seconds: 30);

  /// Checks that the ride really did start after the OTP was accepted.
  Timer? _startReconciliationTimer;
  static const Duration _startReconciliationDelay = Duration(seconds: 6);
  bool _isSyncingAvailableRides = false;
  bool _isInitializing = false;
  bool _isInitialized = false;
  bool _isReconnecting = false;
  bool _isRoutingToRideRoom = false;
  bool _isRoutingToHome = false;

  /// After a socket drop/reconnect attempt, run [connect] + [_attachListeners] on `connected`.
  bool _needsSocketListenerResync = false;

  String? _currentEta;
  Position? _lastPosition;

  @override
  RideSocketState build() {
    _isSyncingAvailableRides = false;
    _isInitializing = false;
    _isInitialized = false;
    _isReconnecting = false;
    _isRoutingToRideRoom = false;
    _isRoutingToHome = false;
    _needsSocketListenerResync = false;

    _useCase = locator<RideSocketUseCase>();
    _locationService = locator<LocationService>();
    _availableRideUseCase = locator<AvailableRideUseCase>();
    _getRideByIdUseCase = locator<GetRideByIdUseCase>();
    _socketService = locator<SocketService>();
    _storage = locator<StorageService>();

    _listenToNotificationPayloads();
    _syncPendingPickupWaitNotification();
    ref.listen<CarpoolSocketState>(carpoolSocketProvider, (previous, next) {
      final previousId = _normalizeRideId(previous?.activeCarpoolId);
      final nextId = _normalizeRideId(next.activeCarpoolId);

      final bool carpoolIdChanged = nextId != previousId;
      final bool isTerminal =
          next.action == CarpoolSocketAction.rideComplete ||
          next.action == CarpoolSocketAction.rideCancel;

      // If switching carpools or a carpool ended, clear the chat UI state.
      if (carpoolIdChanged || isTerminal) {
        clearChatNotificationsForContextSwitch();
        _clearStoredChatConversation();
      }

      // Restore unread indicators for the new carpool context.
      if (carpoolIdChanged) {
        _restorePersistedChatUnreadForCurrentContext();
      }

      // Automatically sync online status if a carpool is active or resumed while offline.
      final bool shouldSyncOnline =
          (next.action == CarpoolSocketAction.rideResume ||
              next.hasActiveRide) &&
          !state.isOnline;
      if (shouldSyncOnline) {
        // Defer to microtask to ensure we don't update state during a build cycle.
        Future<void>.microtask(() => toggleDriverOnline(true));
      }
    });

    ref.onDispose(() {
      _stopLocationUpdates();
      _startReconciliationTimer?.cancel();
      _startReconciliationTimer = null;
      unawaited(_cancelAllSubscriptions());
      unawaited(_notificationPayloadSub?.cancel());
      _notificationPayloadSub = null;
      if (_isInitialized) {
        unawaited(_useCase.disconnect());
      }
    });

    return const RideSocketState();
  }

  Future<void> toggleDriverOnline(bool value) async {
    // ref.read(dashboardProvider.notifier).getDashboardData();
    await _setDriverOnline(value);
  }

  Future<void> toggleDriverOffline() async {
    await _setDriverOnline(false);
  }

  /// Re-syncs ride state from the server when landing on dashboard or resuming
  /// the app. Uses [force] so routing can run even if the same resume was seen
  /// earlier during socket connect.
  Future<void> requestRideResumeFromServer() async {
    if (!_isInitialized) {
      await initialize();
      if (state.status == SocketStatus.error) return;
    }
    if (!_socketService.isConnected) return;

    await locator<RideSocketListener>().requestResumeFromServer(force: true);
  }

  Future<void> _setDriverOnline(bool value) async {
    if (!_isInitialized) {
      await initialize();
      if (state.status == SocketStatus.error) return;
    }

    state = state.copyWith(
      status: SocketStatus.loading,
      action: SocketAction.driverOnline,
      isOnline: value,
    );

    final result = value
        ? await _useCase.driverOnline(NoParams())
        : await _useCase.driverOffline(NoParams());

    result.fold(
      (failure) {
        if (_isDriverOfflineMessage(failure.message)) {
          _applyDriverOfflineState(
            message: _driverOfflineUiMessage(failure.message),
            action: SocketAction.driverOnline,
            status: SocketStatus.error,
          );
          return;
        }
        state = state.copyWith(
          status: SocketStatus.error,
          message: failure.message,
          isOnline: !value,
        );
      },
      (res) async {
        log(" 11111$res:::::::::::::::::;");
        state = state.copyWith(
          status: SocketStatus.success,
          action: SocketAction.none,
          isOnline: value,
          incomingRides: value ? state.incomingRides : const <RideEntity>[],
          showBadge: value ? state.showBadge : false,
          clearMessage: true,
        );
        if (value) {
          // Await location updates so the server has the driver's coordinates
          // before we fetch available rides.
          await _startLocationUpdates();

          // Small safety delay to allow the backend to process the online status and location
          await Future.delayed(const Duration(milliseconds: 800));
          log("2222$res:::::::::::::::::;");

          _syncAvailableRidesIfOnline(trigger: 'toggle_driver_online');
        } else {
          _stopLocationUpdates();
        }
      },
    );
  }

  Future<void> _startLocationUpdates() async {
    _stopLocationUpdates();
    final permission = await _locationService.requestLocationPermission();
    if (permission != LocationPermissionResult.granted) {
      log(
        '[RideSocketController] Location permission not granted for live updates',
        name: 'RideSocketController',
      );
      return;
    }

    await _sendCurrentLocation();
    _locationStreamSub = _locationService.getPositionStream().listen(
      (position) {
        unawaited(_sendPositionUpdate(position));
      },
      onError: (Object error) {
        log(
          '[RideSocketController] Location stream error: $error',
          name: 'RideSocketController',
        );
      },
    );

    // `driver:location:update` is the only event that puts the driver in the
    // geo index the rings are drawn from, and the position stream goes quiet
    // while the car is parked. This heartbeat keeps a waiting driver findable
    // with a fresh position instead of a stale one.
    _locationHeartbeatTimer = Timer.periodic(
      _locationHeartbeatInterval,
      (_) => unawaited(_sendLocationHeartbeat()),
    );
  }

  void _stopLocationUpdates() {
    _locationStreamSub?.cancel();
    _locationStreamSub = null;
    _locationHeartbeatTimer?.cancel();
    _locationHeartbeatTimer = null;
  }

  Future<void> _sendCurrentLocation() async {
    try {
      if (!state.isOnline || !_socketService.isConnected) return;
      final isAvailable = await _locationService.isLocationAvailable();
      if (!isAvailable) return;

      final position = await _locationService.getCurrentPosition();
      if (position == null) return;

      await _sendPositionUpdate(position);
    } catch (e) {
      log(
        '[RideSocketController] Error sending location update: $e',
        name: 'RideSocketController',
      );
    }
  }

  Future<void> syncCurrentLocation() async {
    await _sendCurrentLocation();
  }

  /// Re-sends the last known position rather than asking the GPS for a new fix,
  /// so keeping the driver findable while parked costs nothing in battery.
  Future<void> _sendLocationHeartbeat() async {
    if (!state.isOnline || !_socketService.isConnected) return;

    final Position? position = _lastPosition;
    if (position == null) {
      await _sendCurrentLocation();
      return;
    }

    await _sendPositionUpdate(position);
  }

  Future<void> _sendPositionUpdate(Position position) async {
    _lastPosition = position;
    if (!state.isOnline || !_socketService.isConnected) return;
    final params = DriverLocationParams(
      longitude: position.longitude,
      latitude: position.latitude,
      eta: _currentEta,
    );
    debugPrint(
      '📡 [RideRoomProvider] _sendPositionUpdate -> [${position.longitude}, ${position.latitude}], eta=$_currentEta',
    );
    await _useCase.driverLocationUpdate(params);
  }

  Future<void> driverLocation(DriverLocationEntity location) async {
    state = state.copyWith(
      status: SocketStatus.loading,
      action: SocketAction.driverLocationUpdate,
    );

    final params = DriverLocationParams(
      longitude: location.longitude,
      latitude: location.latitude,
      eta: _currentEta,
    );

    final result = await _useCase.driverLocationUpdate(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: SocketStatus.error,
          message: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          driverLocation: location,
          status: SocketStatus.success,
        );
      },
    );
  }

  /// Claims a ride with `ride:request:accept`.
  ///
  /// Under ring dispatch every driver in the ring gets the same request and only
  /// one keeps it, so losing the race is the ordinary outcome: it is reported as
  /// a success state with [SocketAction.rideRequestTaken] and a discreet
  /// message, never as a red error.
  Future<void> acceptRideRequest(String rideId, {RideEntity? ride}) async {
    state = state.copyWith(
      status: SocketStatus.loading,
      action: SocketAction.rideRequestAccept,
      acceptingRideId: rideId,
    );

    final result = await _useCase.acceptRideRequest(rideId);

    result.fold(
      (failure) {
        final SocketAckFailure? ackFailure = failure is SocketAckFailure
            ? failure
            : null;

        // Another driver got there first: expected, not an error.
        if (ackFailure != null && ackFailure.isRideTaken) {
          _applyRideTaken(rideId: rideId, message: ackFailure.message);
          return;
        }

        if (ackFailure?.isRideExpired ??
            failure.message.contains('RIDE_EXPIRED')) {
          state = state.copyWith(
            status: SocketStatus.success,
            action: SocketAction.rideRequestExpired,
            clearMessage: true,
            incomingRides: _removeIncomingRideList(state.incomingRides, rideId),
            clearAcceptingRideId: true,
          );
          return;
        }

        // 12 h shift used up: the driver cannot take rides until they rest, so
        // the queue goes with the online status instead of leaving stale cards.
        final String failureCode =
            '${ackFailure?.normalizedCode ?? ''} ${failure.message.toUpperCase()}';
        if (failureCode.contains('SHIFT_EXCEEDED')) {
          state = state.copyWith(
            status: SocketStatus.success,
            action: SocketAction.shiftExceeded,
            message: failure.message,
            isOnline: false,
            incomingRides: const <RideEntity>[],
            showBadge: false,
            clearAcceptingRideId: true,
          );
          _stopLocationUpdates();
          return;
        }

        state = state.copyWith(
          status: SocketStatus.error,
          action: SocketAction.rideRequestAccept,
          message: failure.message,
          clearAcceptingRideId: true,
        );
      },
      (message) {
        log('[RideRoomProvider] ${SocketEvent.rideAccept} success: $message');

        // The driver won the ride. `ride:status:update` follows with the full
        // record; promoting the local one here keeps navigation immediate
        // instead of leaving the driver waiting on the request screen.
        final RideEntity? acceptedRide = _findIncomingRide(rideId) ?? ride;

        state = state.copyWith(
          status: SocketStatus.success,
          action: SocketAction.rideRequestAccept,
          message: message,
          ride: acceptedRide?.copyWith(rideStatus: 'accepted'),
          incomingRides: _removeIncomingRideList(state.incomingRides, rideId),
          clearAcceptingRideId: true,
        );
      },
    );
  }

  RideEntity? _findIncomingRide(String rideId) {
    final String? normalized = _normalizeRideId(rideId);
    if (normalized == null) return null;
    for (final RideEntity ride in state.incomingRides) {
      if (_normalizeRideId(ride.id) == normalized) return ride;
    }
    return null;
  }

  /// Drops the card for [rideId] and repaints the queue. [availableRides] is the
  /// fresh list carried by `ride:request:taken`; when it is null the local list
  /// is only pruned.
  ///
  /// [message] is the already translated text from the accept ack. When it is
  /// null the screen falls back to its own discreet wording.
  void _applyRideTaken({
    required String rideId,
    String? message,
    List<RideEntity>? availableRides,
  }) {
    final String? normalizedRideId = _normalizeRideId(rideId);
    final bool wasOnScreen = state.incomingRides.any(
      (ride) => _normalizeRideId(ride.id) == normalizedRideId,
    );
    final bool wasAccepting =
        _normalizeRideId(state.acceptingRideId) == normalizedRideId;

    final List<RideEntity> nextRides = availableRides != null
        ? _sortIncomingRides(availableRides)
        : _removeIncomingRideList(state.incomingRides, rideId);

    // Stay quiet about a ride the driver never had in front of them.
    final bool shouldNotify = wasOnScreen || wasAccepting;

    state = state.copyWith(
      status: SocketStatus.success,
      action: shouldNotify ? SocketAction.rideRequestTaken : state.action,
      message: message,
      clearMessage: message == null,
      incomingRides: nextRides,
      lastSyncAt: availableRides != null ? DateTime.now() : state.lastSyncAt,
      clearAcceptingRideId: wasAccepting,
    );
  }

  Future<void> availableRides({bool silent = false}) async {
    if (!state.isOnline) {
      if (silent) {
        return;
      }
      _applyDriverOfflineState(
        message:
            'You are offline right now. Please go online again to view ride requests.',
        action: SocketAction.availableRides,
        status: SocketStatus.error,
      );
      return;
    }

    if (_isSyncingAvailableRides) {
      return;
    }

    _isSyncingAvailableRides = true;

    if (!silent) {
      state = state.copyWith(
        status: SocketStatus.loading,
        action: SocketAction.availableRides,
      );
    }

    try {
      final result = await _availableRideUseCase();

      result.fold(
        (failure) {
          if (_isDriverOfflineMessage(failure.message)) {
            _applyDriverOfflineState(
              message: _driverOfflineUiMessage(failure.message),
              action: SocketAction.availableRides,
              status: SocketStatus.error,
            );
            return;
          }

          if (silent) {
            log(
              '[RideSocketController] Silent ride queue sync failed: ${failure.message}',
              name: 'RideSocketController',
            );
            return;
          }

          state = state.copyWith(
            status: SocketStatus.error,
            message: failure.message,
          );
        },
        (message) {
          final List<RideEntity> syncedRides = _sortIncomingRides(
            message.rides,
          );
          if (silent) {
            state = state.copyWith(
              incomingRides: syncedRides,
              lastSyncAt: DateTime.now(),
            );
            return;
          }

          state = state.copyWith(
            status: SocketStatus.success,
            action: SocketAction.availableRides,
            incomingRides: syncedRides,
            lastSyncAt: DateTime.now(),
          );
        },
      );
    } finally {
      _isSyncingAvailableRides = false;
    }
  }

  Future<void> driverArriveAction(
    String rideId, {
    required double lat,
    required double lng,
  }) async {
    state = state.copyWith(
      status: SocketStatus.loading,
      action: SocketAction.driverArrive,
    );

    final result = await _useCase.driverArrive(rideId, lat: lat, lng: lng);
    result.fold(
      (failure) {
        // Marking the arrival stopped being a requirement to start: if the GPS
        // never puts the driver inside the 100 m radius, the backend registers
        // the arrival itself on `ride:start`. So the sheet still moves forward
        // to the OTP — otherwise a driver who is physically there but whose
        // location drifted could never start the ride. The error is still
        // surfaced so they know the arrival was not recorded.
        state = state.copyWith(
          status: SocketStatus.error,
          action: SocketAction.driverArrive,
          message: failure.message,
          currentSheet: RideSheetsType.reachedPickup,
        );
        unawaited(_startPickupWaitForCurrentRide(rideId: rideId));
      },
      (_) {
        _currentEta = null;
        state = state.copyWith(
          status: SocketStatus.success,
          action: SocketAction.driverArrive,
          message: 'Driver marked as arrived',
          currentSheet: RideSheetsType.reachedPickup,
        );
        unawaited(_startPickupWaitForCurrentRide(rideId: rideId));
      },
    );
  }

  Future<void> rideStartAction({String? rideId, int? otp}) async {
    rideId ??= _resolveCurrentRideId();
    if (rideId == null) {
      state = state.copyWith(
        status: SocketStatus.error,
        action: SocketAction.rideStart,
        message: 'Unable to start ride. Missing ride ID.',
      );
      return;
    }

    state = state.copyWith(
      status: SocketStatus.loading,
      action: SocketAction.rideStart,
    );

    final result = await _useCase.rideStart(rideId, otp: otp);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: SocketStatus.error,
          message: failure.message,
        );
      },
      (message) {
        _currentEta = null;

        // The ack only means the OTP was accepted. The ride becomes
        // `in-progress` when the payment settles — same instant for wallet,
        // free rides and cards without 3-D Secure, but later when Stripe asks
        // for verification (`RIDE_STARTED_PAYMENT_PENDING`). Advancing the
        // sheet here would offer "finish ride" on a ride the backend has not
        // started yet, and `ride:complete` would come back as
        // INVALID_RIDE_STATUS_TRANSITION. So the sheet waits for
        // `ride:status:update` with `type: "in-progress"`.
        state = state.copyWith(
          status: SocketStatus.success,
          action: SocketAction.rideStart,
          message: message,
        );
        clearPickupWait();
        _scheduleStartReconciliation();
      },
    );
  }

  /// Safety net for the start: if `ride:status:update` with `in-progress`
  /// never lands — a socket blip, or a 3-D Secure verification that finished
  /// while the app was in the background — the real status is pulled from the
  /// server so the driver is not left on the OTP sheet with a started ride.
  void _scheduleStartReconciliation() {
    _startReconciliationTimer?.cancel();
    _startReconciliationTimer = Timer(_startReconciliationDelay, () {
      if (isRideInProgress) return;
      log(
        '[RideRoomProvider] No in-progress event after start; resyncing',
        name: 'RideSocketController',
      );
      unawaited(requestRideResumeFromServer());
    });
  }

  /// True when the backend refused the change of status. It arrives as the raw
  /// i18n key while the server has no translation for it, so both spellings
  /// are matched.
  bool _isInvalidStatusTransition(String? message) {
    final String normalized = (message ?? '').trim().toUpperCase();
    if (normalized.isEmpty) return false;
    return normalized.contains('INVALID_RIDE_STATUS_TRANSITION') ||
        normalized.contains('INVALID RIDE STATUS TRANSITION');
  }

  /// A ride can only be completed while it is in progress.
  bool get isRideInProgress =>
      (state.ride?.rideStatus ?? '').trim().toLowerCase() == 'in-progress';

  Future<void> rideCompleteAction() async {
    final String? rideId = _resolveCurrentRideId();
    if (rideId == null) {
      state = state.copyWith(
        status: SocketStatus.error,
        action: SocketAction.rideComplete,
        message: 'Unable to complete ride. Missing ride ID.',
      );
      return;
    }

    state = state.copyWith(
      status: SocketStatus.loading,
      action: SocketAction.rideComplete,
    );

    final result = await _useCase.rideComplete(rideId);
    result.fold(
      (failure) {
        // Only a ride in progress can be completed. If the backend and the app
        // disagree on the status, re-read the real one instead of leaving the
        // driver stuck on a screen whose button always fails.
        if (_isInvalidStatusTransition(failure.message)) {
          log(
            '[RideRoomProvider] complete rejected as an invalid transition; '
            'resyncing from the server',
            name: 'RideSocketController',
          );
          unawaited(requestRideResumeFromServer());
          state = state.copyWith(
            status: SocketStatus.error,
            action: SocketAction.rideComplete,
            clearMessage: true,
          );
          return;
        }

        state = state.copyWith(
          status: SocketStatus.error,
          message: failure.message,
        );
      },
      (message) {
        locator<SoundService>().playRideCompletedSound();
        state = state.copyWith(
          status: SocketStatus.success,
          action: SocketAction.rideComplete,
          message: message,

          currentSheet: RideSheetsType.reachedDestination,
        );
        clearPickupWait();
        ref.read(dashboardProvider.notifier).incrementCompletedRides();
        _clearStoredChatConversation();
      },
    );
  }

  Future<void> rideCancelAction({
    String? rideId,
    required String cancellationReason,
  }) async {
    rideId ??= _resolveCurrentRideId();
    if (rideId == null) {
      state = state.copyWith(
        status: SocketStatus.error,
        action: SocketAction.rideCancel,
        message: 'Unable to cancel ride. Missing ride ID.',
      );
      return;
    }

    state = state.copyWith(
      status: SocketStatus.loading,
      action: SocketAction.rideCancel,
    );

    final result = await _useCase.rideCancel(
      rideId,
      cancellationReason: cancellationReason,
    );
    result.fold(
      (failure) {
        state = state.copyWith(
          status: SocketStatus.error,
          message: failure.message,
        );
      },
      (message) {
        locator<SoundService>().playRideCancelledSound();
        state = state.copyWith(
          status: SocketStatus.success,
          action: SocketAction.rideCancel,
          message: message,
        );
        clearPickupWait();

        ref.read(dashboardProvider.notifier).getDashboardData();
        _clearStoredChatConversation();
      },
    );
  }

  Future<void> initialize() async {
    if (_isInitializing) return;
    if (_isInitialized && _socketService.isConnected) {
      _listenToConnectionStatus();
      final result = await _useCase.connect();
      result.fold(
        (failure) {
          state = state.copyWith(
            status: SocketStatus.error,
            message: failure.message,
          );
        },
        (_) {
          _attachListeners();
          state = state.copyWith(
            status: SocketStatus.success,
            action: SocketAction.initialize,
          );
        },
      );
      return;
    }

    _isInitializing = true;
    _attachListeners();
    _listenToConnectionStatus();
    state = state.copyWith(
      status: SocketStatus.loading,
      action: SocketAction.initialize,
    );

    final result = await _useCase.connect();
    result.fold(
      (failure) {
        state = state.copyWith(
          status: SocketStatus.error,
          message: failure.message,
        );
      },
      (_) {
        _isInitialized = true;
        state = state.copyWith(
          status: SocketStatus.success,
          action: SocketAction.initialize,
        );
      },
    );
    _isInitializing = false;
  }

  Future<void> stop() async {
    await _cancelAllSubscriptions();
    _stopLocationUpdates();
    _startReconciliationTimer?.cancel();
    _startReconciliationTimer = null;
    _isInitialized = false;
    _isReconnecting = false;

    final result = await _useCase.disconnect();
    result.fold(
      (failure) {
        state = state.copyWith(
          status: SocketStatus.error,
          message: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          status: SocketStatus.initial,
          action: SocketAction.none,
          isOnline: false,
          incomingRides: const <RideEntity>[],
          showBadge: false,
        );
        clearPickupWait();
      },
    );
  }

  void _attachListeners() {
    for (final sub in _subscriptions) {
      unawaited(sub.cancel());
    }
    _subscriptions.clear();

    _listenToIncomingRides();
    _listenToRideTaken();
    _listenToRideResume();
    _listenToRideStatus();
    _listenToDriverOnline();
    _listenToDriverLocation();
    _listenToSocketErrors();
    _listenToChatMessages();
    _listenToShiftExceeded();
  }

  void _listenToNotificationPayloads() {
    _notificationPayloadSub?.cancel();
    final service = locator<NotificationServices>();
    _notificationPayloadSub = service.notificationPayloadStream.listen((
      payload,
    ) {
      _handlePickupWaitNotification(payload);
    });
  }

  void _syncPendingPickupWaitNotification() {
    final payload = locator<NotificationServices>().pendingNotificationData;
    if (payload != null) {
      _handlePickupWaitNotification(payload);
    }
  }

  void _handlePickupWaitNotification(Map<String, dynamic> payload) {
    final String status = (payload['status'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final String rideId = (payload['rideId'] ?? '').toString().trim();
    if (status != 'coming' || rideId.isEmpty) {
      return;
    }

    final String? currentRideId = _normalizeRideId(state.ride?.id);
    if (currentRideId != null && currentRideId != rideId) {
      return;
    }

    clearPickupWait();
  }

  void removeRide(String rideId) {
    final updated = _removeIncomingRideList(state.incomingRides, rideId);
    state = state.copyWith(incomingRides: updated);
  }

  void _listenToChatMessages() {
    _subscriptions.add(
      _useCase.chatStream().listen(
        (either) => either.fold(
          (failure) {
            state = state.copyWith(
              status: SocketStatus.error,
              message: failure.message,
            );
          },
          (ChatMessageEntity chatMessage) {
            final updatedList = [...state.chatMessages, chatMessage];
            final carpoolSock = ref.read(carpoolSocketProvider);
            final bool carpoolLive = carpoolSock.hasActiveRide;
            final String? carpoolRouteId = carpoolSock.activeCarpoolId;
            final bool carpoolSocketHint =
                carpoolLive || (carpoolRouteId?.trim().isNotEmpty ?? false);
            final bool rideSaysCarpool = (state.ride?.rideType ?? '')
                .toLowerCase()
                .contains('carpool');
            final bool isCarpoolMode = carpoolSocketHint || rideSaysCarpool;

            final Set<String> myDriverCanonIds = <String>{
              _canonUserId(ref.read(userProfileProvider).profile?.user.id),
              _canonUserId(state.ride?.driver?.id),
              _canonUserId(state.ride?.driverId),
            }..removeWhere((String e) => e.isEmpty);
            final Set<String> senderIds = chatMessageSenderCanonIds(
              chatMessage,
            );
            final bool fromDriver =
                myDriverCanonIds.isNotEmpty &&
                senderIds.isNotEmpty &&
                senderIds.any(myDriverCanonIds.contains);

            if (isCarpoolMode) {
              final Set<String> nextUnread = {
                ...state.carpoolUnreadPassengerUserIds,
              };
              if (!fromDriver && senderIds.isNotEmpty) {
                final String viewing =
                    (state.activeCarpoolChatPassengerUserId ?? '')
                        .trim()
                        .toLowerCase();
                final bool viewingThis =
                    viewing.isNotEmpty && senderIds.contains(viewing);
                if (viewingThis) {
                  for (final String v in senderIds) {
                    nextUnread.remove(v);
                  }
                } else {
                  nextUnread.addAll(senderIds);
                }
              }

              state = state.copyWith(
                chatMessages: updatedList,
                carpoolUnreadPassengerUserIds: nextUnread,
                action: SocketAction.chatReceived,
                status: SocketStatus.success,
              );
              _persistCarpoolUnreadState(nextUnread);
              return;
            }

            // Normal ride: red dot stays latched while chat is closed; do not
            // clear [showBadge] on every socket row (e.g. passenger while chat open
            // zeroed it, then closing chat left dot stuck off).
            final bool passengerInbound = !fromDriver;
            final bool nextShowBadge = state.isChatOpen
                ? false
                : (state.showBadge || passengerInbound);
            state = state.copyWith(
              chatMessages: updatedList,
              lastChatMessage: chatMessage,
              action: SocketAction.chatReceived,
              status: SocketStatus.success,
              showBadge: nextShowBadge,
            );
            _persistNormalRideUnreadState(
              hasUnread: nextShowBadge,
              rideId:
                  _normalizeRideId(chatMessage.contextId) ??
                  _resolveCurrentRideId(),
            );
          },
        ),
      ),
    );
  }

  bool _isNormalRide() {
    final bool rideSaysCarpool = (state.ride?.rideType ?? '')
        .toLowerCase()
        .contains('carpool');
    final bool carpoolLive = ref.read(carpoolSocketProvider).hasActiveRide;
    if (rideSaysCarpool || carpoolLive) return false;
    return true;
  }

  void _triggerRideSoundEffect(String? newStatus) {
    if (newStatus == null || newStatus.isEmpty) return;

    final soundService = locator<SoundService>();
    final normalized = newStatus.trim().toLowerCase();

    switch (normalized) {
      case 'accepted':
        soundService.playRideAcceptedSound();
        break;
      case 'arrived':
        soundService.playDriverArrivedSound();
        break;
      case 'in-progress':
      case 'started':
        soundService.playRideStartedSound();
        break;
      case 'completed':
      case 'dropped':
        soundService.playRideCompletedSound();
        break;
      case 'cancelled':
      case 'canceled':
        soundService.playRideCancelledSound();
        break;
      default:
        break;
    }
  }

  String _canonUserId(String? id) => (id ?? '').trim().toLowerCase();

  String? _activeCarpoolId() {
    final String? raw = ref.read(carpoolSocketProvider).activeCarpoolId;
    return _normalizeRideId(raw);
  }

  void _persistNormalRideUnreadState({
    required bool hasUnread,
    String? rideId,
  }) {
    final String? normalizedRideId = _normalizeRideId(rideId ?? state.ride?.id);
    if (normalizedRideId == null) {
      return;
    }
    unawaited(
      _storage.saveRideChatUnreadState(
        rideId: normalizedRideId,
        hasUnread: hasUnread,
      ),
    );
  }

  void _persistCarpoolUnreadState(Set<String> unreadPassengerUserIds) {
    final String? carpoolId = _activeCarpoolId();
    if (carpoolId == null) {
      return;
    }
    unawaited(
      _storage.saveCarpoolChatUnreadState(
        carpoolId: carpoolId,
        unreadPassengerUserIds: unreadPassengerUserIds,
      ),
    );
  }

  void _clearPersistedUnreadState() {
    unawaited(_storage.clearRideChatUnreadState());
    unawaited(_storage.clearCarpoolChatUnreadState());
  }

  void _restorePersistedChatUnreadForCurrentContext() {
    bool changed = false;
    bool nextShowBadge = state.showBadge;
    Set<String> nextCarpoolUnread = state.carpoolUnreadPassengerUserIds;

    final String? currentRideId = _resolveCurrentRideId();
    final RideChatUnreadPersisted? persistedRide = _storage
        .getRideChatUnreadState();
    if (currentRideId != null &&
        persistedRide != null &&
        persistedRide.rideId == currentRideId &&
        persistedRide.hasUnread &&
        !state.isChatOpen &&
        !state.showBadge) {
      nextShowBadge = true;
      changed = true;
    }

    final String? currentCarpoolId = _activeCarpoolId();
    final CarpoolChatUnreadPersisted? persistedCarpool = _storage
        .getCarpoolChatUnreadState();
    if (currentCarpoolId != null &&
        persistedCarpool != null &&
        persistedCarpool.carpoolId == currentCarpoolId &&
        persistedCarpool.unreadPassengerUserIds.isNotEmpty) {
      final merged = <String>{
        ...state.carpoolUnreadPassengerUserIds,
        ...persistedCarpool.unreadPassengerUserIds,
      };
      if (merged.length != state.carpoolUnreadPassengerUserIds.length) {
        nextCarpoolUnread = merged;
        changed = true;
      }
    }

    if (!changed) {
      return;
    }

    state = state.copyWith(
      showBadge: nextShowBadge,
      carpoolUnreadPassengerUserIds: nextCarpoolUnread,
    );
  }

  void setActiveCarpoolChatPassengerUserId(String? passengerUserId) {
    if (passengerUserId == null) {
      state = state.copyWith(clearActiveCarpoolChatPassengerUserId: true);
    } else {
      final String n = passengerUserId.trim().toLowerCase();
      state = state.copyWith(
        activeCarpoolChatPassengerUserId: n.isEmpty ? null : n,
      );
    }
  }

  void clearCarpoolChatBadgeForPassengerUser(String passengerUserId) {
    clearCarpoolChatBadgesForCanonKeys(<String>[passengerUserId]);
  }

  /// Clears unread dots for any of these user id strings (e.g. `_id` + signUpRecord).
  void clearCarpoolChatBadgesForCanonKeys(Iterable<String> rawIds) {
    final Set<String> next = {...state.carpoolUnreadPassengerUserIds};
    bool changed = false;
    for (final String raw in rawIds) {
      final String p = raw.trim().toLowerCase();
      if (p.isEmpty) continue;
      if (next.remove(p)) {
        changed = true;
      }
    }
    if (changed) {
      state = state.copyWith(carpoolUnreadPassengerUserIds: next);
      _persistCarpoolUnreadState(next);
    }
  }

  void clearChatBadge() {
    state = state.copyWith(showBadge: false);
    _persistNormalRideUnreadState(hasUnread: false);
  }

  /// Clears badge, last chat message, and socket chat list (e.g. new carpool ride).
  void clearChatNotificationsForContextSwitch() {
    state = state.copyWith(clearChatNotification: true);
  }

  void setChatOpen() {
    state = state.copyWith(isChatOpen: true);
  }

  void setChatClose() {
    state = state.copyWith(
      isChatOpen: false,
      // PopScope / router pops may not run ChatScreen.dispose reliably; always
      // drop carpool "viewing" so passenger-list red dots work after returning.
      clearActiveCarpoolChatPassengerUserId: true,
    );
  }

  void clearPickupWait() {
    state = state.copyWith(clearPickupWait: true);
    unawaited(_storage.clearPickupWaitWindow());
  }

  /// Restores countdown from disk after cold start if the sheet/ride match.
  void _tryRestorePickupWaitFromStorage() {
    if (state.pickupWaitStartedAt != null) return;
    final rideId = _normalizeRideId(state.ride?.id);
    if (rideId == null) return;
    if (state.currentSheet != RideSheetsType.reachedPickup) return;

    final persisted = _storage.getPickupWaitWindow();
    if (persisted == null || persisted.rideId != rideId) return;

    final startedAt = persisted.endsAt.subtract(persisted.duration);
    state = state.copyWith(
      pickupWaitRideId: rideId,
      pickupWaitStartedAt: startedAt,
      pickupWaitDuration: persisted.duration,
    );
  }

  Future<void> _startPickupWaitForCurrentRide({String? rideId}) async {
    final normalizedRideId = _normalizeRideId(rideId ?? state.ride?.id);
    if (normalizedRideId == null) return;
    if (state.currentSheet != RideSheetsType.reachedPickup) return;

    final persisted = _storage.getPickupWaitWindow();
    if (persisted != null && persisted.rideId == normalizedRideId) {
      final startedAt = persisted.endsAt.subtract(persisted.duration);
      state = state.copyWith(
        pickupWaitRideId: normalizedRideId,
        pickupWaitStartedAt: startedAt,
        pickupWaitDuration: persisted.duration,
      );
      return;
    }

    const duration = Duration(minutes: 5);
    final now = DateTime.now();
    final endsAt = now.add(duration);
    state = state.copyWith(
      pickupWaitRideId: normalizedRideId,
      pickupWaitStartedAt: now,
      pickupWaitDuration: duration,
    );
    await _storage.savePickupWaitWindow(
      rideId: normalizedRideId,
      endsAt: endsAt,
      duration: duration,
    );
  }

  void _listenToIncomingRides() {
    _subscriptions.add(
      _useCase.incomingRidesUpdate().listen(
        (either) => either.fold(
          (failure) {
            state = state.copyWith(
              status: SocketStatus.error,
              message: failure.message,
            );
          },
          (ride) {
            if (!state.isOnline) {
              return;
            }

            // Ring dispatch sends a trimmed payload without `createdAt`. Stamp
            // the arrival time so the request still sorts to the top of the
            // queue instead of falling to the bottom as an undated card.
            final RideEntity queued = ride.createdAt == null
                ? ride.copyWith(createdAt: DateTime.now())
                : ride;

            final List<RideEntity> updated = _upsertIncomingRide(
              state.incomingRides,
              queued,
            );

            // Note: the active `ride` is deliberately left untouched. A request
            // in the queue is not this driver's ride until the accept is
            // acknowledged — under ring dispatch the same request sits on
            // several drivers' screens at once.
            state = state.copyWith(
              status: SocketStatus.success,
              action: SocketAction.rideIncoming,
              incomingRides: updated,
            );
            locator<SoundService>().playRequestReceivedSound();
          },
        ),
      ),
    );
  }

  /// `ride:request:taken`: another driver won this request. Pulls the card and
  /// repaints the queue from the list the event carries — no HTTP round trip.
  void _listenToRideTaken() {
    _subscriptions.add(
      _useCase.rideTakenUpdate().listen(
        (either) => either.fold(
          (failure) {
            log(
              '[RideRoomProvider] ride:request:taken error: ${failure.message}',
              name: 'RideSocketController',
            );
          },
          (RideTakenEntity event) {
            log(
              '[RideRoomProvider] ride taken rideId=${event.rideId} '
              'reason=${event.normalizedReason} '
              'availableRides=${event.availableRides?.length}',
              name: 'RideSocketController',
            );

            // No message: the event only carries a code, so the screen supplies
            // the localized wording.
            _applyRideTaken(
              rideId: event.rideId,
              availableRides: event.availableRides,
            );
          },
        ),
      ),
    );
  }

  void _listenToDriverOnline() {
    _subscriptions.add(
      _useCase.driverOnlineUpdateStream().listen(
        (either) => either.fold(
          (failure) {
            state = state.copyWith(
              status: SocketStatus.error,
              message: failure.message,
            );
          },
          (message) {
            state = state.copyWith(
              status: SocketStatus.success,
              action: SocketAction.none,
              message: message,
            );
            _syncAvailableRidesIfOnline(trigger: 'driver_online_event');
          },
        ),
      ),
    );
  }

  void _listenToDriverLocation() {
    // _subscriptions.add(
    //   _useCase.driverLocationUpdateStream().listen(
    //     (either) => either.fold(
    //       (failure) {
    //         state = state.copyWith(
    //           status: SocketStatus.error,
    //           message: failure.message,
    //         );
    //       },
    //       (location) {
    //         state = state.copyWith(
    //           status: SocketStatus.success,
    //           action: SocketAction.driverLocationUpdate,
    //           // driverLocation: location,
    //         );
    //       },
    //     ),
    //   ),
    // );
  }

  void _listenToRideResume() {
    _subscriptions.add(
      _useCase.rideResumeUpdate().listen(
        (either) => either.fold(
          (failure) {
            state = state.copyWith(
              status: SocketStatus.error,
              message: failure.message,
            );
          },
          (RideResponseEntity event) async {
            if (event.type == null) {
              return;
            }
            final String normalizedType = (event.type ?? '')
                .trim()
                .toLowerCase();
            if (normalizedType == 'cancelled' || normalizedType == 'canceled') {
              _handleRideCancelled(event);
              return;
            }
            if (normalizedType == 'completed' ||
                normalizedType == 'dropped' ||
                normalizedType == 'expired') {
              return;
            }

            // Driver offers were retired. `offers_pending` can only come from
            // stale offers left in the database, so it is ignored.
            if (normalizedType == 'offers_pending') {
              log(
                '[RideRoomProvider] Ignoring legacy ride:resume offers_pending',
                name: 'RideSocketController',
              );
              return;
            }
            final RideSheetsType nextSheet = normalizedType == 'coming'
                ? RideSheetsType.reachedPickup
                : _sheetForResponse(normalizedType);
            state = state.copyWith(
              status: SocketStatus.success,
              action: SocketAction.rideResume,
              // ride: ride,
              message: event.message ?? state.message,
              currentSheet: nextSheet,
              otp: event.rideOtp,
            );
            _restorePersistedChatUnreadForCurrentContext();
            if (normalizedType == 'coming') {
              clearPickupWait();
            } else if (nextSheet == RideSheetsType.reachedPickup) {
              unawaited(_startPickupWaitForCurrentRide(rideId: event.rideId));
            } else {
              clearPickupWait();
            }
            unawaited(
              hydrateActiveRideDetailsIfNeeded(preferredRideId: event.rideId),
            );
            await (_syncOnlineForResumeAndRoute(type: normalizedType));
          },
        ),
      ),
    );
  }

  void _listenToRideStatus() {
    _subscriptions.add(
      _useCase.rideStatusUpdate().listen(
        (either) => either.fold(
          (failure) {
            state = state.copyWith(
              status: SocketStatus.error,
              message: failure.message,
            );
          },
          (RideResponseEntity event) {
            final bool targetsCurrentRide = _eventTargetsCurrentRide(event);
            final bool updatedIncomingQueue =
                _reconcileIncomingRidesForStatusEvent(event);
            final String terminalType = _terminalStatusForEvent(
              ride: event.ride,
              type: event.type,
            );
            if (terminalType == 'cancelled') {
              _handleRideCancelled(event);
              return;
            }

            // A request nobody took closes itself once the ring ladder runs
            // out. It only has to leave the queue, which the reconcile above
            // already did.
            if (terminalType == 'expired') {
              state = state.copyWith(
                status: SocketStatus.success,
                action: SocketAction.rideRequestExpired,
                clearRide: targetsCurrentRide,
                clearMessage: true,
                incomingRides: _removeIncomingRideList(
                  state.incomingRides,
                  event.rideId ?? event.ride?.id ?? '',
                ),
              );
              return;
            }

            if (!targetsCurrentRide && updatedIncomingQueue) {
              final String normalizedStatus = _normalizedIncomingRideStatus(
                event,
              );
              state = state.copyWith(
                status: SocketStatus.success,
                action: SocketAction.rideStatusUpdate,
                message: event.message ?? state.message,
              );

              // A queued ride turning 'accepted' only means the ride room is
              // this driver's when they are the one who won it. Under ring
              // dispatch the same request is accepted on other drivers'
              // screens too, and those must stay where they are.
              if (normalizedStatus == 'accepted' && _isRideMine(event)) {
                unawaited(_syncOnlineForResumeAndRoute(type: normalizedStatus));
              }
              return;
            }
            final String? previousRideId = _normalizeRideId(state.ride?.id);
            // The status event now carries the ride fully populated, so it wins
            // over the local copy field by field, and what it omits is kept.
            final RideEntity? ride = _mergeRide(state.ride, event.ride, event);
            final String normalizedType = (event.type ?? '')
                .trim()
                .toLowerCase();
            final RideSheetsType nextSheet = normalizedType == 'coming'
                ? RideSheetsType.reachedPickup
                : _sheetForResponse(terminalType);
            final String? nextRideId = _normalizeRideId(ride?.id);
            final bool newRideContext =
                previousRideId != nextRideId &&
                (previousRideId != null || nextRideId != null);
            state = state.copyWith(
              status: SocketStatus.success,
              action: SocketAction.rideStatusUpdate,
              ride: ride,
              message: event.message ?? state.message,
              currentSheet: nextSheet,
              otp: event.rideOtp,
              clearChatNotification: newRideContext,
            );
            if (newRideContext && previousRideId != null) {
              _clearStoredChatConversation();
            }
            _restorePersistedChatUnreadForCurrentContext();
            if (normalizedType == 'coming') {
              clearPickupWait();
            } else if (nextSheet == RideSheetsType.reachedPickup) {
              unawaited(_startPickupWaitForCurrentRide(rideId: event.rideId));
            } else {
              clearPickupWait();
            }
            unawaited(
              hydrateActiveRideDetailsIfNeeded(preferredRideId: event.rideId),
            );

            if (normalizedType == 'accepted') {
              unawaited(_syncOnlineForResumeAndRoute(type: normalizedType));
            }
            _triggerRideSoundEffect(event.type ?? event.ride?.rideStatus);
          },
        ),
      ),
    );
  }

  void _handleRideCancelled(RideResponseEntity event) {
    void applyClearedState() {
      locator<SoundService>().playRideCancelledSound();
      state = state.copyWith(
        status: SocketStatus.success,
        action: SocketAction.rideStatusUpdate,
        message: event.message ?? state.message,
        clearRide: true,
        incomingRides: const <RideEntity>[],
        currentSheet: RideSheetsType.pickupDetails,
        clearChatNotification: true,
        isChatOpen: false,
      );
      clearPickupWait();
      ref.read(dashboardProvider.notifier).getDashboardData();
      _clearStoredChatConversation();
    }

    // Replace stack with /home. Do not use only addPostFrameCallback for [go]:
    // from a socket callback it can be deferred until the next unrelated frame
    // (e.g. next tap). scheduleMicrotask runs right after this callback returns
    // so GoRouter applies immediately; then clear state on the following frame.
    scheduleMicrotask(() {
      _navigateToDashboardReplacingStack();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        applyClearedState();
      });
    });
  }

  void _listenToSocketErrors() {
    _subscriptions.add(
      _useCase.socketErrors().listen(
        (either) => either.fold((failure) {
          if (_isDriverOfflineMessage(failure.message)) {
            _applyDriverOfflineState(
              message: _driverOfflineUiMessage(failure.message),
              action: state.action,
              status: SocketStatus.error,
            );
            return;
          }
          state = state.copyWith(
            status: SocketStatus.error,
            message: failure.message,
          );
        }, (_) {}),
      ),
    );
  }

  void _listenToShiftExceeded() {
    _subscriptions.add(
      _useCase.shiftExceededStream().listen(
        (either) => either.fold((failure) {}, (message) {
          state = state.copyWith(
            status: SocketStatus.success,
            action: SocketAction.shiftExceeded,
            isOnline: false,
            incomingRides: const <RideEntity>[],
            showBadge: false,
            message: message,
          );
          _stopLocationUpdates();
        }),
      ),
    );
  }

  void _listenToConnectionStatus() {
    _connectionStatusSub?.cancel();
    _connectionStatusSub = _socketService.statusStream.listen((status) async {
      if (!_isInitialized) return;

      if (status == SocketConnectionStatus.connected) {
        _isReconnecting = false;
        if (state.isOnline && _locationStreamSub == null) {
          await _startLocationUpdates();
        }
        if (_needsSocketListenerResync) {
          _needsSocketListenerResync = false;
          unawaited(_resyncSocketListenersAfterNetwork());
        }
        _syncAvailableRidesIfOnline(trigger: 'socket_connected');
      } else if (status == SocketConnectionStatus.reconnecting ||
          status == SocketConnectionStatus.disconnected) {
        _needsSocketListenerResync = true;
        if (state.isOnline) {
          _stopLocationUpdates();
        }
        unawaited(_reconnectIfNeeded());
      }
    });
  }

  Future<void> _reconnectIfNeeded() async {
    if (_isReconnecting || !_isInitialized) {
      return;
    }

    // Socket may already be up (e.g. library auto-reconnect) while native
    // `chat:receive` handlers were cleared — still run [connect] to re-bind.
    if (_socketService.isConnected) {
      final result = await _useCase.connect();
      result.fold(
        (failure) {
          state = state.copyWith(
            status: SocketStatus.error,
            message: failure.message,
          );
        },
        (_) {
          _attachListeners();
          state = state.copyWith(
            status: SocketStatus.success,
            clearMessage: true,
          );
        },
      );
      return;
    }

    _isReconnecting = true;
    final result = await _useCase.connect();
    result.fold(
      (failure) {
        state = state.copyWith(
          status: SocketStatus.error,
          message: failure.message,
        );
      },
      (_) {
        _attachListeners();
        state = state.copyWith(
          status: SocketStatus.success,
          clearMessage: true,
        );
      },
    );
    _isReconnecting = false;
  }

  Future<void> _resyncSocketListenersAfterNetwork() async {
    if (!_isInitialized) {
      return;
    }
    final result = await _useCase.connect();
    result.fold((failure) {
      state = state.copyWith(
        status: SocketStatus.error,
        message: failure.message,
      );
    }, (_) => _attachListeners());
  }

  // RideSheetsType _sheetForRide(RideEntity? ride) {
  //   // final currentSheet = state.currentSheet;

  //   final String status = (ride?.rideStatus ?? '').trim().toLowerCase();
  //   if (status == 'arrived') {
  //     return RideSheetsType.reachedPickup;
  //   }
  //   if (status == 'in-progress' || status == 'started' || status == 'active') {
  //     return RideSheetsType.rideInProgress;
  //   }
  //   if (status == 'completed') {
  //     return RideSheetsType.reachedDestination;
  //   }
  //   return RideSheetsType.pickupDetails;
  //   // return currentSheet;
  // }

  RideSheetsType _sheetForResponse(String? type) {
    // final currentSheet = state.currentSheet;
    // if (ride != null) {
    //   return _sheetForRide(ride);
    // }

    final String normalizedType = (type ?? '').trim().toLowerCase();
    if (normalizedType == 'arrived' || normalizedType == 'coming') {
      return RideSheetsType.reachedPickup;
    }
    if (normalizedType == 'in-progress' ||
        normalizedType == 'started' ||
        normalizedType == 'active'
    // ||
    // normalizedType == 'accepted'
    ) {
      return RideSheetsType.rideInProgress;
    }
    if (normalizedType == 'completed') {
      return RideSheetsType.reachedDestination;
    }
    return RideSheetsType.pickupDetails;

    // return currentSheet;
  }

  String _terminalStatusForEvent({RideEntity? ride, String? type}) {
    final String rideStatus = (ride?.rideStatus ?? '').trim().toLowerCase();
    if (rideStatus.isNotEmpty) return rideStatus;
    return (type ?? '').trim().toLowerCase();
  }

  List<RideEntity> _sortIncomingRides(Iterable<RideEntity> rides) {
    final List<MapEntry<int, RideEntity>> indexed = rides
        .toList()
        .asMap()
        .entries
        .toList();

    indexed.sort((a, b) {
      final int createdAtCompare = _compareDateDesc(
        a.value.createdAt,
        b.value.createdAt,
      );
      if (createdAtCompare != 0) {
        return createdAtCompare;
      }

      final int updatedAtCompare = _compareDateDesc(
        a.value.updatedAt,
        b.value.updatedAt,
      );
      if (updatedAtCompare != 0) {
        return updatedAtCompare;
      }

      return a.key.compareTo(b.key);
    });

    return indexed.map((entry) => entry.value).toList(growable: false);
  }

  List<RideEntity> _upsertIncomingRide(
    List<RideEntity> currentRides,
    RideEntity ride,
  ) {
    final String? rideId = _normalizeRideId(ride.id);

    // A ride already in the queue keeps the fields the trimmed socket payload
    // does not carry (e.g. `createdAt`, which drives the ordering).
    RideEntity finalRide = ride;
    for (final RideEntity existing in currentRides) {
      if (_normalizeRideId(existing.id) != rideId) continue;
      finalRide = ride.copyWith(
        createdAt: ride.createdAt ?? existing.createdAt,
        driverFare: ride.driverFare ?? existing.driverFare,
        dispatch: ride.dispatch ?? existing.dispatch,
      );
      break;
    }

    final Iterable<RideEntity> deduped = currentRides.where((item) {
      if (rideId == null) {
        return true;
      }
      return _normalizeRideId(item.id) != rideId;
    });

    return _sortIncomingRides(<RideEntity>[finalRide, ...deduped]);
  }

  List<RideEntity> _removeIncomingRideList(
    List<RideEntity> currentRides,
    String rideId,
  ) {
    final String? normalizedRideId = _normalizeRideId(rideId);
    if (normalizedRideId == null) {
      return currentRides;
    }

    return currentRides
        .where((ride) => _normalizeRideId(ride.id) != normalizedRideId)
        .toList(growable: false);
  }

  int _compareDateDesc(DateTime? left, DateTime? right) {
    if (left == null && right == null) {
      return 0;
    }
    if (left == null) {
      return 1;
    }
    if (right == null) {
      return -1;
    }
    return right.compareTo(left);
  }

  /// Folds the ride carried by a status event onto the local copy.
  ///
  /// Every `ride:status:update` now ships the ride populated, so the event is
  /// the source of truth for what it contains, while fields it leaves out
  /// (pickup, dropoff, OTP…) survive from [current]. [event] also carries
  /// `driverFare` beside the ride.
  RideEntity? _mergeRide(
    RideEntity? current,
    RideEntity? incoming,
    RideResponseEntity event,
  ) {
    if (incoming == null) {
      return event.driverFare == null
          ? current
          : current?.copyWith(driverFare: event.driverFare);
    }
    if (current == null ||
        _normalizeRideId(current.id) != _normalizeRideId(incoming.id)) {
      return incoming.driverFare == null && event.driverFare != null
          ? incoming.copyWith(driverFare: event.driverFare)
          : incoming;
    }

    return current.copyWith(
      rideStatus: incoming.rideStatus.trim().isEmpty
          ? current.rideStatus
          : incoming.rideStatus,
      rideType: incoming.rideType.trim().isEmpty ? null : incoming.rideType,
      specialRequest: incoming.specialRequest.trim().isEmpty
          ? null
          : incoming.specialRequest,
      rideDistance: incoming.rideDistance == 0 ? null : incoming.rideDistance,
      rideFare: incoming.rideFare == 0 ? null : incoming.rideFare,
      driverFare: incoming.driverFare ?? event.driverFare,
      averageTime: incoming.averageTime == 0 ? null : incoming.averageTime,
      paymentMethod: incoming.paymentMethod.trim().isEmpty
          ? null
          : incoming.paymentMethod,
      paymentStatus: incoming.paymentStatus.trim().isEmpty
          ? null
          : incoming.paymentStatus,
      user: incoming.user,
      driver: incoming.driver,
      driverId: incoming.driverId,
      userId: incoming.userId,
      vehicle: incoming.vehicle,
      pickupPoint: incoming.pickupPoint,
      dropOffPointRequested: incoming.dropOffPointRequested,
      otp: incoming.otp,
      updatedAt: incoming.updatedAt,
    );
  }

  /// Whether a status event is about a ride assigned to this driver.
  ///
  /// Uses the driver id on the payload when it is there; otherwise falls back
  /// to "this driver is the one who just tapped accept on it". Both matter
  /// under ring dispatch, where the same request reaches several drivers.
  bool _isRideMine(RideResponseEntity event) {
    final String? eventRideId = _normalizeRideId(
      event.rideId ?? event.ride?.id,
    );
    if (eventRideId != null &&
        eventRideId == _normalizeRideId(state.acceptingRideId)) {
      return true;
    }

    final String rideDriverId = (event.ride?.driverId ?? '').trim();
    if (rideDriverId.isEmpty) return false;

    final String myId = (_storage.getUID ?? '').trim();
    if (myId.isEmpty) return false;

    return rideDriverId.toLowerCase() == myId.toLowerCase();
  }

  bool _eventTargetsCurrentRide(RideResponseEntity event) {
    final String? currentRideId = _resolveCurrentRideId();
    final String? eventRideId = _normalizeRideId(
      event.rideId ?? event.ride?.id,
    );
    return currentRideId != null &&
        eventRideId != null &&
        currentRideId == eventRideId;
  }

  bool _reconcileIncomingRidesForStatusEvent(RideResponseEntity event) {
    final String? eventRideId = _normalizeRideId(
      event.rideId ?? event.ride?.id,
    );
    if (eventRideId == null) {
      return false;
    }

    // 🔹 Optimization: If we are CURRENTLY accepting this specific rideId,
    // do not remove it from incomingRides yet. The acceptRideRequest ACK
    // needs to find it in the list to correctly set the active 'ride' property,
    // avoiding a race condition where the driver gets stuck on the request screen.
    if (eventRideId == state.acceptingRideId) {
      return false;
    }

    final String normalizedStatus = _normalizedIncomingRideStatus(event);
    if (_isPendingIncomingRideStatus(normalizedStatus) && event.ride != null) {
      state = state.copyWith(
        incomingRides: _upsertIncomingRide(state.incomingRides, event.ride!),
      );
      return true;
    }

    // 🔹 If the ride has been 'accepted', promote it to the active ride
    // This triggers the UI to navigate to the Ride Room screen.
    final bool isAccepted = normalizedStatus == 'accepted';

    final List<RideEntity> updated = _removeIncomingRideList(
      state.incomingRides,
      eventRideId,
    );

    if (isAccepted && event.ride != null) {
      state = state.copyWith(
        status: SocketStatus.success,
        action: SocketAction.rideStatusUpdate,
        ride: event.ride,
        incomingRides: updated,
      );
      return true;
    }

    if (updated.length == state.incomingRides.length) {
      return false;
    }

    state = state.copyWith(incomingRides: updated);
    return true;
  }

  String _normalizedIncomingRideStatus(RideResponseEntity event) {
    final String rideStatus = (event.ride?.rideStatus ?? '')
        .trim()
        .toLowerCase();
    if (rideStatus.isNotEmpty) {
      return rideStatus;
    }
    return (event.type ?? '').trim().toLowerCase();
  }

  bool _isPendingIncomingRideStatus(String status) {
    return status == 'requested' || status == 'pending' || status == 'open';
  }

  String? _resolveCurrentRideId() {
    return _normalizeRideId(state.ride?.id);
  }

  String? _normalizeRideId(String? rawId) {
    if (rawId == null || rawId.trim().isEmpty) return null;
    return rawId.trim();
  }

  bool _isDriverOfflineMessage(String? message) {
    final normalized = message?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty) {
      return false;
    }
    final bool isOffline =
        normalized.contains('driver_is_offline') ||
        normalized.contains('driver is offline');

    return isOffline;
  }

  String _driverOfflineUiMessage(String? message) {
    final normalized = message?.trim() ?? '';
    if (normalized.isEmpty || _isDriverOfflineMessage(normalized)) {
      return 'You are offline right now. Please go online again to receive ride requests.';
    }
    return normalized;
  }

  void _applyDriverOfflineState({
    required String message,
    required SocketAction action,
    required SocketStatus status,
  }) {
    _stopLocationUpdates();
    state = state.copyWith(
      status: status,
      action: action,
      message: message,
      isOnline: false,
      incomingRides: const <RideEntity>[],
      showBadge: false,
    );
  }

  void _syncAvailableRidesIfOnline({required String trigger}) {
    if (!state.isOnline || _isSyncingAvailableRides) {
      return;
    }

    log(
      '[RideSocketController] Syncing ride queue from $trigger',
      name: 'RideSocketController',
    );
    unawaited(availableRides(silent: true));
  }

  Future<void> _cancelAllSubscriptions() async {
    final subscriptions = List<StreamSubscription<dynamic>>.from(
      _subscriptions,
    );
    _subscriptions.clear();

    for (final sub in subscriptions) {
      await sub.cancel();
    }
    await _connectionStatusSub?.cancel();
    _connectionStatusSub = null;
  }

  Future<void> hydrateActiveRideDetailsIfNeeded({
    String? preferredRideId,
  }) async {
    final RideEntity? ride = state.ride;
    final bool needsHydration = ride == null || !_hasRideDetails(ride);
    if (!needsHydration) return;

    final String? rideId = _normalizeRideId(preferredRideId ?? ride?.id);
    if (rideId == null) return;

    final result = await _getRideByIdUseCase.call(rideId);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: SocketStatus.error,
          message: failure.message,
        );
      },
      (hydratedRide) {
        final String? beforeId = _normalizeRideId(state.ride?.id);
        final String? afterId = _normalizeRideId(hydratedRide.id);
        final bool newRideContext =
            beforeId != afterId && (beforeId != null || afterId != null);
        state = state.copyWith(
          status: SocketStatus.success,
          ride: hydratedRide,
          // currentSheet: _sheetForRide(hydratedRide),
          clearMessage: true,
          clearChatNotification: newRideContext,
        );
        if (newRideContext && beforeId != null) {
          _clearStoredChatConversation();
        }
        _restorePersistedChatUnreadForCurrentContext();
        _tryRestorePickupWaitFromStorage();
      },
    );
  }

  bool _hasRideDetails(RideEntity ride) {
    return (ride.user?.name.trim().isNotEmpty ?? false) ||
        (ride.user?.profilePicture.trim().isNotEmpty ?? false) ||
        (ride.pickupPoint?.placeName.trim().isNotEmpty ?? false) ||
        (ride.dropOffPointRequested?.placeName.trim().isNotEmpty ?? false);
  }

  Future<void> _syncOnlineForResumeAndRoute({String? type}) async {
    if (!state.isOnline) {
      final onlineResult = await _useCase.driverOnline(NoParams());
      onlineResult.fold(
        (failure) {
          state = state.copyWith(
            status: SocketStatus.error,
            action: SocketAction.none,
            message: failure.message,
          );
        },
        (_) async {
          state = state.copyWith(
            status: SocketStatus.success,
            action: SocketAction.none,
            isOnline: true,
            clearMessage: true,
          );
          if (_locationStreamSub == null) {
            await _startLocationUpdates();
          }
        },
      );
    }

    final router = AppRouter.router;
    final RouteMatch lastMatch =
        router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : router.routerDelegate.currentConfiguration;
    final String currentLocation = matchList.uri.toString();
    final String normalizedType = (type ?? '').trim().toLowerCase();
    const Set<String> terminalResumeTypes = <String>{
      'cancelled',
      'canceled',
      'completed',
      'dropped',
      'expired',
    };
    if (terminalResumeTypes.contains(normalizedType)) {
      return;
    }

    // Only an assigned ride routes anywhere now: with offers retired there is
    // no resume type that sends the driver to the request list.
    const Routes targetRoute = Routes.rideRoom;

    if (!_isRoutingToRideRoom &&
        !currentLocation.startsWith(targetRoute.path)) {
      _isRoutingToRideRoom = true;
      try {
        AppRouter.router.goNamed(targetRoute.name);
      } finally {
        _isRoutingToRideRoom = false;
      }
    }
  }

  /// Single navigation authority: [GoRouter.go] replaces the route stack with
  /// `/home` so chat (pushed on top of ride room) is torn down together.
  /// Always use [AppRouter.router] so navigation does not depend on widget
  /// [BuildContext] from the current route.
  void _navigateToDashboardReplacingStack() {
    if (_isRoutingToHome) {
      return;
    }

    final router = AppRouter.router;
    final RouteMatch lastMatch =
        router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : router.routerDelegate.currentConfiguration;
    final String currentLocation = matchList.uri.toString();

    final isRestrictedPath =
        currentLocation.startsWith('/profile') ||
        currentLocation.startsWith('/ride-history') ||
        currentLocation.contains(Routes.ridehistorydetail.path) ||
        currentLocation.contains(Routes.passengerdetail.path) ||
        currentLocation.contains(Routes.ridedetailcarpool.path) ||
        currentLocation.contains(Routes.wallet.path) ||
        currentLocation.contains(Routes.bankAccount.path) ||
        currentLocation.contains(Routes.addBankAccount.path) ||
        currentLocation.contains(Routes.carpoolCreate.path) ||
        currentLocation.contains(Routes.passengerList.path) ||
        currentLocation.contains(Routes.carpoolFeedback.path) ||
        currentLocation.contains(Routes.rideMap.path) ||
        currentLocation.contains(Routes.deleteAccountOTP.path) ||
        currentLocation.contains(Routes.deleteAccountVerify.path);

    if (isRestrictedPath) {
      return;
    }

    _isRoutingToHome = true;
    try {
      AppRouter.router.go(Routes.home.path);
    } finally {
      _isRoutingToHome = false;
    }
  }

  void updateLocalSheet(RideSheetsType sheetType) {
    if (state.currentSheet == sheetType) return;
    state = state.copyWith(currentSheet: sheetType);
  }

  void updateEta(String? eta) {
    if (_currentEta != eta) {
      debugPrint('📡 [RideRoomProvider] updateEta: $_currentEta -> $eta');
      _currentEta = eta;
      if (state.isOnline && _socketService.isConnected) {
        if (_lastPosition != null) {
          unawaited(_sendPositionUpdate(_lastPosition!));
        } else {
          unawaited(_sendCurrentLocation());
        }
      }
    }
  }

  void clearRideState() {
    state = state.copyWith(
      clearRide: true,
      action: SocketAction.none,
      status: SocketStatus.initial,
      incomingRides: const <RideEntity>[],
      currentSheet: RideSheetsType.pickupDetails,
      clearMessage: true,
      clearPickupWait: true,
      clearChatNotification: true,
    );
    _clearStoredChatConversation();
  }

  void _clearStoredChatConversation() {
    _currentEta = null;
    ref.read(chatHistoryProvider.notifier).clearConversation();
    _clearPersistedUnreadState();
  }
}
