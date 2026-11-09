import 'package:driver_app/core/constants/app_images.dart';
import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/extensions/strings_extensions.dart';
import 'package:driver_app/features/user_profile/domain/entites/update_profile_params.dart';
import 'package:driver_app/features/user_profile/domain/entites/user_entity.dart';
import 'package:driver_app/features/user_profile/domain/entites/vehicle_type_option_entity.dart';
import 'package:driver_app/features/user_profile/presentation/providers/user_profile_provider.dart';
import 'package:driver_app/features/user_profile/presentation/states/user_states.dart';
import 'package:driver_app/l10n/app_localizations.dart';
import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:driver_app/shared/widgets/app_scaffold.dart';
import 'package:driver_app/shared/widgets/app_text_field.dart';
import 'package:driver_app/shared/widgets/custom_dialogue.dart';
import 'package:driver_app/shared/widgets/custom_tap.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EditVehicleDetailsScreen extends ConsumerStatefulWidget {
  const EditVehicleDetailsScreen({super.key});

  @override
  ConsumerState<EditVehicleDetailsScreen> createState() =>
      _EditVehicleDetailsScreenState();
}

class _EditVehicleDetailsScreenState
    extends ConsumerState<EditVehicleDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _vinController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _regionController = TextEditingController();
  final _expiryDateController = TextEditingController();
  ProviderSubscription<UserProfileState>? _profileListener;

  String _selectedVehicleTypeId = '';
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _trySeedFromCurrentProfile();

    _profileListener = ref.listenManual(userProfileProvider, (_, next) {
      final details = next.profile?.user.vehicleDetails;
      if (details != null) {
        _seedFromVehicleDetails(details);
      }

      if (mounted &&
          _selectedVehicleTypeId.trim().isEmpty &&
          next.vehicleTypeOptions.isNotEmpty) {
        setState(() {
          _selectedVehicleTypeId =
              _matchVehicleTypeOptionId(
                details?.vehicleType,
                next.vehicleTypeOptions,
              ) ??
              next.vehicleTypeOptions.first.id;
        });
      }
    });

    if (ref.read(userProfileProvider).profile == null) {
      Future.microtask(() {
        ref.read(userProfileProvider.notifier).fetchProfile(force: true);
      });
    }

    Future.microtask(() {
      ref.read(userProfileProvider.notifier).fetchVehicleTypes(force: true);
    });
  }

  void _trySeedFromCurrentProfile() {
    final details = ref.read(userProfileProvider).profile?.user.vehicleDetails;
    if (details != null) {
      _seedFromVehicleDetails(details);
    }
  }

  @override
  void dispose() {
    _profileListener?.close();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _vinController.dispose();
    _licensePlateController.dispose();
    _registrationNumberController.dispose();
    _regionController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  void _seedFromVehicleDetails(VehicleDetailsEntity details) {
    if (_seeded) return;
    _seeded = true;

    _makeController.text = details.make;
    _modelController.text = details.model;
    _yearController.text = details.yearOfManufacture?.toString() ?? '';
    _colorController.text = details.color;
    _vinController.text = details.vehicleIdentificationNumber;
    _licensePlateController.text = details.licensePlateNumber;
    _registrationNumberController.text = details.registrationNumber;
    _regionController.text = details.regionOfRegistration;
    if (details.expiryDate.isNotEmpty) {
      final parsedDate = DateTime.tryParse(details.expiryDate);
      if (parsedDate != null) {
        _expiryDateController.text = DateFormat(
          'MM-dd-yyyy',
        ).format(parsedDate);
      } else {
        _expiryDateController.text = details.expiryDate;
      }
    } else {
      _expiryDateController.text = details.expiryDate;
    }

    final matchedId = _matchVehicleTypeOptionId(
      details.vehicleType,
      ref.read(userProfileProvider).vehicleTypeOptions,
    );
    if (matchedId != null) {
      _selectedVehicleTypeId = matchedId;
    }
  }

  String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return AppLocalizations.of(context)!.profileFieldRequired;
    }
    return null;
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final parsedInitialDate = DateTime.tryParse(
      _expiryDateController.text.trim(),
    );
    final initialDate =
        parsedInitialDate != null && !parsedInitialDate.isBefore(today)
        ? parsedInitialDate
        : today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(now.year + 30),
    );
    if (picked != null) {
      _expiryDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      _formKey.currentState?.validate();
    }
  }

  // Future<bool> _showUpdateConfirmationDialog() async {
  //   final l10n = AppLocalizations.of(context)!;
  //   final shouldUpdate = await showDialog<bool>(
  //     context: context,
  //     builder: (_) => CustomDialogue(
  //       title: l10n.confirm,
  //       subtitle: l10n.profile_review_notice,
  //       icon: Icons.warning,
  //       buttons: [
  //         AppButton(text: l10n.no, onPressed: () => context.pop(false)),
  //         AppButton(
  //           text: l10n.yes,
  //           fontColor: AppColors.darkBackground,
  //           onPressed: () => context.pop(true),
  //         ),
  //       ],
  //     ),
  //   );
  //   return shouldUpdate ?? false;
  // }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final profile = ref.read(userProfileProvider).profile;
    if (profile == null) {
      context.showWarningToast(
        AppLocalizations.of(context)!.profileDataNotLoaded,
      );
      return;
    }

    final year = int.parse(_yearController.text.trim());
    final payload = VehicleDetailsUpdatePayload(
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      yearOfManufacture: year,
      color: _colorController.text.trim(),
      vehicleIdentificationNumber: _vinController.text.trim(),
      licensePlateNumber: _licensePlateController.text.trim(),
      registrationNumber: _registrationNumberController.text.trim(),
      regionOfRegistration: _regionController.text.trim(),
      expiryDate: _expiryDateController.text.trim(),
      vehicleType:
          _selectedVehicleTypeOption(ref.read(userProfileProvider))?.model ??
          '',
    );

    final existing = profile.user.vehicleDetails;
    final payloadDate = DateFormat('MM-dd-yyyy').parse(payload.expiryDate);
    final existingDate = DateTime.parse(existing.expiryDate);

    final isExpiryChanged =
        payloadDate.year != existingDate.year ||
        payloadDate.month != existingDate.month ||
        payloadDate.day != existingDate.day;

    final hasAnyChange =
        payload.make != existing.make ||
        payload.model != existing.model ||
        payload.yearOfManufacture != existing.yearOfManufacture ||
        payload.color != existing.color ||
        payload.vehicleIdentificationNumber !=
            existing.vehicleIdentificationNumber ||
        payload.licensePlateNumber != existing.licensePlateNumber ||
        payload.registrationNumber != existing.registrationNumber ||
        payload.regionOfRegistration != existing.regionOfRegistration ||
        // payload.expiryDate != existing.expiryDate
        isExpiryChanged ||
        payload.vehicleType != existing.vehicleType;

    if (!hasAnyChange) {
      context.showWarningToast(AppLocalizations.of(context)!.profileNoChanges);
      return;
    }

    // final isConfirmed = await _showUpdateConfirmationDialog();
    // if (!isConfirmed || !mounted) return;

    final success = await ref
        .read(userProfileProvider.notifier)
        .updateSection(
          UpdateDriverProfileParams.vehicleDetails(payload: payload),
        );
    if (!mounted) return;

    if (success) {
      final message =
          ref.read(userProfileProvider).successMessage ??
          AppLocalizations.of(context)!.profileVehicleUpdatedSuccessfully;
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
    final state = ref.watch(userProfileProvider);

    final isLoadingInitial = state.isFetchingProfile && state.profile == null;
    final isUpdating =
        state.isUpdatingSection &&
        state.updatingSectionType == DriverProfileEditType.vehicleDetails;
    final l10 = context.l10n;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      appBar: AppBar(title: Text(l10n.profileEditVehicleDetails)),
      scrollable: true,
      child: isLoadingInitial
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildLabeledTextField(
                          label: l10n.profileVehicleMake,
                          child: AppTextField(
                            controller: _makeController,
                            hintText: l10n.profileVehicleMake,
                            validator: _requiredValidator,
                            maxLength: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLabeledTextField(
                          label: l10n.profileVehicleModel,
                          child: AppTextField(
                            controller: _modelController,
                            hintText: l10n.profileVehicleModel,
                            validator: _requiredValidator,
                            maxLength: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildLabeledTextField(
                          label: l10n.manu_year,
                          // label: l10n.profileYear,
                          child: AppTextField(
                            controller: _yearController,
                            hintText: l10n.profileYear,
                            validator: Validators.yearValidator,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLabeledTextField(
                          label: l10n.profileVehicleColor,
                          child: AppTextField(
                            controller: _colorController,
                            hintText: l10n.profileVehicleColor,
                            validator: _requiredValidator,
                            maxLength: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p12),
                  _buildLabeledTextField(
                    label: l10n.profileVin,
                    child: AppTextField(
                      controller: _vinController,
                      hintText: l10n.profileVin,
                      validator: Validators.vinValidator,
                      helperText: l10n.profileVinMustBeUnique,
                      maxLength: 17,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[A-HJ-NPR-Z0-9]'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  _buildLabeledTextField(
                    label: l10n.profileLicensePlate,
                    child: AppTextField(
                      controller: _licensePlateController,
                      hintText: l10n.profileLicensePlate,
                      validator: Validators.numberPlateValidator,
                      maxLength: 7,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  _buildLabeledTextField(
                    label: l10n.profileRegistrationNumber,
                    child: AppTextField(
                      controller: _registrationNumberController,
                      hintText: l10n.profileRegistrationNumber,
                      validator: Validators.registrationNumberValidator,
                      helperText: l10n.profileRegistrationMustBeUnique,
                      maxLength: 8,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  _buildLabeledTextField(
                    label: l10n.profileRegionOfRegistration,
                    child: AppTextField(
                      controller: _regionController,
                      hintText: l10n.profileRegionOfRegistration,
                      validator: _requiredValidator,
                      maxLength: 40,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  _buildLabeledTextField(
                    label: l10n.profileRegistrationExpiry,
                    child: AppTextField(
                      controller: _expiryDateController,
                      hintText: 'YYYY-MM-DD',
                      validator: _requiredValidator,
                      readOnly: true,
                      onTap: _pickExpiryDate,
                      suffixIcon: const Icon(Icons.calendar_today, size: 18),
                    ),
                  ),

                  const SizedBox(height: AppSizes.p8),
                  Text(
                    l10n.profileVehicleType,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildVehicleTypePicker(
                    effectiveVehicleTypes: state.vehicleTypeOptions,
                    isFetchingVehicleTypes: state.isFetchingVehicleTypes,
                    isUpdating: isUpdating,
                  ),
                  const SizedBox(height: AppSizes.p16),
                  Text(
                    l10.profile_review_notice,
                    style: context.textTheme.labelSmall?.copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: AppSizes.p24),
                  AppButton(
                    text: isUpdating ? '' : l10n.profileUpdate,
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

  Widget _buildVehicleTypePicker({
    required List<VehicleTypeOptionEntity> effectiveVehicleTypes,
    required bool isFetchingVehicleTypes,
    required bool isUpdating,
  }) {
    if (isFetchingVehicleTypes && effectiveVehicleTypes.isEmpty) {
      return const SizedBox(
        height: 110,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (effectiveVehicleTypes.isEmpty) {
      return SizedBox(
        height: 110,
        child: Center(
          child: Text(
            context.l10n.no_vehicle_types_available,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: effectiveVehicleTypes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final option = effectiveVehicleTypes[index];
          // final vehicleTypeValue = _normalizeVehicleTypeValue(option.model);
          final isSelected = option.id == _selectedVehicleTypeId;
          final vehicleImage =
              AppImages.suv; //_vehicleTypeImage(vehicleTypeValue);
          final label = _vehicleTypeLabel(context, option);
          final isDark = context.theme.brightness == Brightness.dark;

          return CustomTap(
            onTap: isUpdating
                ? null
                : () {
                    setState(() {
                      _selectedVehicleTypeId = option.id;
                    });
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              // curve: Curves.easeInOut,
              decoration: const BoxDecoration(),
              child: AppGradientBox(
                isPlain: context.theme.brightness == Brightness.light,
                padding: const EdgeInsets.all(15),
                border: BorderSide(color: AppColors.brand, width: 2),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          vehicleImage,
                          width: 70,
                          fit: BoxFit.contain,
                          color: isDark ? Colors.white : AppColors.brand,

                          // color: !context.isDark
                          //     ? AppColors.darkBackground
                          //     : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (isSelected)
                      Positioned(
                        top: -10,
                        right: -5,
                        child: Container(
                          width: 18,
                          height: 19,
                          decoration: const BoxDecoration(
                            color: AppColors.brand,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  String _normalizeVehicleTypeValue(String value) {
    return value.trim().toLowerCase();
  }

  String? _matchVehicleTypeOptionId(
    String? vehicleType,
    List<VehicleTypeOptionEntity> options,
  ) {
    final normalized = _normalizeVehicleTypeValue(vehicleType ?? '');
    if (normalized.isEmpty) {
      return null;
    }

    for (final option in options) {
      if (_normalizeVehicleTypeValue(option.model) == normalized) {
        return option.id;
      }
    }

    return null;
  }

  VehicleTypeOptionEntity? _selectedVehicleTypeOption(UserProfileState state) {
    if (_selectedVehicleTypeId.trim().isEmpty) {
      return null;
    }

    for (final option in state.vehicleTypeOptions) {
      if (option.id == _selectedVehicleTypeId) {
        return option;
      }
    }

    return null;
  }

  String _vehicleTypeLabel(
    BuildContext context,
    VehicleTypeOptionEntity option,
  ) {
    final rideType = option.model.trim().toLowerCase();
    return rideType.capitalised;
    // switch (rideType) {
    //   case 'luxury':
    //     return context.l10n.luxury;
    //   case 'economy':
    //     return context.l10n.economy;
    //   case 'premium':
    //     return context.l10n.premium;
    //   default:
    // final make = option.make.trim();
    // final model = option.model.trim();
    // if (make.isNotEmpty && model.isNotEmpty) {
    //   return '$make $model';
    // }
    // if (make.isNotEmpty) {
    //   return make;
    // }
    // if (model.isNotEmpty) {
    //   return model;
    // }
    // return
    // rideType.isNotEmpty
    //     ?
    //  rideType.capitalised;
    // : context.l10n.profileVehicleType;
  }
}

  // String? _vehicleTypeImage(String vehicleType) {
  //   switch (vehicleType.toLowerCase()) {
  //     case 'suv':
  //       return AppImages.suv;
  //     // case 'sedan':
  //     case 'hatchback':
  //       return AppImages.suv;
  //     // case 'luxury':
  //     case 'premium':
  //       return AppImages.suv;
  //     default:
  //       return AppImages.suv;
  //   }
  // }
// }
