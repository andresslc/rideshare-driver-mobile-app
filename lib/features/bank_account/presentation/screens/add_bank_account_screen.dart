import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_gradient_overlay_dropdown.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../../domain/entities/bank_account_form_entity.dart';
import '../providers/bank_account_provider.dart';
import '../states/bank_account_state.dart';

class AddBankAccountScreen extends ConsumerStatefulWidget {
  const AddBankAccountScreen({super.key});

  @override
  ConsumerState<AddBankAccountScreen> createState() =>
      _BankAccountScreenState();
}

class _BankAccountScreenState extends ConsumerState<AddBankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _accountHolderNameController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _routingNumberController;
  late final TextEditingController _countryController;
  late final TextEditingController _currencyController;

  BankHolderType _holderType = BankHolderType.individual;
  @override
  void initState() {
    super.initState();

    _accountHolderNameController = TextEditingController();
    _routingNumberController = TextEditingController();
    _accountNumberController = TextEditingController();
    _countryController = TextEditingController(text: 'US');
    _currencyController = TextEditingController(text: 'usd');

    if (kDebugMode) {
      _accountHolderNameController.text = "John Doe";
      _routingNumberController.text = "110000000";
      _accountNumberController.text = "000123456789";
    }
  }

  @override
  void dispose() {
    _accountHolderNameController.dispose();
    _routingNumberController.dispose();
    _accountNumberController.dispose();
    _countryController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String message) {
    if ((value ?? '').trim().isEmpty) return message;
    return null;
  }

  String? _routingValidator(String? value, AppLocalizations l10) {
    final val = (value ?? '').trim();
    if (val.isEmpty) return l10.routing_number_required;
    if (val.length != 9) return l10.routing_number_must_be_9_digits;
    return null;
  }

  String? _accountValidator(String? value, AppLocalizations l10) {
    final val = (value ?? '').trim();
    if (val.isEmpty) return l10.account_number_required;
    if (val.length < 4 || val.length > 17) {
      return l10.account_number_must_be_4_to_17_digits;
    }
    return null;
  }

  Future<void> _attachBankAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final params = BankAccountFormEntity(
      accountHolderName: _accountHolderNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      routingNumber: _routingNumberController.text.trim(),
      country: _countryController.text.trim().toUpperCase(),
      currency: _currencyController.text.trim().toLowerCase(),
      holderType: _holderType,
    );

    final bankAccountNotifier = ref.read(bankAccountProvider.notifier);
    final walletNotifier = ref.read(walletProvider.notifier);

    final attached = await bankAccountNotifier.attachBankAccount(params);
    if (!mounted) return;

    if (attached) {
      await walletNotifier.fetchBanks();
      if (!mounted) return;
      await walletNotifier.fetchWalletData(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10 = context.l10n;
    final bankAccountNotifier = ref.read(bankAccountProvider.notifier);
    final state = ref.watch(bankAccountProvider);

    ref.listen<BankAccountState>(bankAccountProvider, (previous, next) {
      if (!mounted) return;

      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        context.showErrorToast(next.errorMessage ?? l10.bank_attach_failed);
        bankAccountNotifier.clearMessages();
      }

      if (next.successType != null &&
          previous?.successType != next.successType) {
        switch (next.successType!) {
          case BankAccountSuccessType.attached:
            context.showSuccessToast(l10.bank_account_attached_success);
            context.pop();
            break;
          case BankAccountSuccessType.deleted:
            context.showSuccessToast(l10.bank_account_deleted_success);
            break;
        }
        bankAccountNotifier.clearMessages();
      } else if (next.successMessage != null &&
          previous?.successMessage != next.successMessage) {
        context.showSuccessToast(next.successMessage!);
        bankAccountNotifier.clearMessages();
        context.pop();
      }
    });

    return AppScaffold(
      scrollable: true,
      padding: const EdgeInsets.all(20),
      appBar: AppBar(title: Text(l10.attach_bank_account)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10.attach_bank_account_description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Gap(16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _accountHolderNameController,
                  hintText: l10.account_holder_name,
                  validator: (v) =>
                      _requiredValidator(v, l10.account_holder_name_required),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const Gap(10),
                AppTextField(
                  controller: _routingNumberController,
                  hintText: l10.routing_number,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => _routingValidator(v, l10),
                ),
                const Gap(10),
                AppTextField(
                  controller: _accountNumberController,
                  hintText: l10.account_number,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => _accountValidator(v, l10),
                ),
                const Gap(10),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _countryController,
                        hintText: l10.country_us,
                        maxLength: 2,
                        validator: (v) =>
                            _requiredValidator(v, l10.country_required),
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: AppTextField(
                        controller: _currencyController,
                        hintText: l10.currency_usd,
                        maxLength: 3,
                        validator: (v) =>
                            _requiredValidator(v, l10.currency_required),
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                Text(
                  l10.account_holder_type,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Gap(8),
                AppGradientOverlayDropdown<BankHolderType>(
                  selected: _holderType,
                  expandTriggerWidth: true,
                  items: [
                    GradientDropdownItem(
                      value: BankHolderType.individual,
                      label: l10.individual,
                    ),
                    GradientDropdownItem(
                      value: BankHolderType.company,
                      label: l10.company,
                    ),
                  ],
                  onSelected: (value) => setState(() => _holderType = value),
                ),
                const Gap(12),
                AppButton(
                  text: l10.add_bank_account,
                  isDisable: state.isAttaching,
                  onPressed: state.isAttaching ? null : _attachBankAccount,
                  child: state.isAttaching
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
              ],
            ),
          ),
          const Gap(20),
        ],
      ),
    );
  }
}
