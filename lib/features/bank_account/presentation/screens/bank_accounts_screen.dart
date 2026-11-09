import 'package:driver_app/core/constants/app_icons.dart';
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/navigation/routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/custom_dialogue.dart';
import '../../../../shared/entity/bank_entity.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../../../wallet/presentation/states/wallet_states.dart';
import '../providers/bank_account_provider.dart';
import '../states/bank_account_state.dart';

class BankAccountsScreen extends ConsumerStatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  ConsumerState<BankAccountsScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends ConsumerState<BankAccountsScreen>
    with WidgetsBindingObserver {
  bool _isBootstrapping = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final bankAccountNotifier = ref.read(bankAccountProvider.notifier);
    final walletNotifier = ref.read(walletProvider.notifier);
    final walletBanks = ref.read(walletProvider).banks;

    Future.microtask(() async {
      await bankAccountNotifier.initialize(initialBanks: walletBanks);
      if (!mounted) return;

      if (walletBanks.isEmpty) {
        await walletNotifier.fetchBanks();
        if (!mounted) return;
      }

      setState(() => _isBootstrapping = false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // Refresh wallet data when returning to app (e.g., after Stripe setup)
      await ref.read(bankAccountProvider.notifier).initialize();
    }
  }

  Future<void> _deleteBank(BankEntity bank) async {
    final l10 = context.l10n;
    final account = bank.accountNumber.trim();
    final last4 = account.length <= 4
        ? account
        : account.substring(account.length - 4);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => CustomDialogue(
        title: l10.delete_bank_account,
        subtitle: l10.bank_delete_confirmation(
          bank.bankTitle.trim().isEmpty ? l10.bank_account : bank.bankTitle,
          last4,
        ),
        buttons: [
          AppButton(onPressed: () => (context).pop(false), text: l10.cancel),
          AppButton(onPressed: () => (context).pop(true), text: l10.delete),
        ],
      ),
    );

    if (confirmed != true) return;

    final bankAccountNotifier = ref.read(bankAccountProvider.notifier);
    final walletNotifier = ref.read(walletProvider.notifier);
    final deleted = await bankAccountNotifier.deleteBankAccount(bank.bankId);
    if (!mounted) return;

    if (deleted) {
      await walletNotifier.fetchBanks();
      if (!mounted) return;
      await walletNotifier.fetchWalletData(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10 = context.l10n;
    final colors = context.appColors;
    final bankAccountNotifier = ref.read(bankAccountProvider.notifier);

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
      }
    });
    ref.listen<String?>(walletProvider.select((s) => s.setupUrl), (
      prev,
      next,
    ) async {
      if (next != null && next.isNotEmpty && prev != next) {
        Future.microtask(() async {
          try {
            final uri = Uri.parse(next);
            // Clear the URL from state to prevent repeated launches

            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              if (mounted) {
                // ignore: use_build_context_synchronously
                context.showErrorToast("Could not launch setup browser");
              }
            }
          } catch (e) {
            if (mounted) {
              // ignore: use_build_context_synchronously
              context.showErrorToast("Invalid setup URL: $e");
            }
          }
        });
      }
    });
    final state = ref.watch(bankAccountProvider);
    final walletState = ref.watch(walletProvider);
    final banks = state.banks.isNotEmpty ? state.banks : walletState.banks;
    final isLoadingAction = _isBootstrapping || state.isLoadingBanks;

    return AppScaffold(
      floatingActionButtonLocation: banks.isEmpty
          ? FloatingActionButtonLocation.centerFloat
          : FloatingActionButtonLocation.endFloat,
      floatingActionButton: isLoadingAction
          ? null
          : banks.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
              child: AppButton(
                text: l10.attach_bank_account,
                isDisable: walletState.operation == WalletOperation.attachBank,
                onPressed: walletState.operation == WalletOperation.attachBank
                    ? null
                    : () async {
                        await ref
                            .read(walletProvider.notifier)
                            .setupBankAccount();
                      },
                height: 40,
                child: walletState.operation == WalletOperation.attachBank
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
            ).animate().fade(duration: 300.ms).slideY(begin: 0.2, end: 0)
          : FloatingActionButton(
              backgroundColor: colors.brand,
              shape: const CircleBorder(), // ✅ force circle
              child: Icon(Icons.add_rounded),
              onPressed: () => context.pushNamed(Routes.addBankAccount.name),
            ),
      padding: const EdgeInsets.all(20),
      appBar: AppBar(title: Text(l10.bank_account)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10.attached_bank_accounts,
                style: Theme.of(context).textTheme.titleMedium,
              ).animate().fade(duration: 300.ms).slideY(begin: 0.2, end: 0),

              const Spacer(),
              IconButton(
                onPressed: state.isLoadingBanks
                    ? null
                    : () => bankAccountNotifier.fetchBanks(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const Gap(8),
          Expanded(
            child: state.isLoadingBanks && banks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : banks.isEmpty
                ? Center(child: Text(l10.bank_acc))
                : ListView.separated(
                    itemCount: banks.length,
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (context, index) =>
                        const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final bank = banks[index];
                      final isDeleting = state.deletingBankId == bank.bankId;
                      final account = bank.accountNumber.trim();
                      final last4 = account.length <= 4
                          ? account
                          : account.substring(account.length - 4);
                      return AppGradientBox(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          leading: CircleAvatar(
                            radius: context.screenWidth * 0.05,
                            child: const Icon(Icons.account_balance),
                          ),
                          title:
                              Text(
                                    bank.bankTitle.trim().isNotEmpty
                                        ? bank.bankTitle
                                        : l10.bank_account,
                                  )
                                  .animate()
                                  .fade(duration: 300.ms)
                                  .slideY(begin: 0.2, end: 0),
                          subtitle: Text(
                            '${bank.accountHolderName} - ****$last4',
                          ),
                          trailing: bank.selected
                              ? null
                              : isDeleting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : IconButton(
                                  onPressed: () => _deleteBank(bank),
                                  icon: Image.asset(
                                    AppIcons.trash,
                                    height: context.screenWidth * 0.05,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
