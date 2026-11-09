import 'dart:async';

import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/core/navigation/routes.dart';
import 'package:driver_app/core/params/auth_params.dart';
import 'package:driver_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:driver_app/features/auth/presentation/states/auth_state.dart';
import 'package:driver_app/features/user_profile/presentation/providers/user_profile_provider.dart';
import 'package:driver_app/shared/widgets/custom_tap.dart';
import 'package:driver_app/shared/widgets/loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/shared.dart';

//TODO: Work remaining
class DeleteAccountVerifyOTPScreen extends ConsumerStatefulWidget {
  const DeleteAccountVerifyOTPScreen({super.key});

  @override
  ConsumerState<DeleteAccountVerifyOTPScreen> createState() =>
      _DeleteAccountVerifyOTPScreenState();
}

class _DeleteAccountVerifyOTPScreenState
    extends ConsumerState<DeleteAccountVerifyOTPScreen> {
  final _otpController = TextEditingController();
  final CustomLoader loader = CustomLoader();
  Timer? _timer;
  int _seconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _seconds = 60;
    _canResend = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        timer.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _onVerify() {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      context.showErrorToast(context.l10n.otp_required);
      return;
    }

    ref.read(authProvider.notifier).deleteAccount(otp);
  }

  void _resendOtp() {
    if (!_canResend) return;

    _startTimer();
    final user = ref.read(userProfileProvider).profile?.user;

    ref
        .read(authProvider.notifier)
        .sendDeleteAccountOtp(
          SendOtpParams(countryCode: '', phone: user?.phone ?? ''),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.appColors;

    // Listen to authProvider for side effects
    ref.listen<AuthState>(authProvider, (previous, next) {
      switch (next) {
        case AuthLoading():
          loader.showLoader(context);
          break;

        case AuthError(:final message):
          loader.hideLoader();
          context.showToast(message);
          break;

        case AccountDeleted():
          loader.hideLoader();
          context.showToast(l10n.success_account_deleted_message);
          context.goNamed(Routes.login.name);
          break;

        case OtpResent(:final message):
          loader.hideLoader();
          context.showToast(message);
          break;

        default:
          loader.hideLoader();
          break;
      }
    });

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          l10n.delete_account,
        ).animate().fade(duration: 300.ms).slideY(begin: 0.2, end: 0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSizes.p20),
          Text(
            l10n.verification,
            style: context.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ).animate().fade(delay: 100.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: AppSizes.p16),
          OtpInput(controller: _otpController, length: 6)
              .animate()
              .fade(delay: 200.ms)
              .scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.did_not_receive_code,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              _canResend
                  ? CustomTap(
                      onTap: _resendOtp,
                      child: Text(
                        l10n.resend_now,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colors.link,
                        ),
                      ),
                    )
                  : Text(
                      "00:${_seconds.toString().padLeft(2, '0')}",
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.link,
                      ),
                    ),
            ],
          ).animate().fade(delay: 300.ms).slideX(begin: -0.2, end: 0),
          const Spacer(),
          AppButton(
                text: context.l10n.verify_delete_account,
                onPressed: _onVerify,
              )
              .animate()
              .fade(delay: 400.ms)
              .scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: AppSizes.p24),
        ],
      ),
    );
  }
}
