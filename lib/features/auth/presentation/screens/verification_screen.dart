import 'dart:async';
import 'package:driver_app/core/di/service_locator.dart';
import 'package:driver_app/features/auth/presentation/states/auth_state.dart';
import 'package:driver_app/shared/widgets/loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/params/auth_params.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/shared.dart';
import '../../../../shared/widgets/custom_tap.dart';
import '../providers/auth_provider.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final _otpController = TextEditingController();
  final CustomLoader loader = CustomLoader();

  Timer? _timer;
  int _seconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _otpController.text = "123456";
    }
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

  /// Verify OTP via AuthController
  void _verifyOtp() async {
    final otp = _otpController.text;

    if (otp.length < 6) {
      context.showErrorToast(context.l10n.otp_required);
      return;
    }

    final digitsOnly = widget.phoneNumber;
    final String fcm =
        locator<StorageService>().getFCMToken ??
        await locator<NotificationServices>().getDeviceToken() ??
        '';
    ref
        .read(authProvider.notifier)
        .verifyOtp(
          VerifyOtpParams(
            countryCode: kDebugMode ? '1' : '1',
            phone: digitsOnly,
            otp: otp,
            fcm: fcm,
          ),
        );
  }

  void _resendOtp() {
    if (!_canResend) return;

    _startTimer();

    final rawNumber = widget.phoneNumber;

    String digitsOnly = rawNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.startsWith('1')) {
      digitsOnly = digitsOnly.substring(1);
    }
    ref
        .read(authProvider.notifier)
        .resendOtp(
          SendOtpParams(countryCode: kDebugMode ? '1' : '1', phone: digitsOnly),
        );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.appColors;

    ref.listen<AuthState>(authProvider, (previous, next) {
      switch (next) {
        case AuthLoading():
          loader.showLoader(context);
          break;
        case AuthError(:final message):
          loader.hideLoader();
          final displayMessage = message.toLowerCase().contains('invalid otp')
              ? l10n.invalid_otp
              : message;
          context.showToast(displayMessage);

          // context.showToast($);
          break;
        case OtpVerified(:final response):
          loader.hideLoader();
          context.whereToGo(response, phoneNumber: widget.phoneNumber);
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
      appBar: AppBar(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// 🔹 Header
          AuthHeader(
                title: l10n.verification,
                subtitle: l10n.otp_subtitle(
                  '**** **** ${widget.phoneNumber.substring(7)}',
                ),
              )
              .animate()
              .fadeIn(delay: 150.ms, duration: 350.ms)
              .slideY(begin: 0.15),

          const SizedBox(height: 24),

          /// 🔹 OTP Input (POP effect)
          OtpInput(length: 6, controller: _otpController)
              .animate()
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 450.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(delay: 200.ms),

          const SizedBox(height: 16),

          /// 🔹 Resend Row
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
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

          const SizedBox(height: 32),

          /// 🔹 Verify Button (last appearance)
          AppButton(
            text: l10n.verify,
            onPressed: _verifyOtp,
          ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }
}
