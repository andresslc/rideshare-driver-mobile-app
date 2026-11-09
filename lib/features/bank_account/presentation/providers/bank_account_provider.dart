import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../shared/entity/bank_entity.dart';
import '../../domain/entities/bank_account_form_entity.dart';
import '../../domain/usecases/attach_bank_account_usecase.dart';
import '../../domain/usecases/delete_bank_account_usecase.dart';
import '../../domain/usecases/get_bank_accounts_usecase.dart';
import '../states/bank_account_state.dart';

final bankAccountProvider =
    StateNotifierProvider.autoDispose<BankAccountNotifier, BankAccountState>((
      ref,
    ) {
      return BankAccountNotifier(
        attachBankAccountUseCase: locator<AttachBankAccountUseCase>(),
        getBankAccountsUseCase: locator<GetBankAccountsUseCase>(),
        deleteBankAccountUseCase: locator<DeleteBankAccountUseCase>(),
      );
    });

class BankAccountNotifier extends StateNotifier<BankAccountState> {
  final AttachBankAccountUseCase _attachBankAccountUseCase;
  final GetBankAccountsUseCase _getBankAccountsUseCase;
  final DeleteBankAccountUseCase _deleteBankAccountUseCase;

  BankAccountNotifier({
    required AttachBankAccountUseCase attachBankAccountUseCase,
    required GetBankAccountsUseCase getBankAccountsUseCase,
    required DeleteBankAccountUseCase deleteBankAccountUseCase,
  }) : _attachBankAccountUseCase = attachBankAccountUseCase,
       _getBankAccountsUseCase = getBankAccountsUseCase,
       _deleteBankAccountUseCase = deleteBankAccountUseCase,
       super(const BankAccountState());

  Future<void> initialize({List<BankEntity> initialBanks = const []}) async {
    if (state.banks.isNotEmpty) return;
    if (initialBanks.isNotEmpty) {
      state = state.copyWith(banks: initialBanks);
      return;
    }
    await fetchBanks();
  }

  Future<void> fetchBanks() async {
    state = state.copyWith(
      isLoadingBanks: true,
      errorMessage: null,
      successMessage: null,
      successType: null,
    );

    final result = await _getBankAccountsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingBanks: false,
          errorMessage: failure.message,
        );
      },
      (banks) {
        state = state.copyWith(isLoadingBanks: false, banks: banks);
      },
    );
  }

  Future<bool> attachBankAccount(BankAccountFormEntity params) async {
    if (state.isAttaching) return false;

    state = state.copyWith(
      isAttaching: true,
      errorMessage: null,
      successMessage: null,
      successType: null,
      attachedToken: null,
    );

    final result = await _attachBankAccountUseCase(params);

    final isSuccess = result.fold(
      (failure) {
        state = state.copyWith(
          isAttaching: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (token) {
        state = state.copyWith(
          isAttaching: false,
          attachedToken: token,
          successMessage: null,
          successType: BankAccountSuccessType.attached,
        );
        return true;
      },
    );

    if (isSuccess) {
      await fetchBanks();
    }
    return isSuccess;
  }

  Future<bool> deleteBankAccount(String bankId) async {
    if (state.deletingBankId != null) return false;

    state = state.copyWith(
      deletingBankId: bankId,
      errorMessage: null,
      successMessage: null,
      successType: null,
    );

    final result = await _deleteBankAccountUseCase(bankId: bankId);

    final isSuccess = result.fold(
      (failure) {
        state = state.copyWith(
          deletingBankId: null,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          deletingBankId: null,
          successMessage: null,
          successType: BankAccountSuccessType.deleted,
        );
        return true;
      },
    );

    if (isSuccess) {
      await fetchBanks();
    }
    return isSuccess;
  }

  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
      successType: null,
    );
  }
}
