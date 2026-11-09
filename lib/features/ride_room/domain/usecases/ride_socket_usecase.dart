import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/core/params/driver_location_params.dart';
import 'package:driver_app/core/usecase/usecase.dart';
import 'package:driver_app/features/ride_room/domain/entities/chat_entity.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_entities.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_response_entity.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_taken_entity.dart';
import 'package:driver_app/features/ride_room/domain/repositories/ride_socket_repository.dart';
import 'package:fpdart/fpdart.dart';

/// ------------------------------
/// Ride Socket Use Cases
/// ------------------------------
class RideSocketUseCase {
  final RideSocketRepository repository;

  RideSocketUseCase(this.repository);

  // ================================
  // Connect / Disconnect
  // ================================
  Future<Either<Failure, void>> connect() async {
    return await repository.connect();
  }

  Future<Either<Failure, void>> disconnect() async {
    return await repository.disconnect();
  }

  // ================================
  // Driver Events
  // ================================
  // ================================
  // Chat
  // ================================
  Stream<Either<Failure, ChatMessageEntity>> chatStream() {
    return repository.chatStream();
  }

  Future<Either<Failure, String>> driverOnline(NoParams params) async {
    return await repository.driverOnline(params);
  }

  Future<Either<Failure, String>> driverOffline(NoParams params) async {
    return await repository.driverOffline(params);
  }

  Future<Either<Failure, String>> driverLocationUpdate(
    DriverLocationParams params,
  ) async {
    return await repository.driverLocationUpdate(params);
  }

  Future<Either<Failure, String>> driverArrive(
    String rideId, {
    required double lat,
    required double lng,
  }) async {
    return await repository.driverArrive(rideId, lat: lat, lng: lng);
  }

  Future<Either<Failure, String>> acceptRideRequest(String rideId) async {
    return await repository.acceptRideRequest(rideId);
  }

  Stream<Either<Failure, RideEntity>> incomingRidesUpdate() {
    return repository.incomingRidesUpdate();
  }

  /// Ring dispatch: the ride was won by another driver.
  Stream<Either<Failure, RideTakenEntity>> rideTakenUpdate() {
    return repository.rideTakenUpdate();
  }

  Stream<Either<Failure, RideResponseEntity>> rideResumeUpdate() {
    return repository.rideResumeUpdate();
  }

  Stream<Either<Failure, RideResponseEntity>> rideStatusUpdate() {
    return repository.rideStatusUpdate();
  }

  Stream<Either<Failure, String>> driverOnlineUpdateStream() {
    return repository.driverOnlineUpdateStream();
  }

  // Stream<Either<Failure, DriverLocationEntity>> driverLocationUpdateStream() {
  //   return repository.driverLocationUpdateStream();
  // }

  // ================================
  // Ride Lifecycle Events (Future)
  // ================================

  Future<Either<Failure, String>> rideStart(String rideId, {int? otp}) async {
    return await repository.rideStart(rideId, otp: otp);
  }

  Future<Either<Failure, String>> rideCancel(
    String rideId, {
    required String cancellationReason,
  }) async {
    return await repository.rideCancel(
      rideId,
      cancellationReason: cancellationReason,
    );
  }

  Future<Either<Failure, String>> rideComplete(String rideId) async {
    return await repository.rideComplete(rideId);
  }

  // ================================
  // Socket Errors
  // ================================
  Stream<Either<Failure, String>> shiftExceededStream() {
    return repository.shiftExceededStream();
  }

  Stream<Either<Failure, String>> socketErrors() {
    return repository.socketErrors();
  }
}
