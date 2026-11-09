class SocketEvent {
  SocketEvent._();

  /// My Chat Socket
  static const String chatReceive = 'chat:receive';
  static const String chatRead = 'chat:read';
  static const String chatStatusUpdated = 'chat:status_updated';

  // Ride
  // Events
  static const String driverOnline = 'driver:online';
  static const String driverOffline = 'driver:offline';
  static const String driverLocationUpdate = 'driver:location:update';
  static const String rideAccept = 'ride:request:accept';
  static const String driverArrive = 'ride:driver:arrive';
  static const String rideStart = 'ride:start';
  static const String rideCancel = 'ride:cancel';
  static const String rideComplete = 'ride:complete';

  // Listenners
  static const String rideIncoming = 'ride:incoming';

  /// Ring dispatch: another driver won the ride (or this driver's accept lost
  /// the race). Carries rideId, reason and a fresh availableRides list.
  static const String rideRequestTaken = 'ride:request:taken';
  static const String rideResume = 'ride:resume';
  static const String rideStatusUpdate = 'ride:status:update';
  // Carpool Listners
  static const String carpoolIncomingRequest = 'carpool:incoming_request';
  static const String carpoolRouteUpdate = 'carpool:route_update';
  static const String carpoolResume = 'carpool:resume';
  static const String carpoolStopArrived = 'carpool:stop_arrived';
  static const String carpoolPassengerPickedUp = 'carpool:passenger_picked_up';
  static const String carpoolRideCompleted = 'carpool:ride_completed';
  static const String carpoolBookingStatus = 'carpool:booking_status';

  // Carpool Events

  static const String carpoolCreateRoute = 'carpool:create:route';
  static const String carpoolRespond = 'carpool:respond';
  static const String carpoolStart = 'carpool:start';
  static const String carpoolComplete = 'carpool:complete';
  static const String carpoolArrive = 'carpool:arrive';
  static const String carpoolCancelRoute = 'carpool:cancel:route';
  static const String carpoolPickPassenger = "carpool:pick_passenger";

  // Generic
  static const String socketError = 'error';
  static const String shiftExceeded = 'SHIFT_EXCEEDED';
}
