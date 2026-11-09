import '../../../../core/utils/typedefs.dart';
import '../../../../shared/entity/bank_entity.dart';
import '../repositories/bank_account_repository.dart';

class GetBankAccountsUseCase {
  final BankAccountRepository _repository;

  GetBankAccountsUseCase(this._repository);

  FutureEither<List<BankEntity>> call() {
    return _repository.getBanks();
  }
}
