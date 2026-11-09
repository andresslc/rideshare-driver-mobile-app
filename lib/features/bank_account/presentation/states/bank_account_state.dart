import '../../../../shared/entity/bank_entity.dart';

enum BankAccountSuccessType { attached, deleted }

class BankAccountState {
  static const _unset = Object();

  final bool isLoadingBanks;
  final bool isAttaching;
  final String? deletingBankId;
  final String? errorMessage;
  final String? successMessage;
  final BankAccountSuccessType? successType;
  final String? attachedToken;
  final List<BankEntity> banks;

  const BankAccountState({
    this.isLoadingBanks = false,
    this.isAttaching = false,
    this.deletingBankId,
    this.errorMessage,
    this.successMessage,
    this.successType,
    this.attachedToken,
    this.banks = const [],
  });

  BankAccountState copyWith({
    bool? isLoadingBanks,
    bool? isAttaching,
    Object? deletingBankId = _unset,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
    Object? successType = _unset,
    Object? attachedToken = _unset,
    List<BankEntity>? banks,
  }) {
    return BankAccountState(
      isLoadingBanks: isLoadingBanks ?? this.isLoadingBanks,
      isAttaching: isAttaching ?? this.isAttaching,
      deletingBankId: identical(deletingBankId, _unset)
          ? this.deletingBankId
          : deletingBankId as String?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
      successType: identical(successType, _unset)
          ? this.successType
          : successType as BankAccountSuccessType?,
      attachedToken: identical(attachedToken, _unset)
          ? this.attachedToken
          : attachedToken as String?,
      banks: banks ?? this.banks,
    );
  }
}
