import 'package:driver_app/core/constants/app_images.dart';
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/core/utils/validators.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:driver_app/features/ride_room/presentation/widgets/plain_background_widget.dart';
import 'package:driver_app/l10n/app_localizations.dart';
import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:driver_app/shared/widgets/app_text_field.dart';
import 'package:driver_app/shared/widgets/custom_dialogue.dart';
import 'package:driver_app/shared/widgets/custom_tap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';

Future<bool> showEndRideConfirmation(BuildContext context) async {
  final l10n = context.l10n;
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return CustomDialogue(
        title: l10n.end_ride,
        subtitle: l10n.end_ride_confirmation,
        imagePath: AppImages.noImage,
        buttons: [
          AppButton(
            text: l10n.no,
            fontColor: context.appColors.brand,
            backgroundColor: context.appColors.border,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          AppButton(
            text: l10n.yes,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      );
    },
  );

  return confirmed ?? false;
}

Future<bool> showDropPassengerConfirmation(BuildContext context) async {
  final l10n = context.l10n;
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return CustomDialogue(
        title: l10n.drop_passenger,
        subtitle: l10n.drop_passenger_confirmation,
        imagePath: AppImages.noImage,
        buttons: [
          AppButton(
            text: l10n.no,
            fontColor: context.appColors.brand,
            backgroundColor: context.appColors.border,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          AppButton(
            text: l10n.yes,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      );
    },
  );

  return confirmed ?? false;
}

Future<bool> showCancelRideConfirmation(BuildContext context) async {
  final l10n = context.l10n;
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return CustomDialogue(
        title: l10n.cancel_ride,
        subtitle: l10n.cancel_ride_confirmation,
        imagePath: AppImages.noImage,
        buttons: [
          AppButton(
            text: l10n.cancel,
            fontColor: context.appColors.brand,
            backgroundColor: context.appColors.border,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          AppButton(
            text: l10n.confirm,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      );
    },
  );

  return confirmed ?? false;
}

Future<void> cancelRideWithConfirmation({
  required BuildContext context,
  required WidgetRef ref,
  required String? rideId,
}) async {
  final bool shouldCancel = await showCancelRideConfirmation(context);
  if (!shouldCancel) return;
  if (!context.mounted) return;

  final String? cancellationReason = await showCancelRideReasonDialog(context);
  if (cancellationReason == null) return;
  if (!context.mounted) return;

  await ref
      .read(rideSocketProvider.notifier)
      .rideCancelAction(rideId: rideId, cancellationReason: cancellationReason);
}

Future<String?> showCancelRideReasonDialog(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CancelRideReasonSheet(),
  );
}

class _CancelRideReasonSheet extends StatefulWidget {
  @override
  State<_CancelRideReasonSheet> createState() => _CancelRideReasonSheetState();
}

class _CancelRideReasonSheetState extends State<_CancelRideReasonSheet> {
  //   static List<String> _getPresetReasons(AppLocalizations l10n) => <String>[
  //     l10n.reason_harassment,
  //     l10n.reason_not_responding,
  //     l10n.reason_asked_to_cancel,
  //     l10n.reason_unsafe_location,
  //     l10n.reason_vehicle_issue,
  //     l10n.reason_other,
  //   ];
  /// Stable slot count; labels come from [context.l10n] on every build so
  /// locale changes (e.g. Spanish) always show translated text.
  static const int _presetCount = 6;
  static const int _otherReasonIndex = _presetCount - 1;

  static List<String> _presetLabels(AppLocalizations l10n) => <String>[
    l10n.reason_harassment,
    l10n.reason_not_responding,
    l10n.reason_asked_to_cancel,
    l10n.reason_unsafe_location,
    l10n.reason_vehicle_issue,
    l10n.reason_other,
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  int _selectedIndex = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   // Handled in didChangeDependencies or build because l10n needs context
  // }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _presetReasons = _getPresetReasons(context.l10n);
  //   _selectedReason = _presetReasons.first;
  // }

  // bool get _shouldShowCustomReason =>
  //     _selectedReason == context.l10n.reason_other;
  bool get _shouldShowCustomReason => _selectedIndex == _otherReasonIndex;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit(List<String> presetLabels) {
    if (_shouldShowCustomReason && !_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      _shouldShowCustomReason
          ? _reasonController.text.trim()
          : presetLabels[_selectedIndex],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final presetLabels = _presetLabels(l10n);
    assert(
      presetLabels.length == _presetCount,
      'preset reasons count must match _presetCount',
    );
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PlainBackgroundWidget(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset + 12),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ).copyWith(top: 12, bottom: kToolbarHeight),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: context.appColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.cancellationReason,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      CustomTap(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.cancel_ride_question,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(presetLabels.length, (index) {
                    final reason = presetLabels[index];
                    final selected = _selectedIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                            if (!_shouldShowCustomReason) {
                              _reasonController.clear();
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? context.appColors.border
                                : Colors.transparent,
                            border: Border.all(
                              color: selected
                                  ? context.appColors.brand
                                  : context.appColors.border,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  reason,
                                  style: context.textTheme.bodyLarge,
                                ),
                              ),
                              Radio<int>(
                                value: index,
                                groupValue: _selectedIndex,
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _selectedIndex = value;
                                    if (!_shouldShowCustomReason) {
                                      _reasonController.clear();
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (_shouldShowCustomReason) ...[
                    const SizedBox(height: 6),
                    AppTextField(
                      radius: 10,
                      hintText: l10n.reason,
                      maxLength: 300,
                      controller: _reasonController,
                      validator: Validators.requiredFieldValidator,
                      maxlines: 3,
                      isPlain: true,
                      autoFocus: true,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: l10n.cancel,
                          fontColor: context.appColors.brand,
                          backgroundColor: context.appColors.border,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: l10n.submit,
                          onPressed: () => _submit(presetLabels),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
