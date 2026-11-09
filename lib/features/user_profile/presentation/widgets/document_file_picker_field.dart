import 'dart:io';

import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:flutter/material.dart';

class DocumentFilePickerField extends StatelessWidget {
  final String title;
  final String hint;
  final File? pickedFile;
  final String? remoteFileUrl;
  final VoidCallback onTap;

  const DocumentFilePickerField({
    super.key,
    required this.title,
    required this.hint,
    required this.onTap,
    this.pickedFile,
    this.remoteFileUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasPreview =
        pickedFile != null || (remoteFileUrl?.isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AppGradientBox(
            cornerRadius: 16,
            borderWidth: 1.2,
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              height: 120,
              child: hasPreview
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: pickedFile != null
                          ? Image.file(pickedFile!, fit: BoxFit.cover)
                          : Image.network(
                              remoteFileUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _UploadHint(hint: hint),
                            ),
                    )
                  : _UploadHint(hint: hint),
            ),
          ),
        ),
      ],
    );
  }
}

class _UploadHint extends StatelessWidget {
  final String hint;

  const _UploadHint({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.upload_file_outlined, size: 28),
          const SizedBox(height: 8),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
