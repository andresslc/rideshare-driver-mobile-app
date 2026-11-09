import 'package:fpdart/fpdart.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/app_log.dart';
import '../models/driver_referral_item_model.dart';
import '../models/driver_referral_summary_model.dart';

abstract class DriverReferralDataSource {
  Future<Either<Failure, DriverReferralSummaryModel>> getSummary();

  Future<Either<Failure, DriverReferralHistoryModel>> getHistory({
    int page = 1,
    int limit = 20,
  });
}

class DriverReferralDataSourceImpl implements DriverReferralDataSource {
  final ApiService apiService = locator<ApiService>();

  @override
  Future<Either<Failure, DriverReferralSummaryModel>> getSummary() async {
    return handleNetworkError(() async {
      final res = await apiService.get(ApiEndpoints.driverReferralSummary);

      log("~~res~~~${res.data}");
      return DriverReferralSummaryModel.fromJson(
        res.data as Map<String, dynamic>,
      );
    });
  }

  @override
  Future<Either<Failure, DriverReferralHistoryModel>> getHistory({
    int page = 1,
    int limit = 20,
  }) async {
    return handleNetworkError(() async {
      final res = await apiService.get(
        ApiEndpoints.driverReferralHistory,
        queryParameters: {'page': page, 'limit': limit},
      );

      log("~~res~~~${res.data}");
      return DriverReferralHistoryModel.fromJson(
        res.data as Map<String, dynamic>,
      );
    });
  }
}
