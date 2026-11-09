import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/features/carpool/data/datasources/carpool_datasource.dart';
import 'package:driver_app/features/carpool/domain/entities/view_carpool_passenger_entity.dart';
import 'package:driver_app/features/carpool/domain/repositories/carpool_repository.dart';
import 'package:fpdart/fpdart.dart';

class CarpoolRepositoryImpl implements CarpoolRepository {
  final CarpoolDataSource dataSource;

  CarpoolRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<CarpoolPassengerEntity>>> viewPassenger(String carpoolId) async {
    final result = await dataSource.viewPassenger( carpoolId);
    return result.fold(
      (failure) => Left(failure),
      (models) => Right(models),
    );
  }


}
