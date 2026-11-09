import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/extensions/strings_extensions.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:flutter/material.dart';

class DashboardCarInfoCard extends StatelessWidget {
  const DashboardCarInfoCard({
    super.key,
    required this.title,
    required this.make,
    required this.model,
    required this.registrationNumber,
    required this.imagePath,
    this.vehicleType,
    required this.plateNumber,
  });

  final String title;
  final String make;
  final String model;
  final String registrationNumber;
  final String imagePath;
  final String? vehicleType;
  final String? plateNumber;

  @override
  Widget build(BuildContext context) {
    final details = <MapEntry<String, String>>[
      MapEntry(context.l10n.vehicleMake, make),
      MapEntry(context.l10n.vehicleModel, model),
      MapEntry(context.l10n.vehicleRegistration, registrationNumber),
      if ((vehicleType ?? '').trim().isNotEmpty)
        MapEntry(context.l10n.vehicleType, vehicleType!.trim().capitalised),
      MapEntry(context.l10n.profileLicensePlate, plateNumber!.trim()),
    ];

    return AppGradientBox(
      cornerRadius: AppSizes.p24,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p8),
                  ...details.map(
                    (detail) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.p4),
                      child: RichText(
                        text: TextSpan(
                          style: context.textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text: '${detail.key}: ',
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: detail.value.trim().isEmpty
                                  ? '--'
                                  : detail.value,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.p12),
            Image.asset(
              imagePath,
              fit: BoxFit.fill,
              height: 50,
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.darkBackground
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
