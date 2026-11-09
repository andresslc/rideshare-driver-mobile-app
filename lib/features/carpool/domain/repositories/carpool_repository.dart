import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/features/carpool/domain/entities/view_carpool_passenger_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class CarpoolRepository {
  Future<Either<Failure, List<CarpoolPassengerEntity>>> viewPassenger(String carpoolId);
}
