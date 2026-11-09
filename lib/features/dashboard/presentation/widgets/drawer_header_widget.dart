import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/l10n/app_localizations.dart';
import 'package:driver_app/shared/widgets/circular_profile.dart';
import 'package:driver_app/shared/widgets/custom_tap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/extensions/strings_extensions.dart';
import '../../../user_profile/presentation/providers/user_profile_provider.dart';

class CustomDrawerHeader extends ConsumerWidget {
  final VoidCallback? onViewProfile;

  const CustomDrawerHeader({super.key, this.onViewProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final textTheme = context.textTheme;
    final colorScheme = context.appColors;

    final name = ref.watch(
      userProfileProvider.select((user) => user.profile?.user.displayName),
    );
    final email = ref.watch(
      userProfileProvider.select((user) => user.profile?.user.email),
    );
    final image = ref.watch(
      userProfileProvider.select((user) => user.profile?.user.profilePicture),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p16,
        vertical: AppSizes.p24,
      ),
      child: CustomTap(
        onTap: onViewProfile,
        isNeedOverlay: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Profile Image
            // CircleAvatar(
            //   radius: AppSizes.p32,
            //   backgroundColor: colorScheme.brand,
            //   child: Icon(
            //     Icons.person,
            //     size: AppSizes.p32,
            //     color: colorScheme.textPrimary,
            //   ),
            // ),
            CircularProfile(image: image, size: context.screenWidth * 0.18),
            // if (image != null)
            // CircleAvatar(
            //   radius: AppSizes.p32,
            //   backgroundColor: colorScheme.brand,
            //   child: Icon(
            //     Icons.person,
            //     size: AppSizes.p32,
            //     color: colorScheme.textPrimary,
            //   ),
            // )
            // else
            //   Container(
            //     width: AppSizes.p32,
            //     height: AppSizes.p32,
            //     decoration: BoxDecoration(shape: BoxShape.circle),
            //     clipBehavior: Clip.antiAlias,
            //     child: CachedNetworkImage(
            //       imageUrl: image!,
            //       fit: BoxFit.cover,
            //       progressIndicatorBuilder: (_, _, _) => Center(
            //         child: LoadingAnimationWidget.threeArchedCircle(
            //           size: AppSizes.p32 * 0.3,
            //           color: AppColors.brand,
            //         ),
            //       ),
            //       errorWidget: (_, _, _) => Center(
            //         child: Icon(
            //           Icons.person,
            //           size: AppSizes.p32 * 0.4,
            //           // color: AppColors.,
            //         ),
            //       ),
            //     ),
            //   ),
            const SizedBox(width: AppSizes.p16),

            /// Name, Email & View Profile
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.toString().capitalised,
                    maxLines: 2,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: AppSizes.p4),

                  Text(
                    email.toString(),
                    maxLines: 2,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppSizes.p4),

                  Text(
                    l10n.view_profile,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.brand,
                      decoration: TextDecoration.underline,
                      decorationColor: colorScheme.brand,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
