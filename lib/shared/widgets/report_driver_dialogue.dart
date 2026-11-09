import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/core/utils/validators.dart';
import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:driver_app/shared/widgets/app_text_field.dart';
import 'package:driver_app/shared/widgets/custom_tap.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../core/extensions/context_extension.dart';

class ReportDialog extends StatefulWidget {
  final String? subtitle;
  final String? title;
  final void Function(String description)? onSubmit;
  const ReportDialog({super.key, this.subtitle, this.onSubmit, this.title});

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      // backgroundColor: Colors.transparent,

      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: AppGradientBox(
        isPlain: context.theme.brightness == Brightness.light,
        padding: const EdgeInsets.all(16).copyWith(top: 14),
        cornerRadius: 12,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title + Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title ?? l10n.report_user,
                  style: context.textTheme.titleSmall?.copyWith(fontSize: 20),
                ),
                CustomTap(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              widget.subtitle ?? l10n.we_appreciate_issue,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            // Reason input box
            AppTextField(
              radius: 10,
              hintText: l10n.reason,
              maxLength: 300,
              controller: descriptionController,
              validator: Validators.requiredFieldValidator,
              maxlines: 3,
              isPlain: true,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 16),

            // Submit button
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                text: l10n.submit,
                onPressed: () {
                  widget.onSubmit?.call(descriptionController.text);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
