import 'package:driver_app/features/user_profile/domain/entites/update_profile_params.dart';
import 'package:driver_app/features/user_profile/presentation/screens/edit_document_section_screen.dart';
import 'package:driver_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class EditDriverLicenseScreen extends StatelessWidget {
  const EditDriverLicenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EditDocumentSectionScreen(
      title: l10n.profileEditDriverLicense,
      type: DriverProfileEditType.driverLicense,
      requiresBackImage: true,
      requiresExpiryDate: true,
      requiresLicenseNumber: true,
      successMessage: l10n.profileLicenseUpdatedSuccessfully,
    );
  }
}
