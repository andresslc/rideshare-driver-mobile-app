import '../../../../shared/entity/bank_entity.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/bank_account_form_entity.dart';

abstract class BankAccountRepository {
  FutureEither<String> collectBankToken({
    required BankAccountFormEntity params,
  });

  FutureEither<String> attachBankToken({required String token});

  FutureEither<List<BankEntity>> getBanks();

  FutureEither<String> deleteBank({required String bankId});
}
