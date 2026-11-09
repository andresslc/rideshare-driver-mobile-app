import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/wallet_repository.dart';

class WithdrawFundsUseCase {
  final WalletRepository repository;

  WithdrawFundsUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required double amount,
    required String bankId,
  }) {
    return repository.withdraw(amount: amount, bankId: bankId);
  }
}
