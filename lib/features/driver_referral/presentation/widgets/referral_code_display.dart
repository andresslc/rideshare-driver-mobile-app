import 'dart:math' as math;

import 'package:driver_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

/// Read-only alphanumeric code display. Mirrors the look of [OtpInput]
/// but the characters come from the backend and can never be edited.
class ReferralCodeDisplay extends StatefulWidget {
  const ReferralCodeDisplay({super.key, required this.code, this.length = 7});

  final String code;
  final int length;

  @override
  State<ReferralCodeDisplay> createState() => _ReferralCodeDisplayState();
}

class _ReferralCodeDisplayState extends State<ReferralCodeDisplay> {
  static const double _gap = 7;
  static const double _maxBoxSize = 52;

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.code.toUpperCase());
  }

  @override
  void didUpdateWidget(covariant ReferralCodeDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.code != widget.code) {
      _controller.text = widget.code.toUpperCase();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Fit all boxes in the available width (7 boxes at 12% of the
        // screen width overflow on 360dp phones).
        final boxSize = math.min(
          (constraints.maxWidth - _gap * (widget.length - 1)) / widget.length,
          _maxBoxSize,
        );

        final pinTheme = PinTheme(
          width: boxSize,
          height: boxSize,
          textStyle: theme.textTheme.titleMedium,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.brand, width: .5),
            boxShadow: [
              BoxShadow(
                color: AppColors.brand.withValues(alpha: 0.25),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        );

        return Center(
          child: Pinput(
            controller: _controller,
            length: widget.length,
            readOnly: true,
            useNativeKeyboard: false,
            showCursor: false,
            defaultPinTheme: pinTheme,
            focusedPinTheme: pinTheme,
            submittedPinTheme: pinTheme,
            separatorBuilder: (index) => const SizedBox(width: _gap),
          ),
        );
      },
    );
  }
}
