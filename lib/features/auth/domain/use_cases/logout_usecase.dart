import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/features/auth/domain/repositories/auth_repositories.dart';
import 'package:fpdart/fpdart.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, String>> call() async {
    return await repository.logout();
  }
}
