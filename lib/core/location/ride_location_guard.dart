import 'package:driver_app/features/ride_room/domain/entities/ride_entities.dart';
import 'package:driver_app/features/ride_room/presentation/states/ride_state.dart';

/// Shared rules for blocking the app when GPS is turned off during a ride.
abstract final class RideLocationGuard {
  static bool hasActiveRide(RideEntity? ride) {
    if (ride == null) return false;

    final rideStatus = ride.rideStatus.trim().toLowerCase();
    if (rideStatus.isEmpty) return true;

    switch (rideStatus) {
      case 'completed':
      case 'cancelled':
      case 'canceled':
      case 'dropped':
        return false;
      default:
        return true;
    }
  }

  static bool hasActiveRideFromState(RideSocketState rideState) {
    return hasActiveRide(rideState.ride);
  }

  static bool shouldBlockForDisabledLocation({
    required RideSocketState rideState,
    required bool isLocationServiceEnabled,
  }) {
    return 
    // hasActiveRideFromState(rideState) &&
     !isLocationServiceEnabled;
  }
}
