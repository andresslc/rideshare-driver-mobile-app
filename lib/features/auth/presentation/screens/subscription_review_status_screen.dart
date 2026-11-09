import 'package:driver_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/strings_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/shared.dart';

class SubcriptionReviewStatusScreen extends StatefulWidget {
  const SubcriptionReviewStatusScreen({super.key, required this.status});

  final String? status;

  @override
  State<SubcriptionReviewStatusScreen> createState() =>
      _SubcriptionReviewStatusScreenState();
}

class _SubcriptionReviewStatusScreenState
    extends State<SubcriptionReviewStatusScreen> {
  void onLougout() {
    // locator<StorageService>().clearAuthSession();
    // locator<ApiService>().clearAuthToken();
    context.clearDriverSession();
    context.goNamed(Routes.login.name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.appColors;

    final bool isApproved = widget.status == null || widget.status!.isEmpty;
    final url = remoteConfigModel.websiteURL;

    return AppScaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: onLougout, icon: Icon(Icons.logout))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 2),

          _StatusIcon(status: widget.status),

          const SizedBox(height: AppSizes.p24),

          /// TITLE
          Text(
            isApproved
                ? l10n.account_approved_title
                : l10n.subscription_status_title,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineSmall?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: AppSizes.p12),

          /// MESSAGE
          Text(
            isApproved
                ? l10n.account_approved_message
                : l10n.subscription_status_message(widget.status ?? ""),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
              height: 1.3,
            ),
          ),

          const SizedBox(height: AppSizes.p16),

          /// WEBSITE SECTION
          Text(
            isApproved ? l10n.subscription_note : l10n.subscription_renew_note,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: AppSizes.p8),

          GestureDetector(
            onTap: () => url.copyToClipboard(),

            child: Text(
              url,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.link,
                // decoration: TextDecoration.underline,
              ),
            ),
          ),

          const Spacer(flex: 4),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final bool isApproved = status == null || status!.isEmpty;

    return Center(
      child: Container(
        height: 76,
        width: 76,
        decoration: BoxDecoration(
          color: isApproved ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        child: Icon(
          isApproved ? Icons.check : Icons.close_rounded,
          color: Colors.white,
          size: 44,
        ),
      ),
    );
  }
}
