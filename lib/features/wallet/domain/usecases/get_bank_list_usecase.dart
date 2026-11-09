import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../shared/entity/bank_entity.dart';
import '../repositories/wallet_repository.dart';

class GetBankListUseCase {
  final WalletRepository repository;

  GetBankListUseCase(this.repository);

  Future<Either<Failure, List<BankEntity>>> call() {
    return repository.getBankList();
  }
}
