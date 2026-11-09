import 'package:driver_app/features/wallet/presentation/states/wallet_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/wallet_provider.dart';
import '../widgets/transaction_filter.dart';
import '../widgets/transaction_header.dart';
import '../widgets/transaction_list.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/withdraw_bottom_sheet.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../core/extensions/context_extension.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with WidgetsBindingObserver {
  late final ProviderSubscription<WalletState> _walletListener;
  String? _pendingFilterChange;

  WalletNotifier get _walletNotifier => ref.read(walletProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _walletListener = ref.listenManual(
      walletProvider,
      _handleWalletStateChange,
    );
    _scheduleInitialFetch();
  }

  @override
  void dispose() {
    _walletListener.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _scheduleInitialFetch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshTransactions();
    });
  }

  void _handleWalletStateChange(WalletState? previous, WalletState next) {
    if (!mounted) return;

    if (next.operation == WalletOperation.attachBank &&
        previous?.operation != WalletOperation.attachBank) {
      context.showLoader();
    }

    if (previous?.operation == WalletOperation.attachBank &&
        next.operation != WalletOperation.attachBank) {
      context.hideLoader();
    }

    if ((next.errorMessage?.isNotEmpty ?? false) &&
        previous?.errorMessage != next.errorMessage) {
      context.showErrorToast(next.errorMessage!);
    }

    if ((next.withdrawalSuccess?.isNotEmpty ?? false) &&
        previous?.withdrawalSuccess != next.withdrawalSuccess) {
      context.showSuccessToast(next.withdrawalSuccess!);
    }

    if ((next.setupUrl?.isNotEmpty ?? false) &&
        previous?.setupUrl != next.setupUrl) {
      _launchSetupUrl(next.setupUrl!);
    }

    if (_pendingFilterChange != null &&
        next.selectedCategory == _pendingFilterChange &&
        next.operation != WalletOperation.loadWallet &&
        next.operation != WalletOperation.silentSyncWallet) {
      setState(() => _pendingFilterChange = null);
    }
  }

  Future<void> _launchSetupUrl(String url) async {
    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        context.showErrorToast("Could not launch setup browser");
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast("Invalid setup URL: $e");
      }
    }
  }

  Future<void> _refreshTransactions() {
    return _walletNotifier.fetchWalletData(
      refresh: true,
      type: ref.read(walletProvider).selectedCategory,
    );
  }

  void _loadMoreTransactions() {
    _walletNotifier.fetchWalletData(
      type: ref.read(walletProvider).selectedCategory,
    );
  }

  void _updateFilter(String filter) {
    final normalizedFilter = filter.toLowerCase();
    if (normalizedFilter == ref.read(walletProvider).selectedCategory) return;

    setState(() => _pendingFilterChange = normalizedFilter);
    _walletNotifier.fetchWalletData(refresh: true, type: normalizedFilter);
  }

  Future<void> _handlePrimaryAction(WalletState state) async {
    if (state.operation == WalletOperation.withdraw) return;

    if (state.bankStatus == BankStatus.attached) {
      openWithdrawBottomSheet(context);
      return;
    }

    await _walletNotifier.setupBankAccount();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      // padding: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(0),
      scrollable: false,
      appBar: AppBar(
        title: Text(
          l10n.wallet,
        ).animate().fade(duration: 300.ms).slideY(begin: 0.2, end: 0),
        centerTitle: true,
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 4, right: 4),
        child: _WalletScreenContent(
          state: walletState,
          l10n: l10n,
          isFilterChanging:
              _pendingFilterChange != null &&
              walletState.operation == WalletOperation.loadWallet &&
              walletState.transactions.isNotEmpty &&
              walletState.selectedCategory == _pendingFilterChange,
          onPrimaryAction: () {
            _handlePrimaryAction(walletState);
          },
          onFilterChanged: _updateFilter,
          onRefresh: _refreshTransactions,
          onLoadMore: _loadMoreTransactions,
        ),
      ),
      // .animate().fade(duration: 300.ms).slideY(begin: 0.2, end: 0),
    );
  }
}

class _WalletScreenContent extends StatelessWidget {
  const _WalletScreenContent({
    required this.state,
    required this.l10n,
    required this.isFilterChanging,
    required this.onPrimaryAction,
    required this.onFilterChanged,
    required this.onRefresh,
    required this.onLoadMore,
  });

  final WalletState state;
  final AppLocalizations l10n;
  final bool isFilterChanging;
  final VoidCallback onPrimaryAction;
  final ValueChanged<String> onFilterChanged;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WalletBalanceCard(
          balance: state.balance,
          rewardedBalance: state.rewardedBalance,
          totalBalance: state.totalBalance,
          isSilentSyncing: state.operation == WalletOperation.silentSyncWallet,
        ).animate().fade(duration: 300.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: AppSizes.p12),
        _WalletPrimaryActionButton(
          state: state,
          l10n: l10n,
          onPressed: onPrimaryAction,
        ),
        const Gap(20),
        TransactionFilterHeader(
          selectedCategory: state.selectedCategory,
          onChanged: onFilterChanged,
        ).animate().fade(delay: 150.ms).slideX(begin: -0.2, end: 0),
        const Gap(20),
        const TransactionHeader()
            .animate()
            .fade(delay: 200.ms)
            .slideY(begin: 0.2, end: 0),
        const Gap(20),
        Expanded(
          child: _WalletTransactionSection(
            state: state,
            l10n: l10n,
            isFilterChanging: isFilterChanging,
            onRefresh: onRefresh,
            onLoadMore: onLoadMore,
          ).animate().fade(delay: 250.ms),
        ),
      ],
    );
  }
}

class _WalletPrimaryActionButton extends StatelessWidget {
  const _WalletPrimaryActionButton({
    required this.state,
    required this.l10n,
    required this.onPressed,
  });

  final WalletState state;
  final AppLocalizations l10n;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: AppButton(
        isDisable: state.bankStatus == BankStatus.none,
        text: state.bankStatus == BankStatus.none
            ? ""
            : state.bankStatus == BankStatus.attached
            ? l10n.withdrawal_now
            : l10n.attach_bank_account,
        onPressed: onPressed,
        height: 40,
        child: state.bankStatus == BankStatus.none
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
      ).animate().fade(delay: 100.ms).slideY(begin: 0.2, end: 0),
    );
  }
}

class _WalletTransactionSection extends StatelessWidget {
  const _WalletTransactionSection({
    required this.state,
    required this.l10n,
    required this.isFilterChanging,
    required this.onRefresh,
    required this.onLoadMore,
  });

  final WalletState state;
  final AppLocalizations l10n;
  final bool isFilterChanging;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (state.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasInitialError) {
      return _WalletStatusPane(
        message: state.errorMessage ?? l10n.something_went_wrong,
        actionLabel: l10n.retry,
        onAction: onRefresh,
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: onRefresh,
          child: TransactionList(
            key: ValueKey(state.selectedCategory),
            transactions: state.transactions,
            onLoadMore: onLoadMore,
            isFetchingMore: state.isLoadingMore,
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isFilterChanging,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: isFilterChanging
                  ? const _WalletFilterLoadingOverlay()
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}

class _WalletFilterLoadingOverlay extends StatelessWidget {
  const _WalletFilterLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade100;

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Column(
            children: List.generate(5, (_) => const _WalletFilterLoadingRow()),
          ),
        ),
      ),
    );
  }
}

class _WalletFilterLoadingRow extends StatelessWidget {
  const _WalletFilterLoadingRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: const [
              _WalletFilterLoadingCell(
                flex: 2,
                alignment: Alignment.centerLeft,
              ),
              Gap(12),
              _WalletFilterLoadingCell(flex: 3, alignment: Alignment.center),
              Gap(12),
              _WalletFilterLoadingCell(flex: 2, alignment: Alignment.center),
              Gap(12),
              _WalletFilterLoadingCell(flex: 2, alignment: Alignment.center),
              Gap(12),
              _WalletFilterLoadingCell(
                flex: 2,
                alignment: Alignment.centerRight,
              ),
            ],
          ),
        ),
        const Divider(thickness: 1, height: 1),
      ],
    );
  }
}

class _WalletFilterLoadingCell extends StatelessWidget {
  const _WalletFilterLoadingCell({required this.flex, required this.alignment});

  final int flex;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignment,
        child: Container(
          height: 16,
          // width: 12,
          constraints: const BoxConstraints(maxWidth: 90),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _WalletStatusPane extends StatelessWidget {
  const _WalletStatusPane({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const Gap(12),
            TextButton(
              onPressed: () {
                onAction();
              },
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

extension on WalletState {
  bool get isInitialLoading =>
      operation == WalletOperation.loadWallet && transactions.isEmpty;

  bool get hasInitialError =>
      operation != WalletOperation.loadWallet &&
      transactions.isEmpty &&
      (errorMessage?.isNotEmpty ?? false);

  bool get isLoadingMore => operation == WalletOperation.loadMore;
}
