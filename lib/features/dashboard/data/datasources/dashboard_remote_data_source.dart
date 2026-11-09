import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/services/api_service.dart';
import '../models/dashboard_model.dart';

/// ===============================
/// ABSTRACT DATASOURCE
/// ===============================
abstract class DashboardDatasource {
  /// Fetch dashboard data
  Future<Either<Failure, DriverDashboardModel>> getDashboardData();
}

/// ===============================
/// IMPLEMENTATION
/// ===============================
class DashboardDatasourceImpl implements DashboardDatasource {
  final ApiService _apiService = locator<ApiService>();

  @override
  Future<Either<Failure, DriverDashboardModel>> getDashboardData() {
    return handleNetworkError(() async {
      final res = await _apiService.get(ApiEndpoints.dashBoard);

      return DriverDashboardModel.fromJson(res.data);
    });
  }
}
