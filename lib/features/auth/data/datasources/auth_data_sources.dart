import 'dart:developer';

import 'package:driver_app/core/services/storage_service.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/params/auth_params.dart';
import '../../../../core/services/api_service.dart';
import '../../../../shared/model/api_response_model.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../models/auth_user_model.dart';

/// ===============================
/// ABSTRACT DATASOURCE
/// ===============================
abstract class AuthDatasource {
  /// Create new user profile (Signup)
  Future<Either<Failure, String>> sendOtp(SendOtpParams params);
  Future<Either<Failure, String>> logout();

  /// Login user with email & password

  /// Verify OTP after signup/login
  Future<Either<Failure, AuthResponseEntity>> verifyOtp(VerifyOtpParams params);

  /// Delete user account
  Future<Either<Failure, bool>> deleteAccount(String otp);
}

/// ===============================
/// IMPLEMENTATION
/// ===============================
class AuthDatasourceImpl implements AuthDatasource {
  final ApiService apiService = locator<ApiService>();
  final StorageService _storageService = locator<StorageService>();

  /// ---------------------------------
  /// LOGIN API CALL
  /// ---------------------------------
  @override
  Future<Either<Failure, String>> sendOtp(SendOtpParams params) {
    return handleNetworkError(() async {
      final res = await apiService.post(
        ApiEndpoints.sendOtp,
        data: params.toJson(),
      );

      final ApiResponse response = ApiResponse.fromMap(res.data);

      return response.message ?? 'Login successful';
    });
  }

  /// ---------------------------------
  /// VERIFY OTP
  /// ---------------------------------
  @override
  Future<Either<Failure, AuthResponseEntity>> verifyOtp(
    VerifyOtpParams params,
  ) {
    return handleNetworkError(() async {
      apiService.setDeviceIds();
      final res = await apiService.post(
        ApiEndpoints.verifyOtp,
        data: params.toJson(),
      );

      final AuthResponseModel response = AuthResponseModel.fromJson(
        res.data as Map<String, dynamic>,
      );
      log("~~res~~~${res.data}");
      apiService.clearDeviceIdsFromHeaders();

      return response;
    });
  }

  /// ---------------------------------
  ///  (LOGOUt)
  /// ---------------------------------
  @override
  Future<Either<Failure, String>> logout() {
    return handleNetworkError(() async {
      final response = await apiService.post(ApiEndpoints.logout);

      final apiResponse = ApiResponse.fromMap(response.data);
      return apiResponse.message ?? '';
    });
  }

  /// DELETE ACCOUNT
  /// ---------------------------------
  @override
  Future<Either<Failure, bool>> deleteAccount(String otp) {
    return handleNetworkError(() async {
      final response = await apiService.post(
        ApiEndpoints.deleteAccount,
        data: {'otp': otp},
      );

      final apiResponse = ApiResponse.fromMap(response.data);

      _storageService.clearAuthSession();
      apiService.clearAuthToken();

      return apiResponse.success;
    });
  }
}
