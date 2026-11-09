import 'package:driver_app/core/core.dart';
import 'package:driver_app/features/wallet/presentation/states/wallet_states.dart';
import 'package:driver_app/shared/widgets/app_gradient_overlay_dropdown.dart';
import 'package:driver_app/shared/widgets/bottom_sheets/draggable_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/wallet_provider.dart';

void openWithdrawBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true, // ✅ important
    isDismissible: true,
    enableDrag: true,
    barrierColor: Colors.black.withOpacity(0.3), // ✅ MUST add
    backgroundColor: Colors.transparent,
    builder: (context) => const WithdrawBottomSheetContent(),
  );
}

class WithdrawBottomSheetContent extends ConsumerStatefulWidget {
  const WithdrawBottomSheetContent({super.key});

  @override
  ConsumerState<WithdrawBottomSheetContent> createState() =>
      _WithdrawBottomSheetContentState();
}

class _WithdrawBottomSheetContentState
    extends ConsumerState<WithdrawBottomSheetContent> {
  static const int _amountMaxLength = 10;

  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  String? _selectedBankId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(walletProvider.notifier).fetchBanks());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  Future<void> _withdraw() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = double.tryParse(_amountController.text);

    await ref
        .read(walletProvider.notifier)
        .withdraw(amount: amount!, bankId: _selectedBankId ?? "");
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final l10n = AppLocalizations.of(context)!;
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    ref.listen<WalletOperation>(walletProvider.select((s) => s.operation), (
      prev,
      next,
    ) {
      if (prev == WalletOperation.withdraw && next == WalletOperation.none) {
        context.pop();
      }
    });

    return DraggableSheetWidget(
      heightFactor: 0.9,
      sizeToChild: true,
      isButtonAvailable: false,
      expandOnFocusNodes: [_amountFocusNode],

      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Text(
                l10n.withdraw_funds,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: AppSizes.p20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.p20),

              /// Bank Selection
              if (walletState.operation == WalletOperation.loadBanks &&
                  walletState.banks.isEmpty)
                Center(
                  child: const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (walletState.banks.isEmpty)
                Text(l10n.no_bank_accounts_found)
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.attached_bank_accounts,
                      style: context.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSizes.p8),
                    AppGradientOverlayDropdown<String>(
                      selected: _selectedBankId,
                      placeholder: l10n.select_bank,
                      expandTriggerWidth: true,
                      items: walletState.banks
                          .map(
                            (bank) => GradientDropdownItem<String>(
                              value: bank.id,
                              label:
                                  '${bank.accountHolderName} (****${bank.accountNumber})',
                            ),
                          )
                          .toList(),
                      onSelected: (id) => setState(() => _selectedBankId = id),
                    ),
                  ],
                ),
              const SizedBox(height: AppSizes.p16),

              /// Balance
              Row(
                children: [
                  Text(
                    l10n.available_balance,
                    style: context.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Text(
                    "\$${walletState.totalBalance.toStringAsFixed(2)}",
                    style: context.textTheme.titleMedium,
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.p20),
              Text(l10n.enter_amount, style: context.textTheme.titleSmall),
              const SizedBox(height: AppSizes.p8),

              /// Amount input
              AppTextField(
                maxLength: _amountMaxLength,
                focusNode: _amountFocusNode,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                controller: _amountController,
                hintText: l10n.type_amount,
                validator: (value) =>
                    Validators.amountValidator(value, walletState.totalBalance),
              ),
              const SizedBox(height: AppSizes.p8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: AppSizes.p4),
                  Expanded(
                    child: Text(
                      l10n.platform_fee_deducted,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p20),

              /// Confirm button
              AppButton(
                text: walletState.operation == WalletOperation.withdraw
                    ? ""
                    : l10n.withdrawal_now,
                onPressed:
                    walletState.operation == WalletOperation.withdraw ||
                        _selectedBankId == null
                    ? null
                    : () => _withdraw(),
                isDisable:
                    walletState.operation == WalletOperation.withdraw ||
                    _selectedBankId == null,
                child: walletState.operation == WalletOperation.withdraw
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),

              const SizedBox(height: AppSizes.p20),
            ],
          ),
        ),
      ),
    );
  }
}
