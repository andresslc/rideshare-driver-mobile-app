import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/params/auth_params.dart';
import '../repositories/auth_repositories.dart';

class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<Either<Failure, String>> call(SendOtpParams params) async {
    return await repository.sendOtp(params: params);
  }
}
