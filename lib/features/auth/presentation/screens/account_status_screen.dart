import 'package:driver_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/shared.dart';

class AccountStatusScreen extends StatelessWidget {
  const AccountStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.appColors;
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusIcon(),

          const SizedBox(height: AppSizes.p24),

          Text(
            l10n.account_status_complete_title,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineSmall?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: AppSizes.p12),

          Text(
            l10n.account_status_complete_message,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // if (status == AccountReviewStatus.notApproved) {
    //   return Center(
    //     child: Container(
    //       height: 76,
    //       width: 76,
    //       decoration: BoxDecoration(
    //         color: const Color(0xFFFF3B3B),
    //         borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
    //       ),
    //       child: const Icon(Icons.close_rounded, color: Colors.black, size: 44),
    //     ),
    //   );
    // }

    return Center(
      child: Icon(
        Icons.warning_amber_rounded,
        color: Color(0xFFFFC533),
        size: context.screenWidth * 0.4,
      ),
    );
  }
}
