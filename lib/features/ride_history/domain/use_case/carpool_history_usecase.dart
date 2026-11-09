import '../../../../core/errors/failure.dart';
import '../../../../core/params/carpool_param.dart';
import '../enitities/carpool_history_entities.dart';
import '../repositories/ride_history_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetCarpoolUseCase {
  final RideHistoryRepository _repository;

  GetCarpoolUseCase(this._repository);

  Future<Either<Failure, CarpoolHistoryEntity>> call({
    required CarpoolParam params,
  }) async {
    return await _repository.getCarpoolHistory(params: params);
  }
}
