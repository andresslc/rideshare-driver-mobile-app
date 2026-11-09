import 'package:driver_app/core/constants/app_colors.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:driver_app/shared/widgets/custom_tap.dart';
import 'package:flutter/material.dart';

enum ReferralMessageType { info, warning, error }

/// Response message shown under the referral code (paused programme,
/// request errors, ...). Never blocks the code itself.
class ReferralMessageBanner extends StatelessWidget {
  const ReferralMessageBanner({
    super.key,
    required this.message,
    this.type = ReferralMessageType.info,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final ReferralMessageType type;
  final String? actionLabel;
  final VoidCallback? onAction;

  Color get _color {
    switch (type) {
      case ReferralMessageType.info:
        return AppColors.brand;
      case ReferralMessageType.warning:
        return AppColors.warning;
      case ReferralMessageType.error:
        return AppColors.error;
    }
  }

  IconData get _icon {
    switch (type) {
      case ReferralMessageType.info:
        return Icons.info_outline_rounded;
      case ReferralMessageType.warning:
        return Icons.warning_amber_rounded;
      case ReferralMessageType.error:
        return Icons.error_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppGradientBox(
      padding: const EdgeInsets.all(12),
      cornerRadius: 12,
      border: BorderSide(color: _color, width: .5),
      child: Row(
        children: [
          Icon(_icon, color: _color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 8),
            CustomTap(
              onTap: onAction!,
              child: Text(
                actionLabel!,
                style: context.textTheme.labelSmall?.copyWith(
                  color: colors.link,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
