import 'dart:math' as math;

import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class WalletBalanceCard extends StatefulWidget {
  final double balance;
  final double rewardedBalance;
  final double totalBalance;
  final bool isSilentSyncing;

  const WalletBalanceCard({
    super.key,
    required this.balance,
    required this.rewardedBalance,
    required this.totalBalance,
    this.isSilentSyncing = false,
  });

  @override
  State<WalletBalanceCard> createState() => _WalletBalanceCardState();
}

class _WalletBalanceCardState extends State<WalletBalanceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  double? _silentAnchor;
  bool _settlingAfterSilent = false;

  double get _effectiveTotal => widget.totalBalance > 0
      ? widget.totalBalance
      : (widget.balance + widget.rewardedBalance);

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    if (widget.isSilentSyncing) {
      _silentAnchor = _effectiveTotal;
      _waveController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant WalletBalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSilentSyncing && !oldWidget.isSilentSyncing) {
      _silentAnchor = _effectiveTotal;
      _settlingAfterSilent = false;
      _waveController.repeat(reverse: true);
    }
    if (!widget.isSilentSyncing && oldWidget.isSilentSyncing) {
      _waveController.stop();
      _waveController.reset();
      _settlingAfterSilent = _silentAnchor != null;
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = context.textTheme;
    final amountStyle = textTheme.displayMedium?.copyWith(
      color: context.appColors.brand,
      fontWeight: FontWeight.bold,
    );

    Widget amount;
    if (widget.isSilentSyncing && _silentAnchor != null) {
      amount = AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          final base = _silentAnchor!;
          final amp = math.max(base * 0.0025, 0.02);
          final v = base + amp * math.sin(_waveController.value * 2 * math.pi);
          return Text('\$${v.toStringAsFixed(2)}', style: amountStyle);
        },
      );
    } else if (_settlingAfterSilent && _silentAnchor != null) {
      amount = TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1500),
        curve: Curves.fastOutSlowIn,
        tween: Tween(begin: _silentAnchor!, end: _effectiveTotal),
        onEnd: () {
          if (!mounted) return;
          setState(() {
            _silentAnchor = null;
            _settlingAfterSilent = false;
          });
        },
        builder: (context, value, child) {
          return Text('\$${value.toStringAsFixed(2)}', style: amountStyle);
        },
      );
    } else {
      amount = TweenAnimationBuilder<double>(
        tween: Tween<double>(end: _effectiveTotal),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.fastOutSlowIn,
        builder: (context, value, child) {
          return Text('\$${value.toStringAsFixed(2)}', style: amountStyle);
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, top: 0),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // ignore: deprecated_member_use
            color: context.appColors.textPrimary.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.total_earnings,
              style: textTheme.titleSmall?.copyWith(
                color: context.appColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSizes.p8),
            amount,
            const SizedBox(height: AppSizes.p16),
            Row(
              children: [
                Expanded(
                  child: _BalanceSubCard(
                    title: l10n.regular_balance,
                    amount: widget.balance,
                    icon: Icons.payments_outlined,
                    accentColor: context.appColors.brand,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BalanceSubCard(
                    title: l10n.rewarded_balance,
                    amount: widget.rewardedBalance,
                    icon: Icons.stars_rounded,
                    accentColor: Colors.amber.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceSubCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color accentColor;

  const _BalanceSubCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: accentColor),
              const SizedBox(width: 4),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: textTheme.labelMedium?.copyWith(
                      color: colors.textPrimary.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: amount),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Text(
                  "\$${value.toStringAsFixed(2)}",
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
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
