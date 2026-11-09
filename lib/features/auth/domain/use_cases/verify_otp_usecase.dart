import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/params/auth_params.dart';
import '../entities/auth_user_entity.dart';
import '../repositories/auth_repositories.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, AuthResponseEntity>> call(
    VerifyOtpParams params,
  ) async {
    return await repository.verifyOtp(params: params);
  }
}
