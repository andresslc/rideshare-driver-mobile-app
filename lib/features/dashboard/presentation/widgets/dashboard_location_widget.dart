import 'package:driver_app/core/constants/app_icons.dart';
import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DashboardLocationWidget extends StatelessWidget {
  final String location;
  const DashboardLocationWidget({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          AppIcons.strokeLocation,
          height: AppSizes.p14,
          color: context.colorScheme.primary,
        ),
        const Gap(AppSizes.p8),
        Flexible(child: Text(location, style: context.textTheme.bodyMedium)),
      ],
    );
  }
}
