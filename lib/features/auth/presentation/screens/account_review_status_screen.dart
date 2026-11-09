import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/constants_data.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/navigation/routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/shared.dart';

enum AccountReviewStatus { underReview, notApproved, approved }

class AccountReviewStatusArgs {
  const AccountReviewStatusArgs({
    this.status = AccountReviewStatus.underReview,
  });

  final AccountReviewStatus status;
}

class AccountReviewStatusScreen extends StatelessWidget {
  const AccountReviewStatusScreen({
    super.key,
    this.args = const AccountReviewStatusArgs(),
  });

  final AccountReviewStatusArgs args;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.appColors;
    final isNotApproved = args.status == AccountReviewStatus.notApproved;
    final portalUrl = remoteConfigModel.websiteURL;

    return AppScaffold(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => context.goNamed(Routes.login.name),
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 2),

          _StatusIcon(status: args.status),

          const SizedBox(height: AppSizes.p24),

          Text(
            isNotApproved
                ? l10n.account_not_approved_title
                : l10n.account_under_review_title,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineSmall?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: AppSizes.p12),

          Text(
            isNotApproved
                ? l10n.account_not_approved_message
                : l10n.account_under_review_message,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
              height: 1.3,
            ),
          ),

          if (isNotApproved) ...[
            const SizedBox(height: AppSizes.p16),
            Text(
              l10n.reapply_at_label,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSizes.p8),
            Text(
              portalUrl,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.link,
                // decoration: TextDecoration.underline,
              ),
            ),
            const Spacer(flex: 5),
          ] else ...[
            const Spacer(flex: 3),
            Text(
              l10n.account_review_notify_message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: AppSizes.p12),
            Text(
              l10n.updates_visit_label,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSizes.p8),
            Text(
              portalUrl,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.link,
                // decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: AppSizes.p20),
          ],
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final AccountReviewStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == AccountReviewStatus.notApproved) {
      return Center(
        child: Container(
          height: 76,
          width: 76,
          decoration: BoxDecoration(
            color: const Color(0xFFFF3B3B),
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
          child: const Icon(Icons.close_rounded, color: Colors.black, size: 44),
        ),
      );
    }

    return const Center(
      child: Icon(
        Icons.warning_amber_rounded,
        color: Color(0xFFFFC533),
        size: 74,
      ),
    );
  }
}
