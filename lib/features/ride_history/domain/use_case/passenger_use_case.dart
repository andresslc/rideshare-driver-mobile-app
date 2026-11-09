import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/core/params/passenger_params.dart';
import 'package:driver_app/features/ride_history/domain/enitities/passenger_entity.dart';
import 'package:driver_app/features/ride_history/domain/repositories/ride_history_repository.dart';
import 'package:fpdart/fpdart.dart';

class PassengerUseCase {
  final RideHistoryRepository _repository;

  PassengerUseCase(this._repository);

  Future<Either<Failure, List<PassengerDetailedEntity>>> call({
    required PassengerParams params,
  }) async {
    return await _repository.getPassengerDetail(params: params);
  }
}
