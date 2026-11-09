import 'dart:io';

import 'package:driver_app/core/di/service_locator.dart';
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/services/image_service.dart';
import 'package:driver_app/features/wallet/presentation/widgets/camera_bottom_sheet.dart';
import 'package:driver_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ProfileImagePickResult {
  final File? file;
  final bool remove;

  const ProfileImagePickResult._({this.file, required this.remove});

  const ProfileImagePickResult.picked(File file)
    : this._(file: file, remove: false);

  const ProfileImagePickResult.removed() : this._(remove: true);
}

class ProfileImagePicker {
  ProfileImagePicker._();

  static Future<ProfileImagePickResult?> pickImage(
    BuildContext context, {
    bool canRemove = false,
    int maxSizeInMB = 20,
  }) async {
    final result = await showModalBottomSheet<CameraBottomSheetResult>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CameraBottomSheet(canRemove: canRemove),
    );

    if (result?.remove == true) {
      return const ProfileImagePickResult.removed();
    }

    final source = result?.source;
    if (source == null) {
      return null;
    }

    try {
      final pickedFile = await locator<ImageService>().pickValidatedSingleImage(
        source: source,
        maxSizeInMB: maxSizeInMB,
      );
      if (pickedFile == null) {
        return null;
      }
      return ProfileImagePickResult.picked(File(pickedFile.path));
    } catch (error) {
      if (!context.mounted) return null;
      final l10n = AppLocalizations.of(context)!;
      final message = _mapImageError(l10n, error, maxSizeInMB);
      context.showErrorToast(message);
      // ScaffoldMessenger.of(context)
      //   ..hideCurrentSnackBar()
      //   ..showSnackBar(SnackBar(content: Text(message)));
      // return null;
    }
  }

  static String _mapImageError(
    AppLocalizations l10n,
    Object error,
    int maxSizeInMB,
  ) {
    if (error is! FormatException) return l10n.something_went_wrong;
    final code = error.message;
    if (code.startsWith('image_too_large')) {
      final parts = code.split(':');
      final size = parts.length > 1 ? int.tryParse(parts[1]) : maxSizeInMB;
      return l10n.profileImageTooLarge(size ?? maxSizeInMB);
    }
    if (code == 'image_invalid_type') {
      return l10n.profileImageInvalidType;
    }
    return l10n.something_went_wrong;
  }
}
