import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/repositories/auth_repositories.dart';
import '../datasources/auth_data_sources.dart';
import '../../../../core/params/auth_params.dart';

/// Internal repository abstraction
abstract class AuthRepositoryInternal implements AuthRepository {}

/// =======================================
/// IMPLEMENTATION
/// =======================================
class AuthRepositoryImpl implements AuthRepositoryInternal {
  final AuthDatasource dataSource;

  const AuthRepositoryImpl(this.dataSource);

  /// ---------------------------------
  /// CREATE PROFILE (SIGNUP)
  /// ---------------------------------
  @override
  Future<Either<Failure, String>> sendOtp({
    required SendOtpParams params,
  }) async {
    final response = await dataSource.sendOtp(params);

    return response.fold(
      (failure) => Left(ServerFailure(message: failure.message)),
      (message) => Right(message),
    );
  }

  /// ---------------------------------
  /// VERIFY OTP
  /// ---------------------------------
  @override
  Future<Either<Failure, AuthResponseEntity>> verifyOtp({
    required VerifyOtpParams params,
  }) async {
    final response = await dataSource.verifyOtp(params);

    return response.fold(
      (failure) => Left(ServerFailure(message: failure.message)),
      (authResponse) => Right(authResponse),
    );
  }

  /// ---------------------------------
  ///Logout
  /// ---------------------------------
  @override
  Future<Either<Failure, String>> logout() async {
    final response = await dataSource.logout();
    return response.fold(
      (failure) => Left(ServerFailure(message: failure.message)),
      (message) => Right(message),
    );
  }

  @override
  Future<Either<Failure, bool>> deleteAccount(String otp) async {
    final response = await dataSource.deleteAccount(otp);
    return response.fold(
      (failure) => Left(ServerFailure(message: failure.message)),
      (success) => Right(success),
    );
  }
}
