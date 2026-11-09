import 'dart:io';

import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/extensions/strings_extensions.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/core/utils/validators.dart';
import 'package:driver_app/features/user_profile/domain/entites/update_profile_params.dart';
import 'package:driver_app/features/user_profile/domain/entites/user_entity.dart';
import 'package:driver_app/features/user_profile/presentation/providers/user_profile_provider.dart';
import 'package:driver_app/features/user_profile/presentation/widgets/profile_image_picker.dart';
import 'package:driver_app/l10n/app_localizations.dart';
import 'package:driver_app/shared/location_component/location_models/address_details.dart';
import 'package:driver_app/shared/location_component/location_ui/address_search_field.dart';
import 'package:driver_app/shared/screens/success_screen.dart';
import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:driver_app/shared/widgets/app_scaffold.dart';
import 'package:driver_app/shared/widgets/app_text_field.dart';
import 'package:driver_app/shared/widgets/circular_profile.dart';
import 'package:driver_app/shared/widgets/phone_number_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/navigation/routes.dart';

class EditPersonalInformationScreen extends ConsumerStatefulWidget {
  const EditPersonalInformationScreen({super.key});

  @override
  ConsumerState<EditPersonalInformationScreen> createState() =>
      _EditPersonalInformationScreenState();
}

class _EditPersonalInformationScreenState
    extends ConsumerState<EditPersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ssnController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  late bool _isSsnEditable;
  File? _selectedImageFile;
  String? _currentRemoteImage;
  bool _removedProfileImage = false;
  bool _isCityStateReadOnly = true;
  bool _seeded = false;

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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ssnController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _seedFromUser(UserEntity user) {
    if (_seeded) return;
    _seeded = true;
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _emailController.text = user.email;
    _phoneController.text = user.phone.toUSPhoneFormat();
    _ssnController.text = user.ssn ?? "";
    _seedAddressFields(user);
    _isSsnEditable = (user.ssn == null || user.ssn!.trim().isEmpty);
    _currentRemoteImage = user.profilePicture;
  }

  void _seedAddressFields(UserEntity user) {
    _addressController.text = user.address ?? '';
    if (user.city != null && user.city!.isNotEmpty) {
      _cityController.text = user.city!;
    }
    if (user.state != null && user.state!.isNotEmpty) {
      _stateController.text = user.state!;
    }

    if ((user.city == null || user.city!.isEmpty) ||
        (user.state == null || user.state!.isEmpty)) {
      _isCityStateReadOnly = false;
      _onAddressDetailsFetched(
        AddressDetails(
          latitude: 0,
          longitude: 0,
          city: user.city ?? '',
          state: user.state ?? '',
          country: '',
          zipCode: '',
        ),
      );
    } else {
      _isCityStateReadOnly = true;
    }
  }

  void _onAddressDetailsFetched(AddressDetails details) {
    if (details.isResolvedFromPlaces) {
      _cityController.text = details.city;
      _stateController.text = details.state;
      if (mounted) {
        setState(
          () => _isCityStateReadOnly =
              details.city.isNotEmpty && details.state.isNotEmpty,
        );
      }
      return;
    }
    final parts = _addressController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (details.city.isNotEmpty) {
      _cityController.text = details.city;
    } else if (parts.isNotEmpty) {
      if (parts.length >= 4) {
        _cityController.text = parts[parts.length - 3];
      } else if (parts.length == 3 || parts.length == 2) {
        _cityController.text = parts[0];
      }
    }

    if (details.state.isNotEmpty) {
      _stateController.text = details.state;
    } else if (parts.isNotEmpty) {
      if (parts.length >= 3) {
        _stateController.text = parts[parts.length - 2];
      } else if (parts.length == 2) {
        _stateController.text = parts[1];
      }
    }

    if (mounted) {
      setState(() {
        _isCityStateReadOnly =
            _cityController.text.isNotEmpty && _stateController.text.isNotEmpty;
      });
    }
  }

  void _onCustomAddressSelected(String customAddress) {
    if (mounted) {
      setState(() {
        _isCityStateReadOnly = false;
        _cityController.clear();
        _stateController.clear();
      });
    }
  }

  void _onAddressCleared() {
    if (mounted) {
      setState(() {
        _cityController.clear();
        _stateController.clear();
        _isCityStateReadOnly = false;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    const maxSizeInMB = 20;
    final result = await ProfileImagePicker.pickImage(
      context,
      canRemove: false,
      maxSizeInMB: maxSizeInMB,
    );
    if (!mounted || result == null) return;
    setState(() {
      if (result.remove) {
        _selectedImageFile = null;
        _currentRemoteImage = null;
        _removedProfileImage = true;
        return;
      }
      _selectedImageFile = result.file;
      if (result.file != null) {
        _currentRemoteImage = null;
        _removedProfileImage = false;
      }
    });
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final hasProfileImage =
        _selectedImageFile != null ||
        (_currentRemoteImage != null &&
            _currentRemoteImage!.trim().isNotEmpty &&
            !_removedProfileImage);

    if (!hasProfileImage) {
      context.showErrorToast(context.l10n.profilePictureRequired);
      return;
    }

    final profile = ref.read(userProfileProvider).profile;
    if (profile == null) {
      return;
    }

    final current = profile.user;
    final updatedFirstName = _firstNameController.text.trim();
    final updatedLastName = _lastNameController.text.trim();
    final updatedEmail = _emailController.text.trim();
    final updatedssn = _ssnController.text.trim();
    final updatedAddress = _addressController.text.trim();
    final updatedCity = _cityController.text.trim();
    final updatedState = _stateController.text.trim();

    final noDataChange =
        updatedFirstName == current.firstName &&
        updatedLastName == current.lastName &&
        updatedssn == current.ssn.toString() &&
        updatedEmail == current.email &&
        updatedAddress == (current.address ?? "") &&
        updatedCity == current.displayCity &&
        updatedState == current.displayState &&
        _selectedImageFile == null &&
        !_removedProfileImage;

    if (noDataChange) {
      context.showWarningToast(context.l10n.no_changes);
      return;
    }

    final params = UpdateDriverProfileParams.profile(
      firstName: updatedFirstName,
      lastName: updatedLastName,
      ssn: updatedssn,
      email: updatedEmail,
      address: updatedAddress,
      city: updatedCity,
      state: updatedState,
      file: _selectedImageFile,
    );

    final success = await ref
        .read(userProfileProvider.notifier)
        .updateSection(params);
    if (!mounted) return;

    if (success) {
      context.goNamed(
        Routes.success.name,
        extra: SuccessArgs(
          type: SuccessType.profileeditSuccessfully,
          redirectRouteName: Routes.home.name,
        ),
      );
      ref.read(userProfileProvider.notifier).clearMessages();
      (context).pop();

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
    final state = ref.watch(userProfileProvider);
    final user = state.profile?.user;
    if (user != null) {
      _seedFromUser(user);
    }
    final ssnMaskFormatter = MaskTextInputFormatter(
      mask: '###-##-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );

    final isLoadingInitial = state.isFetchingProfile && state.profile == null;
    final isUpdating =
        state.isUpdatingSection &&
        state.updatingSectionType == DriverProfileEditType.profile;

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.profileEditPersonalInformation,
        ),
      ),
      scrollable: true,
      child: isLoadingInitial
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (_selectedImageFile != null)
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.white24,
                          backgroundImage: FileImage(_selectedImageFile!),
                        )
                      else
                        CircularProfile(
                          image: _selectedImageFile != null
                              ? (_selectedImageFile!.path)
                              : _currentRemoteImage,

                          size: context.screenWidth * 0.15,
                        ),
                      const SizedBox(width: 14),
                      TextButton(
                        onPressed: isUpdating ? null : _pickProfileImage,
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.profileChangeProfilePicture,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p20),
                  AppTextField(
                    controller: _firstNameController,
                    labelText: context.l10n.first_name,
                    maxLength: 15,
                    textCapitalization: TextCapitalization.words,
                    hintText: context.l10n.enter_first_name,
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      // Allows only a-z and A-Z characters
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                    ],
                    validator: Validators.requiredFieldValidator,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSizes.p16),
                  AppTextField(
                    controller: _lastNameController,
                    labelText: context.l10n.last_name,
                    maxLength: 15,
                    textCapitalization: TextCapitalization.words,
                    hintText: context.l10n.enter_last_name,
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      // Allows only a-z and A-Z characters
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                    ],
                    validator: Validators.requiredFieldValidator,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSizes.p16),
                  Text(
                    AppLocalizations.of(context)!.profileEmailAddress,
                    style: context.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p8),

                  AppTextField(
                    controller: _emailController,
                    hintText: AppLocalizations.of(
                      context,
                    )!.profileEnterEmailAddress,
                    validator: Validators.emailValidator,
                    maxLength: 254,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSizes.p16),
                  Text(
                    AppLocalizations.of(context)!.ssn,
                    style: context.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p8),
                  AppTextField(
                    enabled: _isSsnEditable,
                    isGreishText: true,
                    controller: _ssnController,
                    hintText: context.l10n.ssn,
                    validator: Validators.ssnValidator,
                    textCapitalization: TextCapitalization.characters,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ssnMaskFormatter],
                  ),
                  const SizedBox(height: AppSizes.p16),
                  Text(
                    AppLocalizations.of(context)!.profileAddress,
                    style: context.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p8),
                  AddressSearchField(
                    searchFieldId: 'profile_edit.address',
                    controller: _addressController,
                    onDetailsFetched: _onAddressDetailsFetched,
                    onCustomAddressSelected: _onCustomAddressSelected,
                    onAddressCleared: _onAddressCleared,
                    hintText: AppLocalizations.of(context)!.profileEnterAddress,
                    validator: Validators.addressValidator,
                    maxLength: 255,
                    inputFormatters: [
                      // LengthLimitingTextInputFormatter(255),
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[a-zA-Z0-9\s.,\-/#'()& \s:]"),
                      ),
                    ],
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSizes.p16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _cityController,
                          labelText: context.l10n.city,
                          readOnly: _isCityStateReadOnly,
                          isGreishText: _isCityStateReadOnly,
                          maxlines: 1,
                          maxLength: 28,
                          hintText: context.l10n.enter_city,
                          validator: Validators.requiredFieldValidator,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: AppSizes.p16),
                      Expanded(
                        child: AppTextField(
                          controller: _stateController,
                          labelText: context.l10n.state,
                          readOnly: _isCityStateReadOnly,
                          isGreishText: _isCityStateReadOnly,
                          maxlines: 1,
                          maxLength: 28,
                          hintText: context.l10n.enter_state,
                          validator: Validators.stateValidator,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p16),
                  Text(
                    AppLocalizations.of(context)!.profilePhoneNumber,
                    // style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    style: context.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: AppSizes.p8),
                  PhoneNumberField(
                    controller: _phoneController,
                    enabled: false,
                    hintText: AppLocalizations.of(
                      context,
                    )!.profilePhoneNumberHint,
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

//ssn: Null
