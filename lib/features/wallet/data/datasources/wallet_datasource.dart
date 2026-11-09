import 'package:driver_app/core/extensions/strings_extensions.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/services/api_service.dart';
import '../../../../shared/model/bank_model.dart';
import '../../../../core/utils/app_log.dart';
import '../../../../shared/model/api_response_model.dart';
import '../../domain/entities/setup_account_url_entity.dart';
import '../models/setup_account_url_model.dart';
import '../models/wallet_response_model.dart';

abstract class WalletDataSource {
  Future<Either<Failure, WalletResponseModel>> getTransactionHistory({
    int page = 1,
    int limit = 20,
    String? type,
  });
  Future<Either<Failure, SetupAccountUrlEntity>> setupAccount();
  Future<Either<Failure, List<BankModel>>> getBankList();
  Future<Either<Failure, String>> withdraw({
    required double amount,
    required String bankId,
  });
}

class WalletDataSourceImpl implements WalletDataSource {
  final ApiService apiService = locator<ApiService>();

  @override
  Future<Either<Failure, WalletResponseModel>> getTransactionHistory({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    return handleNetworkError(() async {
      final res = await apiService.get(
        ApiEndpoints.transactionHistory,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (type != null && type != 'all') 'type': type.capitalised,
        },
      );
      final WalletResponseModel response = WalletResponseModel.fromJson(
        res.data as Map<String, dynamic>,
      );

      log("~~res~~~${res.data}");
      return response;
    });
  }

  @override
  Future<Either<Failure, SetupAccountUrlEntity>> setupAccount() async {
    return handleNetworkError(() async {
      final res = await apiService.get(ApiEndpoints.setupAccount);
      return SetupAccountUrlModel.fromResponse(
        res.data as Map<String, dynamic>,
      );
    });
  }

  @override
  Future<Either<Failure, List<BankModel>>> getBankList() async {
    return handleNetworkError(() async {
      final res = await apiService.get(ApiEndpoints.banksList);
      final banks = (res.data['data']['banks'] as List)
          .map((e) => BankModel.fromJson(e as Map<String, dynamic>))
          .toList();

      log("~~res~~~${res.data}");
      return banks;
    });
  }

  @override
  Future<Either<Failure, String>> withdraw({
    required double amount,
    required String bankId,
  }) {
    return handleNetworkError(() async {
      final res = await apiService.post(
        ApiEndpoints.withdraw,
        data: {'amount': amount, 'bankId': bankId},
      );

      final ApiResponse response = ApiResponse.fromMap(res.data);

      return response.message ?? 'Withdrawal request sent successfully';
    });
  }
}
