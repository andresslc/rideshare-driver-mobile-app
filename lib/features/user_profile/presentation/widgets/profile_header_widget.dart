import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/shared/widgets/custom_tap.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/navigation/routes.dart';
import '../../../../shared/widgets/circular_profile.dart';

class ProfileHeader extends StatelessWidget {
  final String? profilePicture;
  final String name;
  final String? email;
  final String phone;
  final String? rating;
  final int reviewCount;

  const ProfileHeader({
    super.key,
    required this.profilePicture,
    required this.name,
    required this.email,
    required this.phone,
    this.rating,
    this.reviewCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final displayRating = rating?.trim().isNotEmpty ?? false ? rating! : "0.0";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // CircleAvatar(
        //   radius: 44,
        //   backgroundColor: Colors.white24,
        //   backgroundImage: (profilePicture?.trim().isNotEmpty ?? false)
        //       ? NetworkImage(profilePicture!)
        //       : null,
        //   child: (profilePicture?.trim().isNotEmpty ?? false)
        //       ? null
        //       : const Icon(Icons.person, size: 44),
        // ),
        CircularProfile(
          image: profilePicture,
          size: context.screenWidth * 0.32,
        ),

        Gap(12),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Text(
        //       name.trim().isEmpty ? '-' : name,
        //       // maxLines: 2,
        //       // textAlign: TextAlign.center,
        //       style: context.textTheme.titleLarge?.copyWith(
        //         fontWeight: FontWeight.bold,
        //       ),
        //     ),
        //   ],
        // ),
        SizedBox(
          width: double.infinity,
          child: Text(
            name.trim().isEmpty ? '-' : name,
            textAlign: TextAlign.center,
            maxLines: 2,
            // overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 6),
        // Text(
        //   email.trim().isEmpty ? phone : email,
        //   style: const TextStyle(fontSize: 14, color: Colors.white70),
        // ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_purple500_sharp,
                  size: 17,
                  color: Colors.amber,
                ),
                const SizedBox(width: 2),
                Text(displayRating, style: context.textTheme.labelMedium),
                const SizedBox(width: 6),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTap(
                      onTap: () {
                        context.pushNamed(Routes.reviews.name);
                      },
                      child: Text(
                        "$reviewCount ${context.l10n.reviews}",
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                    Container(
                      height: 0.8,
                      width: 78, // underline width
                      color: Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
