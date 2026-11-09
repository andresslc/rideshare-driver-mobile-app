import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/extensions/strings_extensions.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../user_profile/presentation/providers/user_profile_provider.dart';
import '../providers/driver_referral_history_provider.dart';
import '../providers/driver_referral_summary_provider.dart';
import '../states/driver_referral_states.dart';
import '../widgets/referral_code_display.dart';
import '../widgets/referral_history_tile.dart';
import '../widgets/referral_message_banner.dart';
import '../widgets/referral_stats_grid.dart';

class DriverReferralScreen extends ConsumerStatefulWidget {
  const DriverReferralScreen({super.key});

  @override
  ConsumerState<DriverReferralScreen> createState() =>
      _DriverReferralScreenState();
}

class _DriverReferralScreenState extends ConsumerState<DriverReferralScreen> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());

    // Stats and history may change while the app is in the background
    // (e.g. a referred rider finished their ride).
    _lifecycleListener = AppLifecycleListener(onResume: _refresh);
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(driverReferralSummaryProvider.notifier).refresh(),
      ref.read(driverReferralHistoryProvider.notifier).refresh(),
    ]);
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.extentAfter < 240) {
      ref.read(driverReferralHistoryProvider.notifier).loadMore();
    }
    return false;
  }

  String _money(double amount) => '\$${amount.toStringAsFixed(2)}';

  Future<void> _copyCode(String code) async {
    await code.copyToClipboard();
    if (!mounted) return;
    context.showToast(context.l10n.referral_code_copied);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summaryState = ref.watch(driverReferralSummaryProvider);
    final historyState = ref.watch(driverReferralHistoryProvider);
    final summary = summaryState.summary;

    // While the summary loads, show the code the profile already returned
    // (`data.driver.referralCode` from `/driver/me`), if any.
    final profileCode = ref.watch(
      userProfileProvider.select((s) => s.profile?.user.referralCode),
    );
    final code = summary?.referralCode ?? profileCode;

    return AppScaffold(
      appBar: AppBar(),
      child: RefreshIndicator.adaptive(
        onRefresh: _refresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              /// 🔹 Header
              SliverToBoxAdapter(
                child:
                    AuthHeader(
                          title: l10n.referral_title,
                          subtitle: summary != null
                              ? l10n.referral_explainer(
                                  _money(summary.driverBonusAmount),
                                )
                              : '',
                        )
                        .animate()
                        .fadeIn(delay: 150.ms, duration: 350.ms)
                        .slideY(begin: 0.15),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              /// 🔹 Read-only code (POP effect)
              SliverToBoxAdapter(
                child: code != null && code.isNotEmpty
                    ? ReferralCodeDisplay(code: code)
                          .animate()
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1, 1),
                            duration: 450.ms,
                            curve: Curves.easeOutBack,
                          )
                          .fadeIn(delay: 200.ms)
                    : const _Skeleton(child: ReferralCodeDisplay(code: '')),
              ),

              /// 🔹 Copy (Share returns with the next store release)
              if (summary != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: l10n.referral_copy_code,
                            backgroundColor: context.appColors.lightButton,
                            fontColor: context.appColors.brand,
                            onPressed: () => _copyCode(summary.referralCode),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),
                ),

              /// 🔹 Response message slot
              SliverToBoxAdapter(
                child: AnimatedSize(
                  duration: 250.ms,
                  curve: Curves.easeOut,
                  child: _buildSummaryMessage(summaryState),
                ),
              ),

              /// 🔹 Stats
              if (summary != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: ReferralStatsGrid(stats: summary.stats),
                  ).animate().fadeIn(delay: 300.ms),
                ),

              /// 🔹 History
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 12),
                  child: Text(
                    l10n.referral_history,
                    style: context.textTheme.titleMedium,
                  ),
                ).animate().fadeIn(delay: 300.ms),
              ),

              ..._buildHistory(historyState),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryMessage(DriverReferralSummaryState state) {
    final l10n = context.l10n;
    final summary = state.summary;

    ReferralMessageBanner? banner;
    if (state.errorMessage != null && !state.isLoading) {
      // The message is the one the API returned, e.g. 400
      // "Your subscription is not active" for a driver without subscription.
      banner = ReferralMessageBanner(
        message: state.errorMessage!,
        type: ReferralMessageType.error,
        actionLabel: l10n.retry,
        onAction: () =>
            ref.read(driverReferralSummaryProvider.notifier).refresh(),
      );
    } else if (summary != null && !summary.enabled) {
      banner = ReferralMessageBanner(
        message: l10n.referral_paused,
        type: ReferralMessageType.warning,
      );
    }

    if (banner == null) return const SizedBox(width: double.infinity);

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: banner.animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
    );
  }

  List<Widget> _buildHistory(DriverReferralHistoryState state) {
    final l10n = context.l10n;

    // First load: skeleton tiles.
    if (state.isLoading && state.items.isEmpty) {
      return [
        SliverList.separated(
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, _) => const _Skeleton(child: _TileSkeleton()),
        ),
      ];
    }

    // Error with nothing to show.
    if (state.errorMessage != null && state.items.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: ReferralMessageBanner(
            message: state.errorMessage!,
            type: ReferralMessageType.error,
            actionLabel: l10n.retry,
            onAction: () =>
                ref.read(driverReferralHistoryProvider.notifier).refresh(),
          ),
        ),
      ];
    }

    if (state.items.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: AppEmptyWidget(
            message: l10n.invite_friends,
            icon: Icons.person,
          ),
        ),
      ];
    }

    return [
      SliverList.separated(
        itemCount: state.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            ReferralHistoryTile(item: state.items[index])
                .animate()
                .fadeIn(delay: (40 * (index % 10)).ms, duration: 250.ms)
                .slideY(begin: 0.08),
      ),

      // Bottom loader / inline error while paginating.
      if (state.isLoadingMore)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: context.appColors.brand,
              ),
            ),
          ),
        )
      else if (state.errorMessage != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ReferralMessageBanner(
              message: state.errorMessage!,
              type: ReferralMessageType.error,
              actionLabel: l10n.retry,
              onAction: () =>
                  ref.read(driverReferralHistoryProvider.notifier).loadMore(),
            ),
          ),
        ),
    ];
  }
}

/// Shimmer wrapper using the same colors as the wallet skeleton.
class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
      child: child,
    );
  }
}

class _TileSkeleton extends StatelessWidget {
  const _TileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
