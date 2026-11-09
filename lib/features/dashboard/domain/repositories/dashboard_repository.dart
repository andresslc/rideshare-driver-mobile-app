import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DriverDashboardEntity>> getDashboardData();
}
