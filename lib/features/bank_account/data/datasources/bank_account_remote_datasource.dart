import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/model/api_response_model.dart';
import '../../../../shared/model/bank_model.dart';
import '../../../../shared/entity/bank_entity.dart';

abstract class BankAccountRemoteDataSource {
  FutureEither<String> attachBankToken({required String token});

  FutureEither<List<BankEntity>> getBanks();

  FutureEither<String> deleteBank({required String bankId});
}

class BankAccountRemoteDataSourceImpl implements BankAccountRemoteDataSource {
  final ApiService _apiService;

  BankAccountRemoteDataSourceImpl(this._apiService);

  @override
  FutureEither<String> attachBankToken({required String token}) async {
    return handleNetworkError(() async {
      final res = await _apiService.post(
        ApiEndpoints.attachBankAccount,
        data: <String, dynamic>{'token': token},
      );

      final ApiResponse response = ApiResponse.fromMap(res.data);

      return response.message ?? '';
    });
    // final response = await _apiService.post(
    //   ApiEndpoints.attachBankAccount,
    //   data: <String, dynamic>{'token': token},
    // );

    // final body =
    //     (response.data as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    // final success = body['success'];

    // if (success is bool && !success) {
    //   throw Exception(
    //     body['message'] as String? ?? 'Unable to attach bank account.',
    //   );
    // }
  }

  @override
  FutureEither<List<BankEntity>> getBanks() async {
    // final response = await _apiService.get(ApiEndpoints.banksList);
    // final body =
    //     (response.data as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

    // final data =
    //     (body['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    // final banksRaw = data['banks'];
    // if (banksRaw is! List) {
    //   return const <BankEntity>[];
    // }

    // return banksRaw
    //     .whereType<Map>()
    //     .map<BankEntity>((e) => BankModel.fromJson(e.cast<String, dynamic>()))
    //     .toList();
    return handleNetworkError(() async {
      final res = await _apiService.get(ApiEndpoints.banksList);
      final ApiResponse response = ApiResponse.fromMap(res.data);

      final data =
          (response.data as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      final banksRaw = data['banks'];
      if (banksRaw is! List) {
        return const <BankEntity>[];
      }
      return (banksRaw)
          .whereType<Map>()
          .map<BankEntity>((e) => BankModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    });
  }

  @override
  FutureEither<String> deleteBank({required String bankId}) async {
    return handleNetworkError(() async {
      final res = await _apiService.delete(
        ApiEndpoints.deleteBankAccount,
        data: <String, dynamic>{'bankId': bankId},
      );
      final ApiResponse response = ApiResponse.fromMap(res.data);

      return response.message ?? '';
    });
    //   Response response;
    //   try {
    // response = await _apiService.delete(
    //   ApiEndpoints.deleteBankAccount,
    //   data: <String, dynamic>{'bankId': bankId},
    // );
    //   } on DioException catch (e) {
    //     final statusCode = e.response?.statusCode ?? 0;
    //     if (statusCode == 404 || statusCode == 405) {
    //       // Fallback for backends using POST for delete operations.
    //       response = await _apiService.post(
    //         ApiEndpoints.deleteBankAccount,
    //         data: <String, dynamic>{'bankId': bankId},
    //       );
    //     } else {
    //       rethrow;
    //     }
    //   }

    //   final body =
    //       (response.data as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    //   final success = body['success'];

    //   if (success is bool && !success) {
    //     throw Exception(body['message'] as String? ?? 'Unable to delete bank.');
    //   }
  }
}
