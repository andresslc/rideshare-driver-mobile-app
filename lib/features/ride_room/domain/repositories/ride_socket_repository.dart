import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/core/params/driver_location_params.dart';
import 'package:driver_app/core/usecase/usecase.dart';
import 'package:driver_app/features/ride_room/domain/entities/chat_entity.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_entities.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_response_entity.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_taken_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class RideSocketRepository {
  Future<Either<Failure, void>> connect();
  Future<Either<Failure, void>> disconnect();

  // ================================
  // Driver Events
  // ================================
  Stream<Either<Failure, RideEntity>> incomingRidesUpdate();
  Stream<Either<Failure, RideTakenEntity>> rideTakenUpdate();
  Stream<Either<Failure, RideResponseEntity>> rideResumeUpdate();
  Stream<Either<Failure, RideResponseEntity>> rideStatusUpdate();
  Stream<Either<Failure, String>> driverOnlineUpdateStream();
  // Stream<Either<Failure, DriverLocationEntity>> driverLocationUpdateStream();
  Stream<Either<Failure, ChatMessageEntity>> chatStream();

  // ================================
  // Errors
  // ================================
  Stream<Either<Failure, String>> shiftExceededStream();
  Stream<Either<Failure, String>> socketErrors();

  // ================================
  //  Ride Events
  // ================================
  Future<Either<Failure, String>> driverOnline(NoParams params);
  Future<Either<Failure, String>> driverOffline(NoParams params);
  Future<Either<Failure, String>> driverLocationUpdate(
    DriverLocationParams params,
  );
  Future<Either<Failure, String>> acceptRideRequest(String rideId);
  Future<Either<Failure, String>> driverArrive(
    String rideId, {
    required double lat,
    required double lng,
  });
  Future<Either<Failure, String>> rideStart(String rideId, {int? otp});
  Future<Either<Failure, String>> rideCancel(
    String rideId, {
    required String cancellationReason,
  });
  Future<Either<Failure, String>> rideComplete(String rideId);
}
