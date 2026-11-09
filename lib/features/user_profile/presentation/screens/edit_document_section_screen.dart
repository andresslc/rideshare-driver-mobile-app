import 'dart:io';

import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/services/image_service.dart';
import 'package:driver_app/features/user_profile/domain/entites/update_profile_params.dart';
import 'package:driver_app/features/user_profile/domain/entites/user_entity.dart';
import 'package:driver_app/features/user_profile/presentation/providers/user_profile_provider.dart';
import 'package:driver_app/features/user_profile/presentation/widgets/document_file_picker_field.dart';
import 'package:driver_app/features/wallet/presentation/widgets/camera_bottom_sheet.dart';
import 'package:driver_app/l10n/app_localizations.dart';
import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:driver_app/shared/widgets/app_scaffold.dart';
import 'package:driver_app/shared/widgets/app_text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EditDocumentSectionScreen extends ConsumerStatefulWidget {
  final String title;
  final DriverProfileEditType type;
  final bool requiresFrontImage;
  final bool requiresBackImage;
  final bool requiresExpiryDate;
  final bool requiresLicenseNumber;
  final String successMessage;

  const EditDocumentSectionScreen({
    super.key,
    required this.title,
    required this.type,
    required this.successMessage,
    this.requiresFrontImage = true,
    this.requiresBackImage = false,
    this.requiresExpiryDate = false,
    this.requiresLicenseNumber = false,
  });

  @override
  ConsumerState<EditDocumentSectionScreen> createState() =>
      _EditDocumentSectionScreenState();
}

class _EditDocumentSectionScreenState
    extends ConsumerState<EditDocumentSectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _expiryDateController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  DateTime? _selectedExpiryDate;

  File? _frontImageFile;
  File? _backImageFile;
  String? _frontRemoteImage;
  String? _backRemoteImage;
  bool _seeded = false;

  String? _initialFrontRemoteImage;
  String? _initialBackRemoteImage;
  String? _initialLicenseNumber;
  String? _initialExpiryDate;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider).profile;
    if (profile?.user != null) {
      _seedFromUser(profile!.user);
    } else {
      Future.microtask(() {
        ref.read(userProfileProvider.notifier).fetchProfile(force: true);
      });
    }
  }

  @override
  void dispose() {
    _expiryDateController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  void _seedFromUser(UserEntity user) {
    if (_seeded) return;
    _seeded = true;

    final section = _resolveSection(user);
    _frontRemoteImage = section.fileUrls.isNotEmpty
        ? section.fileUrls.first
        : null;
    _backRemoteImage = section.fileUrls.length > 1 ? section.fileUrls[1] : null;
    _licenseNumberController.text = section.licenseNumber ?? '';

    final parsedExpiry = _parseExpiryDate(section.expiryDate);
    _selectedExpiryDate = parsedExpiry;
    _expiryDateController.text = parsedExpiry != null
        ? DateFormat('MM-dd-yyyy').format(parsedExpiry)
        : (section.expiryDate ?? '');

    _initialFrontRemoteImage = _frontRemoteImage;
    _initialBackRemoteImage = _backRemoteImage;
    _initialLicenseNumber = _licenseNumberController.text;
    _initialExpiryDate = _expiryDateController.text;
  }

  DateTime? _parseExpiryDate(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return null;

    final apiFormat = DateTime.tryParse(raw);
    if (apiFormat != null) return apiFormat;

    try {
      return DateFormat('MM-dd-yyyy').parseStrict(raw);
    } catch (_) {
      return null;
    }
  }

  String _toApiExpiryDate(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return raw;

    final parsed = _parseExpiryDate(raw);
    if (parsed == null) return raw;
    return parsed.toString();
    // return DateFormat('yyyy-MM-dd').format(parsed);
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime initial = _selectedExpiryDate ?? today;
    if (initial.isBefore(today)) {
      initial = today;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: DateTime(today.year + 100),
    );
    if (picked == null) return;

    setState(() {
      _selectedExpiryDate = picked;
      _expiryDateController.text = DateFormat('MM-dd-yyyy').format(picked);
    });
  }

  DriverDocumentEntity _resolveSection(UserEntity user) {
    switch (widget.type) {
      case DriverProfileEditType.driverLicense:
        return user.driverLicense;
      case DriverProfileEditType.insurance:
        return user.insurance;
      case DriverProfileEditType.vehicleRegistration:
        return user.vehicleRegistration;
      case DriverProfileEditType.profile:
      case DriverProfileEditType.vehicleDetails:
        return const DriverDocumentEntity();
    }
  }

  Future<void> _pickFrontImage() async {
    await _handleImageSelection(
      hasExistingImage:
          _frontImageFile != null ||
          (_frontRemoteImage?.trim().isNotEmpty ?? false),
      canRemove: !widget.requiresFrontImage,
      onPicked: (image) {
        _frontImageFile = image;
        _frontRemoteImage = null;
      },
      onRemoved: () {
        _frontImageFile = null;
        _frontRemoteImage = null;
      },
    );
  }

  Future<void> _pickBackImage() async {
    await _handleImageSelection(
      hasExistingImage:
          _backImageFile != null ||
          (_backRemoteImage?.trim().isNotEmpty ?? false),
      canRemove: !widget.requiresBackImage,
      onPicked: (image) {
        _backImageFile = image;
        _backRemoteImage = null;
      },
      onRemoved: () {
        _backImageFile = null;
        _backRemoteImage = null;
      },
    );
  }

  Future<void> _handleImageSelection({
    required bool hasExistingImage,
    required bool canRemove,
    required void Function(File image) onPicked,
    required VoidCallback onRemoved,
  }) async {
    final result = await showModalBottomSheet<CameraBottomSheetResult>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          CameraBottomSheet(canRemove: canRemove && hasExistingImage),
    );

    if (!mounted || result == null) return;

    if (result.remove) {
      setState(onRemoved);
      return;
    }

    final source = result.source;
    if (source == null) return;

    try {
      final picked = await locator<ImageService>().pickValidatedSingleImage(
        source: source,
        maxSizeInMB: 20,
      );
      if (!mounted || picked == null) return;
      setState(() {
        onPicked(File(picked.path));
      });
    } catch (error) {
      if (!mounted) return;
      final l10n = context.l10n;
      final message = error is FormatException
          ? _mapImageError(l10n, error, 20)
          : l10n.image_selection_failed;
      context.showErrorToast(message);
    }
  }

  String _mapImageError(
    AppLocalizations l10n,
    FormatException error,
    int size,
  ) {
    final code = error.message;
    if (code.startsWith('image_too_large')) {
      final parts = code.split(':');
      final parsed = parts.length > 1 ? int.tryParse(parts[1]) : size;
      return l10n.profileImageTooLarge(parsed ?? size);
    }
    if (code == 'image_invalid_type') {
      return l10n.profileImageInvalidType;
    }
    return l10n.something_went_wrong;
  }

  String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return AppLocalizations.of(context)!.profileFieldRequired;
    }
    return null;
  }

  Future<File?> _resolveUploadFile({
    required File? localFile,
    required String? remoteUrl,
    required String fileNamePrefix,
  }) async {
    if (localFile != null) return localFile;
    return _downloadRemoteFile(remoteUrl, fileNamePrefix: fileNamePrefix);
  }

  Future<File?> _downloadRemoteFile(
    String? remoteUrl, {
    required String fileNamePrefix,
  }) async {
    final url = (remoteUrl ?? '').trim();
    if (url.isEmpty) return null;

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return null;

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final bytes = await consolidateHttpClientResponseBytes(response);
      final extension = _resolveFileExtension(uri);
      final tempDir = await Directory.systemTemp.createTemp(
        'driver_app_docs_',
      );
      final file = File(
        '${tempDir.path}${Platform.pathSeparator}$fileNamePrefix${DateTime.now().microsecondsSinceEpoch}$extension',
      );
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  String _resolveFileExtension(Uri uri) {
    if (uri.pathSegments.isEmpty) return '.jpg';
    final fileName = uri.pathSegments.last;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) return '.jpg';
    final extension = fileName.substring(dotIndex).toLowerCase();
    if (extension.length > 8) return '.jpg';
    return extension;
  }

  Future<void> _handleSubmit() async {
    final profile = ref.read(userProfileProvider).profile;
    if (profile == null) {
      context.showWarningToast(
        AppLocalizations.of(context)!.profileDataNotLoaded,
      );
      return;
    }

    final hasFront =
        _frontImageFile != null || (_frontRemoteImage?.isNotEmpty ?? false);
    final hasBack =
        _backImageFile != null || (_backRemoteImage?.isNotEmpty ?? false);

    if (widget.requiresFrontImage && !hasFront) {
      context.showWarningToast(
        AppLocalizations.of(context)!.profileFrontImageRequired,
      );
      return;
    }
    if (widget.requiresBackImage && !hasBack) {
      context.showWarningToast(
        AppLocalizations.of(context)!.profileBackImageRequired,
      );
      return;
    }

    final hasFrontImageChanged =
        _frontImageFile != null ||
        _frontRemoteImage != _initialFrontRemoteImage;
    final hasBackImageChanged =
        _backImageFile != null || _backRemoteImage != _initialBackRemoteImage;
    final hasExpiryDateChanged =
        widget.requiresExpiryDate &&
        (_expiryDateController.text.trim() !=
            (_initialExpiryDate ?? '').trim());
    final hasLicenseNumberChanged =
        widget.requiresLicenseNumber &&
        (_licenseNumberController.text.trim() !=
            (_initialLicenseNumber ?? '').trim());

    final hasChanges =
        hasFrontImageChanged ||
        hasBackImageChanged ||
        hasExpiryDateChanged ||
        hasLicenseNumberChanged;

    if (!hasChanges) {
      context.showWarningToast(context.l10n.no_changes);
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final expiry = _toApiExpiryDate(_expiryDateController.text);
    final licenseNumber = _licenseNumberController.text.trim();

    late final UpdateDriverProfileParams params;
    switch (widget.type) {
      case DriverProfileEditType.driverLicense:
        final frontFile = await _resolveUploadFile(
          localFile: _frontImageFile,
          remoteUrl: _frontRemoteImage,
          fileNamePrefix: 'driver_license_front_',
        );
        final backFile = await _resolveUploadFile(
          localFile: _backImageFile,
          remoteUrl: _backRemoteImage,
          fileNamePrefix: 'driver_license_back_',
        );
        if (!mounted) return;
        if (frontFile == null || backFile == null) {
          context.showErrorToast(
            AppLocalizations.of(context)!.profileUnableToPrepareFrontBack,
          );
          return;
        }
        params = UpdateDriverProfileParams.driverLicense(
          expiryDate: expiry,
          licenseNumber: licenseNumber,
          frontImage: frontFile,
          backImage: backFile,
        );
        break;
      case DriverProfileEditType.insurance:
        final frontFile = await _resolveUploadFile(
          localFile: _frontImageFile,
          remoteUrl: _frontRemoteImage,
          fileNamePrefix: 'insurance_front_',
        );
        final backFile = await _resolveUploadFile(
          localFile: _backImageFile,
          remoteUrl: _backRemoteImage,
          fileNamePrefix: 'insurance_back_',
        );
        if (!mounted) return;
        if (frontFile == null || backFile == null) {
          context.showErrorToast(
            AppLocalizations.of(context)!.profileUnableToPrepareFrontBack,
          );
          return;
        }
        params = UpdateDriverProfileParams.insurance(
          frontImage: frontFile,
          backImage: backFile,
        );
        break;
      case DriverProfileEditType.vehicleRegistration:
        final frontFile = await _resolveUploadFile(
          localFile: _frontImageFile,
          remoteUrl: _frontRemoteImage,
          fileNamePrefix: 'vehicle_registration_front_',
        );
        if (!mounted) return;
        if (frontFile == null) {
          context.showErrorToast(
            AppLocalizations.of(context)!.profileUnableToPrepareFront,
          );
          return;
        }
        params = UpdateDriverProfileParams.vehicleRegistration(
          frontImage: frontFile,
        );
        break;

      case DriverProfileEditType.profile:
      case DriverProfileEditType.vehicleDetails:
        return;
    }

    // final bool? isDo = await showDialog(
    //   context: context,
    //   builder: (_) => GradientSideDialog(
    //     title: "Confirm Update",
    //     subtitle:
    //         "Are you sure you want to update your vehicle/document information? Your profile will go into review, and some features may be temporarily restricted until approval.",
    //     // imagePath: AppIcons.danger,
    //     icon: Icons.warning,
    //     buttons: [
    //       AppButton(
    //         text: "No",
    //         // fontColor: AppColors.brand,
    //         onPressed: () => (context).pop(false),
    //         // backgroundColor: AppColors.darkField,
    //       ),
    //       AppButton(
    //         text: "Yes",
    //         fontColor: AppColors.darkBackground,
    //         // backgroundColor: AppColors.brand,
    //         onPressed: () => (context).pop(true),

    //         // color: Colors.red,
    //       ),
    //     ],
    //   ),
    // );
    // if (!((isDo) ?? false)) return;
    final success = await ref
        .read(userProfileProvider.notifier)
        .updateSection(params);
    if (!mounted) return;

    if (success) {
      final message =
          ref.read(userProfileProvider).successMessage ?? widget.successMessage;
      context.showSuccessToast(message);
      ref.read(userProfileProvider.notifier).clearMessages();
      context.pop();

      return;
    }

    final error = ref.read(userProfileProvider).errorMessage;
    if (error != null && error.trim().isNotEmpty) {
      context.showErrorToast(error);
      ref.read(userProfileProvider.notifier).clearMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10 = context.l10n;
    final state = ref.watch(userProfileProvider);
    final profile = state.profile;
    if (profile != null) {
      _seedFromUser(profile.user);
    }

    final isLoadingInitial = state.isFetchingProfile && state.profile == null;
    final isUpdating =
        state.isUpdatingSection && state.updatingSectionType == widget.type;

    return AppScaffold(
      appBar: AppBar(title: Text(widget.title)),
      scrollable: true,
      child: isLoadingInitial
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DocumentFilePickerField(
                    title: AppLocalizations.of(
                      context,
                    )!.profileUploadFrontImage,
                    hint: AppLocalizations.of(
                      context,
                    )!.profileUploadDocumentHint,
                    pickedFile: _frontImageFile,
                    remoteFileUrl: _frontRemoteImage,
                    onTap: isUpdating ? () {} : _pickFrontImage,
                  ),
                  if (widget.requiresBackImage) ...[
                    const SizedBox(height: AppSizes.p16),
                    DocumentFilePickerField(
                      title: AppLocalizations.of(
                        context,
                      )!.profileUploadBackImage,
                      hint: AppLocalizations.of(
                        context,
                      )!.profileUploadDocumentHint,
                      pickedFile: _backImageFile,
                      remoteFileUrl: _backRemoteImage,
                      onTap: isUpdating ? () {} : _pickBackImage,
                    ),
                  ],
                  if (widget.requiresExpiryDate) ...[
                    const SizedBox(height: AppSizes.p16),
                    Text(
                      AppLocalizations.of(context)!.profileExpiryDate,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p8),
                    AppTextField(
                      onTap: _pickExpiryDate,
                      controller: _expiryDateController,
                      hintText: 'MM-dd-yyyy',
                      validator: _requiredValidator,
                      readOnly: true,
                      suffixIcon: const Icon(Icons.calendar_today, size: 18),
                    ),
                  ],
                  if (widget.requiresLicenseNumber) ...[
                    const SizedBox(height: AppSizes.p16),
                    Text(
                      AppLocalizations.of(context)!.profileLicenseNumber,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p8),
                    AppTextField(
                      controller: _licenseNumberController,
                      hintText: AppLocalizations.of(
                        context,
                      )!.profileEnterLicenseNumber,
                      maxLength: 9,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z0-9]'),
                        ),
                      ],
                      validator: Validators.licenseValidator,
                    ),
                  ],
                  const SizedBox(height: AppSizes.p20),
                  Text(
                    // '* Once vehicle/document information is updated, your profile may move to review. During this period, ride acceptance can be restricted.',
                    // ln10.profile_review_notice,
                    l10.profile_review_notice,
                    style: context.textTheme.labelSmall?.copyWith(fontSize: 10),

                    // "* Once vehicle or document information is updated, the driver profile will move into a review state. During this review period, the driver may have restricted or no access to accept new rides until the information is approved.",
                    // style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: AppSizes.p24),
                  AppButton(
                    text: isUpdating
                        ? ''
                        : AppLocalizations.of(context)!.profileUpdate,
                    isDisable: isUpdating,
                    onPressed: isUpdating ? null : _handleSubmit,
                    child: isUpdating
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : null,
                  ),
                ],
              ),
            ),
    );
  }
}
