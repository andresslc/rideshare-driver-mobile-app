import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/core/usecase/usecase.dart';
import 'package:driver_app/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:driver_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetDashboardUseCase extends UseCase<DriverDashboardEntity, NoParams> {
  final DashboardRepository _repository;

  GetDashboardUseCase(this._repository);

  @override
  Future<Either<Failure, DriverDashboardEntity>> call(NoParams params) async {
    return await _repository.getDashboardData();
  }
}
