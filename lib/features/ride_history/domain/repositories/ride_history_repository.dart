import 'package:driver_app/core/params/carpool_detail_params.dart';
import 'package:driver_app/core/params/carpool_param.dart';
import 'package:driver_app/core/params/passenger_params.dart';
import 'package:driver_app/core/params/ride_history_detail_params.dart';
import 'package:driver_app/features/ride_history/domain/enitities/carpool_history_entities.dart';
import 'package:driver_app/features/ride_history/domain/enitities/passenger_entity.dart';
import 'package:driver_app/features/ride_history/domain/enitities/ride_history_entites.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/params/ride_history_param.dart';
import '../enitities/ride_history_detail_entities.dart';

abstract class RideHistoryRepository {
  Future<Either<Failure, RideHistoryResponseEntity>> getRideHistory({
    required RideHistoryRequestParams params,
  });
  Future<Either<Failure, CarpoolHistoryEntity>> getCarpoolHistory({
    required CarpoolParam params,
  });
  Future<Either<Failure, RideDetailResponseEntity>> getRideDetail({
    required RideHistoryDetailParams params,
  });
  Future<Either<Failure, List<PassengerDetailedEntity>>> getPassengerDetail({
    required PassengerParams params,
  });
  // Future<Either<Failure, CarpoolEntity>> getCarpoolDetail({
  //   required CarpoolDetailParams params,
  // });
}
