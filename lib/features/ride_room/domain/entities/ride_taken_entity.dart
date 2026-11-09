import 'package:driver_app/features/ride_room/domain/entities/ride_entities.dart';

/// Payload of `ride:request:taken`.
///
/// Reaches the driver in two situations, with the same shape: the driver tapped
/// accept and someone else got there first, or another driver won the ride
/// without this one touching anything. Either way the card for [rideId] must
/// leave the screen and the queue is repainted with [availableRides], which
/// comes in the same format as `GET /rides?status=requested`.
class RideTakenEntity {
  final String rideId;
  final String reason;

  /// Fresh queue sent with the event. `null` when the event did not carry it
  /// (an empty list is a real answer: nothing left to take).
  final List<RideEntity>? availableRides;

  const RideTakenEntity({
    required this.rideId,
    this.reason = '',
    this.availableRides,
  });

  String get normalizedReason => reason.trim().toUpperCase();
}
