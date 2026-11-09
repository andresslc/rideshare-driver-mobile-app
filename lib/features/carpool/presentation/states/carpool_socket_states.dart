import 'package:driver_app/features/carpool/domain/entities/carpool_entity.dart';

enum CarpoolSocketStatus { initial, loading, success, error }

enum CarpoolSocketAction {
  none,
  rideIncoming,
  rideResume,
  rideRequestAccept,
  ridePassengerPick,
  ridePassengerDrop,
  rideArrive,
  rideStart,
  rideCancel,
  rideComplete,
}

class CarpoolStopProgress {
  final int order;
  final String stopName;
  final String? routeStopId;
  final List<double> coordinates;
  final bool requiresArrival;
  final bool hasArrived;
  final List<String> bookingIds;
  final List<String> pickedBookingIds;
  final List<String> cancelledBookingIds;

  const CarpoolStopProgress({
    required this.order,
    required this.stopName,
    this.routeStopId,
    this.coordinates = const <double>[],
    this.requiresArrival = false,
    this.hasArrived = false,
    this.bookingIds = const <String>[],
    this.pickedBookingIds = const <String>[],
    this.cancelledBookingIds = const <String>[],
  });

  List<String> get pendingBookingIds => bookingIds
      .where(
        (bookingId) =>
            !pickedBookingIds.contains(bookingId) &&
            !cancelledBookingIds.contains(bookingId),
      )
      .toList(growable: false);

  bool get isCompleted =>
      requiresArrival ? hasArrived : pendingBookingIds.isEmpty;

  CarpoolStopProgress copyWith({
    int? order,
    String? stopName,
    String? routeStopId,
    List<double>? coordinates,
    bool? requiresArrival,
    bool? hasArrived,
    List<String>? bookingIds,
    List<String>? pickedBookingIds,
    List<String>? cancelledBookingIds,
  }) {
    return CarpoolStopProgress(
      order: order ?? this.order,
      stopName: stopName ?? this.stopName,
      routeStopId: routeStopId ?? this.routeStopId,
      coordinates: coordinates ?? this.coordinates,
      requiresArrival: requiresArrival ?? this.requiresArrival,
      hasArrived: hasArrived ?? this.hasArrived,
      bookingIds: bookingIds ?? this.bookingIds,
      pickedBookingIds: pickedBookingIds ?? this.pickedBookingIds,
      cancelledBookingIds: cancelledBookingIds ?? this.cancelledBookingIds,
    );
  }
}

class CarpoolSocketState {
  final CarpoolSocketStatus status;
  final CarpoolSocketAction action;
  final String? message;
  final CarpoolIncomingRequestEntity? lastIncomingRequest;
  final List<CarpoolIncomingRequestEntity> incomingRequests;
  final List<CarpoolIncomingRequestEntity> acceptedRequests;
  final String? activeCarpoolId;
  final List<CarpoolStopProgress> stopProgress;
  final int currentStopIndex;
  final Map<String, dynamic>? lastRideResume;
  final bool hasActiveRide;
  final bool isRideStarted;
  final String? lastPickedBookingId;
  final String? lastCancelledBookingId;

  const CarpoolSocketState({
    this.status = CarpoolSocketStatus.initial,
    this.action = CarpoolSocketAction.none,
    this.message,
    this.lastIncomingRequest,
    this.incomingRequests = const <CarpoolIncomingRequestEntity>[],
    this.acceptedRequests = const <CarpoolIncomingRequestEntity>[],
    this.activeCarpoolId,
    this.stopProgress = const <CarpoolStopProgress>[],
    this.currentStopIndex = 0,
    this.lastRideResume,
    this.hasActiveRide = false,
    this.isRideStarted = false,
    this.lastPickedBookingId,
    this.lastCancelledBookingId,
  });

  CarpoolSocketState copyWith({
    CarpoolSocketStatus? status,
    CarpoolSocketAction? action,
    String? message,
    CarpoolIncomingRequestEntity? lastIncomingRequest,
    List<CarpoolIncomingRequestEntity>? incomingRequests,
    List<CarpoolIncomingRequestEntity>? acceptedRequests,
    String? activeCarpoolId,
    List<CarpoolStopProgress>? stopProgress,
    int? currentStopIndex,
    Map<String, dynamic>? lastRideResume,
    bool? hasActiveRide,
    bool? isRideStarted,
    String? lastPickedBookingId,
    String? lastCancelledBookingId,
    bool clearMessage = false,
    bool clearIncomingRequest = false,
    bool clearIncomingRequests = false,
    bool clearRideResume = false,
    bool clearLastPickedBookingId = false,
    bool clearLastCancelledBookingId = false,
  }) {
    return CarpoolSocketState(
      status: status ?? this.status,
      action: action ?? this.action,
      message: clearMessage ? null : (message ?? this.message),
      lastIncomingRequest: clearIncomingRequest
          ? null
          : (lastIncomingRequest ?? this.lastIncomingRequest),
      incomingRequests: clearIncomingRequests
          ? const <CarpoolIncomingRequestEntity>[]
          : (incomingRequests ?? this.incomingRequests),
      acceptedRequests: acceptedRequests ?? this.acceptedRequests,
      activeCarpoolId: activeCarpoolId ?? this.activeCarpoolId,
      stopProgress: stopProgress ?? this.stopProgress,
      currentStopIndex: currentStopIndex ?? this.currentStopIndex,
      lastRideResume: clearRideResume
          ? null
          : (lastRideResume ?? this.lastRideResume),
      hasActiveRide: hasActiveRide ?? this.hasActiveRide,
      isRideStarted: isRideStarted ?? this.isRideStarted,
      lastPickedBookingId: clearLastPickedBookingId
          ? null
          : (lastPickedBookingId ?? this.lastPickedBookingId),
      lastCancelledBookingId: clearLastCancelledBookingId
          ? null
          : (lastCancelledBookingId ?? this.lastCancelledBookingId),
    );
  }

  int get incomingRequestCount => incomingRequests.length;
  bool get hasAcceptedPassengers => acceptedRequests.isNotEmpty;
  bool get hasRouteStops => stopProgress.isNotEmpty;
  bool get allStopsCompleted =>
      stopProgress.isNotEmpty && stopProgress.every((stop) => stop.isCompleted);
  CarpoolStopProgress? get currentStop =>
      currentStopIndex >= 0 && currentStopIndex < stopProgress.length
      ? stopProgress[currentStopIndex]
      : null;

  @override
  String toString() {
    return 'CarpoolSocketState(status: $status, action: $action, message: $message, lastIncomingRequest: $lastIncomingRequest, incomingRequests: $incomingRequests, acceptedRequests: $acceptedRequests, activeCarpoolId: $activeCarpoolId, stopProgress: $stopProgress, currentStopIndex: $currentStopIndex, lastRideResume: $lastRideResume, hasActiveRide: $hasActiveRide, isRideStarted: $isRideStarted, lastPickedBookingId: $lastPickedBookingId, lastCancelledBookingId: $lastCancelledBookingId)';
  }
}
