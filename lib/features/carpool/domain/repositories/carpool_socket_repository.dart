import 'package:driver_app/core/params/carpool_params.dart';
import 'package:driver_app/core/utils/typedefs.dart';
import 'package:driver_app/features/carpool/domain/entities/carpool_entity.dart';

abstract class CarpoolSocketRepository {
  /// Carpool Listener Streams
  Stream<CarpoolIncomingRequestEntity> incomingRequestStream();
  Stream<Map<String, dynamic>> routeUpdateStream();
  Stream<Map<String, dynamic>> carpoolResumeStream();
  Stream<Map<String, dynamic>> passengerPickedStream();
  Stream<Map<String, dynamic>> rideCompletedStream();
  Stream<Map<String, dynamic>> bookingStatusStream();

  /// Error Stream
  Stream<String> watchErrors();

  /// Carpool Events
  FutureEither<String> createRoute(CarpoolRideParams params);
  FutureEither<String> respondToRequest(BookingActionRequestParams params);
  FutureEither<String> pickPassenger(BookingOtpRequestParams params);
  FutureEither<String> startCarpool(String carpoolId);
  FutureEither<String> completeCarpool(String bookingId);
  FutureEither<String> arriveAtStop(CarpoolArriveRequestParams params);
  FutureEither<String> cancelRoute(String carpoolId);
}
