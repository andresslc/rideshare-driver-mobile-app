import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/params/driver_location_params.dart';
import 'package:driver_app/features/ride_room/data/datasources/ride_socket_datasource.dart';
import 'package:driver_app/features/ride_room/domain/entities/chat_entity.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_entities.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_response_entity.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_taken_entity.dart';
import 'package:driver_app/features/ride_room/domain/repositories/ride_socket_repository.dart';
import 'package:fpdart/fpdart.dart';

class RideSocketRepositoryImpl implements RideSocketRepository {
  final RideSocketDataSource dataSource;

  RideSocketRepositoryImpl(this.dataSource);

  // ================================
  // Connect / Disconnect
  // ================================

  @override
  Future<Either<Failure, void>> connect() async {
    try {
      await dataSource.connect();
      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> disconnect() async {
    try {
      await dataSource.disconnect();
      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  // ================================
  // Driver Events
  // ================================

  @override
  Future<Either<Failure, String>> driverOnline(NoParams params) async {
    final response = await dataSource.toggleDriverOnline();
    return response.fold((failure) => Left(failure), (data) => Right(data));
  }

  @override
  Future<Either<Failure, String>> driverOffline(NoParams params) async {
    final response = await dataSource.toggleDriverOffline();
    return response.fold((failure) => Left(failure), (data) => Right(data));
  }

  @override
  Future<Either<Failure, String>> driverLocationUpdate(
    DriverLocationParams params,
  ) async {
    final response = await dataSource.driverLocationUpdate(params);
    log(
      "Driver location update response: ${response.fold((l) => l.message, (r) => r)}",
    );
    return response.fold((failure) => Left(failure), (data) => Right(data));
  }

  @override
  Future<Either<Failure, String>> acceptRideRequest(String rideId) async {
    final response = await dataSource.acceptRideRequest(rideId);
    return response.fold((failure) => Left(failure), (data) => Right(data));
  }

  // ================================
  // Incoming / Resume / Status Rides
  // ================================

  // ================================
  // Chat
  // ================================
  @override
  Stream<Either<Failure, ChatMessageEntity>> chatStream() {
    return dataSource.chatStream().map((event) => Right(event));
  }

  @override
  Stream<Either<Failure, RideEntity>> incomingRidesUpdate() {
    return dataSource.incomingRidesUpdate().map((event) => Right(event));
  }

  @override
  Stream<Either<Failure, RideTakenEntity>> rideTakenUpdate() {
    return dataSource.rideTakenUpdate().map((event) => Right(event));
  }

  @override
  Stream<Either<Failure, RideResponseEntity>> rideResumeUpdate() {
    return dataSource.rideResumeUpdate().map((event) => Right(event));
  }

  @override
  Stream<Either<Failure, RideResponseEntity>> rideStatusUpdate() {
    return dataSource.rideStatusUpdate().map((event) => Right(event));
  }

  @override
  Stream<Either<Failure, String>> driverOnlineUpdateStream() {
    return dataSource.driverOnlineUpdateStream().map((event) => Right(event));
  }

  // @override
  // Stream<Either<Failure, DriverLocationEntity>> driverLocationUpdateStream() {
  //   return dataSource.driverLocationUpdateStream().map((event) => Right(event));
  // }

  // ================================
  //  Ride Events
  // ================================

  @override
  Future<Either<Failure, String>> driverArrive(
    String rideId, {
    required double lat,
    required double lng,
  }) async {
    final response = await dataSource.driverArrive(rideId, lat: lat, lng: lng);
    return response.fold((failure) => Left(failure), (data) => Right(data));
  }

  @override
  Future<Either<Failure, String>> rideStart(String rideId, {int? otp}) async {
    final response = await dataSource.rideStart(rideId, otp: otp);
    return response.fold((failure) => Left(failure), (data) => Right(data));
  }

  @override
  Future<Either<Failure, String>> rideCancel(
    String rideId, {
    required String cancellationReason,
  }) async {
    final response = await dataSource.rideCancel(
      rideId,
      cancellationReason: cancellationReason,
    );
    return response.fold((failure) => Left(failure), (data) => Right(data));
  }

  @override
  Future<Either<Failure, String>> rideComplete(String rideId) async {
    final response = await dataSource.rideComplete(rideId);
    return response.fold((failure) => Left(failure), (data) => Right(data));
  }

  // ================================
  // Errors
  // ================================

  @override
  Stream<Either<Failure, String>> shiftExceededStream() {
    return dataSource.shiftExceededStream().map((event) => Right(event));
  }

  @override
  Stream<Either<Failure, String>> socketErrors() {
    return dataSource.watchErrors().map(
      (error) => Left(NetworkFailure(message: error)),
    );
  }
}
