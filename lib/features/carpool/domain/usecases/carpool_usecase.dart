import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/core/params/carpool_params.dart';
import 'package:driver_app/features/carpool/domain/entities/carpool_entity.dart';
import 'package:driver_app/features/carpool/domain/entities/view_carpool_passenger_entity.dart';
import 'package:driver_app/features/carpool/domain/repositories/carpool_repository.dart';
import 'package:driver_app/features/carpool/domain/repositories/carpool_socket_repository.dart';
import 'package:fpdart/fpdart.dart';

/// UseCase to create a new carpool route
class CreateCarpoolRouteUseCase {
  final CarpoolSocketRepository repository;
  CreateCarpoolRouteUseCase(this.repository);

  Future<Either<Failure, String>> call(CarpoolRideParams params) async {
    return await repository.createRoute(params);
  }
}

/// UseCase to respond to a carpool request (accept/reject)
class RespondToCarpoolRequestUseCase {
  final CarpoolSocketRepository repository;
  RespondToCarpoolRequestUseCase(this.repository);

  Future<Either<Failure, String>> call(BookingActionRequestParams params) async {
    return await repository.respondToRequest(params);
  }
}

/// UseCase to pick passenger with OTP verification
class PickCarpoolPassengerUseCase {
  final CarpoolSocketRepository repository;
  PickCarpoolPassengerUseCase(this.repository);

  Future<Either<Failure, String>> call(BookingOtpRequestParams params) async {
    return await repository.pickPassenger(params);
  }
}

/// UseCase to start a carpool
class StartCarpoolUseCase {
  final CarpoolSocketRepository repository;
  StartCarpoolUseCase(this.repository);

  Future<Either<Failure, String>> call(String carpoolId) async {
    return await repository.startCarpool(carpoolId);
  }
}

/// UseCase to complete a carpool
class CompleteCarpoolUseCase {
  final CarpoolSocketRepository repository;
  CompleteCarpoolUseCase(this.repository);

  Future<Either<Failure, String>> call(String bookingId) async {
    return await repository.completeCarpool(bookingId);
  }
}

/// UseCase to notify server when driver arrives at a route stop
class ArriveAtCarpoolStopUseCase {
  final CarpoolSocketRepository repository;
  ArriveAtCarpoolStopUseCase(this.repository);

  Future<Either<Failure, String>> call(CarpoolArriveRequestParams params) async {
    return await repository.arriveAtStop(params);
  }
}

/// UseCase to cancel a carpool route
class CancelCarpoolRouteUseCase {
  final CarpoolSocketRepository repository;
  CancelCarpoolRouteUseCase(this.repository);

  Future<Either<Failure, String>> call(String carpoolId) async {
    return await repository.cancelRoute(carpoolId);
  }
}

/// UseCase to listen for incoming carpool requests
class IncomingCarpoolRequestUseCase {
  final CarpoolSocketRepository repository;
  IncomingCarpoolRequestUseCase(this.repository);

  Stream<CarpoolIncomingRequestEntity> call() =>
      repository.incomingRequestStream();
}

/// UseCase to listen for route updates
class CarpoolRouteUpdateUseCase {
  final CarpoolSocketRepository repository;
  CarpoolRouteUpdateUseCase(this.repository);

  Stream<Map<String, dynamic>> call() => repository.routeUpdateStream();
}

/// UseCase to listen for passenger picked up events
class CarpoolPassengerPickedUseCase {
  final CarpoolSocketRepository repository;
  CarpoolPassengerPickedUseCase(this.repository);

  Stream<Map<String, dynamic>> call() => repository.passengerPickedStream();
}

/// UseCase to listen for completed rides
class CarpoolRideCompletedUseCase {
  final CarpoolSocketRepository repository;
  CarpoolRideCompletedUseCase(this.repository);

  Stream<Map<String, dynamic>> call() => repository.rideCompletedStream();
}

/// UseCase to watch socket errors
class CarpoolSocketErrorUseCase {
  final CarpoolSocketRepository repository;
  CarpoolSocketErrorUseCase(this.repository);

  Stream<String> call() => repository.watchErrors();
}

class ViewPassengerUseCase {
  final CarpoolRepository repository;

  ViewPassengerUseCase(this.repository);

  Future<Either<Failure, List<CarpoolPassengerEntity>>> call(String carpoolId) async {
    return await repository.viewPassenger(carpoolId);
  }
}
