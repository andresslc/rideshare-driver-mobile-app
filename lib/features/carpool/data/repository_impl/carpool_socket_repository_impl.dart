import 'package:driver_app/core/utils/typedefs.dart';
import 'package:driver_app/features/carpool/data/datasources/carpool_socket_datasource.dart';
import 'package:driver_app/features/carpool/domain/entities/carpool_entity.dart';
import 'package:driver_app/features/carpool/domain/repositories/carpool_socket_repository.dart';

import 'package:driver_app/core/params/carpool_params.dart';

class CarpoolSocketRepositoryImpl implements CarpoolSocketRepository {
  final CarpoolSocketDataSource dataSource;

  CarpoolSocketRepositoryImpl(this.dataSource);

  // Streams
  @override
  Stream<CarpoolIncomingRequestEntity> incomingRequestStream() =>
      dataSource.incomingRequestStream();

  @override
  Stream<Map<String, dynamic>> routeUpdateStream() =>
      dataSource.routeUpdateStream();

  @override
  Stream<Map<String, dynamic>> carpoolResumeStream() =>
      dataSource.carpoolResumeStream();

  @override
  Stream<Map<String, dynamic>> passengerPickedStream() =>
      dataSource.passengerPickedStream();

  @override
  Stream<Map<String, dynamic>> rideCompletedStream() =>
      dataSource.rideCompletedStream();

  @override
  Stream<Map<String, dynamic>> bookingStatusStream() =>
      dataSource.bookingStatusStream();

  @override
  Stream<String> watchErrors() => dataSource.watchErrors();

  // Events
  @override
  FutureEither<String> createRoute(CarpoolRideParams params) =>
      dataSource.createRoute(params);

  @override
  FutureEither<String> respondToRequest(BookingActionRequestParams params) =>
      dataSource.respondToRequest(params);

  @override
  FutureEither<String> pickPassenger(BookingOtpRequestParams params) =>
      dataSource.pickPassenger(params);

  @override
  FutureEither<String> startCarpool(String carpoolId) =>
      dataSource.startCarpool(carpoolId);

  @override
  FutureEither<String> completeCarpool(String bookingId) =>
      dataSource.completeCarpool(bookingId);

  @override
  FutureEither<String> arriveAtStop(CarpoolArriveRequestParams params) =>
      dataSource.arriveAtStop(params);

  @override
  FutureEither<String> cancelRoute(String carpoolId) =>
      dataSource.cancelRoute(carpoolId);
}
