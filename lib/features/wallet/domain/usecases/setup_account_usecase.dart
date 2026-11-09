import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/setup_account_url_entity.dart';
import '../repositories/wallet_repository.dart';

class SetupAccountUseCase {
  final WalletRepository repository;

  SetupAccountUseCase(this.repository);

  Future<Either<Failure, SetupAccountUrlEntity>> call() {
    return repository.setupAccount();
  }
}
