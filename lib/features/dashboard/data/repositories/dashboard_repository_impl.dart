import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../datasources/dashboard_remote_data_source.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// =======================================
/// IMPLEMENTATION
/// =======================================
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDatasource _dataSource;

  const DashboardRepositoryImpl(this._dataSource);

  /// ---------------------------------
  /// Fetch Dashboard Data
  /// ---------------------------------
  @override
  Future<Either<Failure, DriverDashboardEntity>> getDashboardData() async {
    final response = await _dataSource.getDashboardData();

    return response.fold(
      (failure) => Left(ServerFailure(message: failure.message)),
      (dashboardEntity) => Right(dashboardEntity),
    );
  }
}
