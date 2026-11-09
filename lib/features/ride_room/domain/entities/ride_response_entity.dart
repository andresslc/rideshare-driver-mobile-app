import 'package:driver_app/features/ride_room/domain/entities/ride_entities.dart';

class RideResponseEntity {
  final String? type;
  final String? message;
  final RideEntity? ride;
  final String? rideOtp;
  final String? rideId;
  final int? offersCount;

  /// Driver earnings, sent next to `ride` on the status event rather than
  /// inside it.
  final double? driverFare;

  const RideResponseEntity({
    this.type,
    this.message,
    this.ride,
    this.rideOtp,
    this.rideId,
    this.offersCount,
    this.driverFare,
  });
}
