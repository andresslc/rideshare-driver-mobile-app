import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/params/auth_params.dart';
import '../entities/auth_user_entity.dart';

/// =======================================
/// AUTH REPOSITORY CONTRACT
/// =======================================
abstract class AuthRepository {
  /// Create new user profile (Signup)
  Future<Either<Failure, String>> sendOtp({required SendOtpParams params});

  /// Verify OTP after signup/login
  Future<Either<Failure, AuthResponseEntity>> verifyOtp({
    required VerifyOtpParams params,
  });

  Future<Either<Failure, String>> logout();
  Future<Either<Failure, bool>> deleteAccount(String otp);
}
