import 'package:driver_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as locationService;
import '../../../../shared/widgets/app_button.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../shared/widgets/custom_dialogue.dart';

class CameraBottomSheetResult {
  final ImageSource? source;
  final bool remove;

  const CameraBottomSheetResult.pick(this.source) : remove = false;

  const CameraBottomSheetResult.remove() : source = null, remove = true;
}

class CameraBottomSheet extends StatelessWidget {
  final bool canRemove;

  const CameraBottomSheet({super.key, this.canRemove = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 50,
                  child: TextButton(
                    onPressed: () => Navigator.pop(
                      context,
                      const CameraBottomSheetResult.pick(ImageSource.gallery),
                    ),
                    child: Text(
                      "Upload Image",
                      style: context.textTheme.titleSmall,
                    ),
                  ),
                ),
                const Divider(thickness: 1.5, height: 1),
                SizedBox(
                  height: 50,
                  child: TextButton(
                    onPressed: () => handleCameraTap(context),
                    child: Text(
                      "Take Photo",
                      style: context.textTheme.titleSmall,
                    ),
                  ),
                ),
                if (canRemove) ...[
                  const Divider(thickness: 1.5, height: 1),
                  SizedBox(
                    height: 50,
                    child: TextButton(
                      onPressed: () => Navigator.pop(
                        context,
                        const CameraBottomSheetResult.remove(),
                      ),
                      child: Text(
                        "Remove Photo",
                        style: context.textTheme.titleSmall?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Gap(15),
          SafeArea(
            top: false,
            child: AppButton(
              text: "Cancel",
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> handleCameraTap(BuildContext context) async {
    final status = await Permission.camera.status;

    debugPrint('STARTED: $status');

    switch (status) {
      case PermissionStatus.granted:
        debugPrint('GRANTED');
        _openCamera(context);
        return;

      case PermissionStatus.permanentlyDenied:
        debugPrint('PERMANENTLY DENIED (before request)');
        _showCameraPermissionDialog(context);
        return;

      case PermissionStatus.restricted:
        debugPrint('RESTRICTED');
        _showCameraPermissionDialog(context);
        return;

      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        debugPrint('LIMITED / PROVISIONAL');
        _openCamera(context);
        return;

      case PermissionStatus.denied:
        debugPrint('DENIED → requesting...');

        final result = await Permission.camera.request();

        debugPrint('AFTER REQUEST: $result');

        switch (result) {
          case PermissionStatus.granted:
            _openCamera(context);
            return;

          case PermissionStatus.permanentlyDenied:
            _showCameraPermissionDialog(context);
            return;

          case PermissionStatus.restricted:
            _showCameraPermissionDialog(context);
            return;

          case PermissionStatus.limited:
          case PermissionStatus.provisional:
            _openCamera(context);
            return;

          case PermissionStatus.denied:
            _showCameraPermissionDialog(context);
            return;
        }
    }
  }

  void _openCamera(BuildContext context) {
    Navigator.pop(
      context,
      const CameraBottomSheetResult.pick(ImageSource.camera),
    );
  }

  void _showCameraPermissionDialog(BuildContext context) {
    final l10n = context.l10n;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PopScope(
        canPop: false,
        child: CustomDialogue(
          title: l10n.camera_permission_title,
          subtitle: l10n.camera_permission_subtitle,
          icon: Icons.location_on,
          buttons: [
            AppButton(
              text: l10n.open_settings,
              onPressed: () async {
                context.pop();
                await locationService.openAppSettings();
              },
              backgroundColor: context.appColors.brand,
              fontColor: Colors.white,
            ),
          ],
        ),
      ),
    ).then((_) {});
  }
}
