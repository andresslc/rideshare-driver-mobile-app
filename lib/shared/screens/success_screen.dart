import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/extensions/theme_extension.dart';
import '../../core/navigation/routes.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/app_scaffold.dart';

enum SuccessType {
  numberVerified,
  profileApproved,
  accountDeleted,
  fundsAdded,
  languageUpdated,
  feedbackSubmitted,
  profileeditSuccessfully,
}

class SuccessArgs {
  const SuccessArgs({
    this.type = SuccessType.numberVerified,
    this.redirectRouteName,
    this.autoRedirectDelay = const Duration(seconds: 2),
    this.titleOverride,
    this.messageOverride,
    this.redirectArgs,
  });

  final SuccessType type;
  final String? redirectRouteName;
  final Duration autoRedirectDelay;
  final String? titleOverride;
  final String? messageOverride;
  final Object? redirectArgs;
}

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key, this.args = const SuccessArgs()});

  final SuccessArgs args;

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _scheduleRedirect();
  }

  @override
  void didUpdateWidget(covariant SuccessScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.args != widget.args) {
      _redirectTimer?.cancel();
      _scheduleRedirect();
    }
  }

  void _scheduleRedirect() {
    final routeName = widget.args.redirectRouteName ?? Routes.home.name;

    _redirectTimer = Timer(widget.args.autoRedirectDelay, () {
      if (!mounted) return;
      final currentRouteName = GoRouter.of(context).state.name;
      if (currentRouteName == Routes.success.name) {
        context.goNamed(routeName, extra: widget.args.redirectArgs);
      }
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.appColors;
    final content = _resolveContent(widget.args.type, l10n).copyWith(
      title: widget.args.titleOverride,
      message: widget.args.messageOverride,
    );

    return AppScaffold(
      scrollable: false,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
      child: Align(
        alignment: const Alignment(0, -0.08),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  color: colors.brand,
                  borderRadius: BorderRadius.circular(AppSizes.p16),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF061204),
                  size: 42,
                ),
              ),
              const SizedBox(height: AppSizes.p20),
              Text(
                content.title,
                style: context.textTheme.headlineLarge?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.p12),
              Text(
                content.message,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: colors.textSecondary,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _SuccessContent _resolveContent(SuccessType type, AppLocalizations l10n) {
    switch (type) {
      case SuccessType.numberVerified:
        return _SuccessContent(
          title: l10n.number_verified,
          message: l10n.number_verified_message,
        );
      case SuccessType.profileApproved:
        return _SuccessContent(
          title: l10n.success_profile_approved_title,
          message: l10n.success_profile_approved_message,
        );
      case SuccessType.accountDeleted:
        return _SuccessContent(
          title: l10n.success_account_deleted_title,
          message: l10n.success_account_deleted_message,
        );
      case SuccessType.fundsAdded:
        return _SuccessContent(
          title: l10n.success_funds_added_title,
          message: l10n.success_funds_added_message,
        );
      case SuccessType.languageUpdated:
        return _SuccessContent(
          title: l10n.language_updated_title,
          message: l10n.language_updated_message,
        );
      case SuccessType.feedbackSubmitted:
        return _SuccessContent(
          title: l10n.success_feedback_title,
          message: l10n.success_feedback_message,
        );

      case SuccessType.profileeditSuccessfully:
        return _SuccessContent(
          title: l10n.profileEditSuccess,
          message: l10n.profile_update_subtitle,
        );
    }
  }
}

class _SuccessContent {
  const _SuccessContent({required this.title, required this.message});

  final String title;
  final String message;

  _SuccessContent copyWith({String? title, String? message}) {
    return _SuccessContent(
      title: title ?? this.title,
      message: message ?? this.message,
    );
  }
}
