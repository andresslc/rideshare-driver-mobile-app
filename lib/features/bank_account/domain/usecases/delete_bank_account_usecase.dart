import '../../../../core/utils/typedefs.dart';
import '../repositories/bank_account_repository.dart';

class DeleteBankAccountUseCase {
  final BankAccountRepository _repository;

  DeleteBankAccountUseCase(this._repository);

  FutureEither<String> call({required String bankId}) {
    return _repository.deleteBank(bankId: bankId);
  }
}
