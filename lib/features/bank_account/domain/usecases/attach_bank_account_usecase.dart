import 'package:fpdart/fpdart.dart';

import '../../../../core/utils/typedefs.dart';
import '../entities/bank_account_form_entity.dart';
import '../repositories/bank_account_repository.dart';

class AttachBankAccountUseCase {
  final BankAccountRepository _repository;

  AttachBankAccountUseCase(this._repository);

  FutureEither<String> call(BankAccountFormEntity params) async {
    final tokenResult = await _repository.collectBankToken(params: params);

    return tokenResult.fold((failure) async => Left(failure), (token) async {
      final attachResult = await _repository.attachBankToken(token: token);

      return attachResult.fold((failure) => Left(failure), (_) => Right(token));
    });
  }
}
