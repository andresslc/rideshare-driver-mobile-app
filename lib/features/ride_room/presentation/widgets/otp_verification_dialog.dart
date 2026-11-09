import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:driver_app/shared/widgets/otp_input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class OtpVerificationDialog extends StatefulWidget {
  const OtpVerificationDialog({super.key, this.length = 6, this.expectedOtp});

  final int length;
  final String? expectedOtp;

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  final _otpController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyAndSubmit() {
    final enteredOtp = _otpController.text.trim();
    if (enteredOtp.length != widget.length) {
      setState(() {
        _errorText = context.l10n.otp_length_error(widget.length);
      });
      return;
    }

    // final expected = (widget.expectedOtp ?? '').trim();
    // if (expected.isNotEmpty && enteredOtp != expected) {
    //   setState(() {
    //     _errorText = context.l10n.otp_invalid_message;
    //   });
    //   return;
    // }

    Navigator.of(context).pop(int.tryParse(enteredOtp));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: AppGradientBox(
        isPlain: true,
        cornerRadius: 16,
        // padding: const EdgeInsets.all(AppSizes.p20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: Icon(Icons.close),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppSizes.p20,
                left: AppSizes.p20,
                right: AppSizes.p20,
              ),
              child: Column(
                children:
                    [
                      Text(
                        context.l10n.pickup_verification_title,
                        style: context.textTheme.titleLarge,
                      ),

                      if (kDebugMode)
                        Text(
                          "${widget.expectedOtp}",
                          style: context.textTheme.titleLarge,
                        ),

                      const SizedBox(height: 2),
                      Text(
                        context.l10n.enter_otp_to_verify,
                        style: context.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 20),

                      /// OTP Fields
                      OtpInput(
                        controller: _otpController,
                        length: widget.length,
                        onCompleted: (otp) {
                          _otpController.text = otp;
                        },
                      ),
                      if (_errorText != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _errorText!,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.redAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 25),

                      /// Verify Button
                      AppButton(
                        text: context.l10n.verify,
                        onPressed: _verifyAndSubmit,
                      ),
                    ].animate().scale(
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
