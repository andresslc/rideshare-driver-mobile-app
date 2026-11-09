import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/features/ride_room/data/models/ride_models.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_entities.dart';
import 'package:driver_app/features/ride_room/domain/repositories/ride_repository.dart';
import 'package:fpdart/fpdart.dart';

class AvailableRideUseCase {
  final RideRepository repository;
  AvailableRideUseCase(this.repository);

  Future<Either<Failure, RideRequestResponseModel>> call() async {
    return await repository.availableRides();
  }


}

class GetRideByIdUseCase {
  final RideRepository repository;
  GetRideByIdUseCase(this.repository);

  Future<Either<Failure, RideEntity>> call(String rideId) async {
    return await repository.getRideById(rideId);
  }
}
