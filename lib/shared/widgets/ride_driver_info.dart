import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/core/theme/app_colors.dart';
import 'package:driver_app/shared/widgets/circular_profile.dart';
import 'package:flutter/material.dart';

import '../../core/extensions/context_extension.dart';
import 'chat_icon_widget.dart';

class DriverInfoSection extends StatelessWidget {
  const DriverInfoSection({
    super.key,
    required this.profileImage,
    required this.userName,
    required this.rating,
    this.carImage = '',
    this.carName = '',
    this.vehicleType = '',
    this.showTopBorder = true,
    this.wantChatIcon = false,
    this.onTrailing,
    this.showTrailing = false,
    this.showBadge = false,
    this.showRating = true,
    this.avatarSize,
    this.nameTextStyle,
  });
  final double? avatarSize;
  final TextStyle? nameTextStyle;

  final String profileImage;
  final String userName;
  final num rating;
  final String? carImage;
  final String? carName;
  final String? vehicleType;
  final bool showTopBorder;
  final bool showTrailing;
  final bool wantChatIcon;
  final bool showRating;
  final bool showBadge;
  final VoidCallback? onTrailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showTopBorder)
          Container(height: 1, color: context.appColors.border),
        const SizedBox(height: 8),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // CircleAvatar(
                  //   radius: 25,
                  //   backgroundImage: AssetImage(profileImage),
                  // ),
                  CircularProfile(
                    image: profileImage,
                    size: avatarSize ?? context.screenWidth * 0.14,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SizedBox(
                        //   width: double.infinity,
                        //   child: Text(
                        //     userName,
                        //     // textAlign: TextAlign.center,
                        //     maxLines: 2,
                        //     // overflow: TextOverflow.ellipsis,
                        //     softWrap: true,
                        //     style:
                        //         nameTextStyle ?? context.textTheme.titleMedium,
                        //   ),
                        // ),
                        Text(
                          userName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: nameTextStyle ?? context.textTheme.titleMedium,
                        ),

                        // const SizedBox(height: 2),
                        if (showRating)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toString(),
                                style: context.textTheme.bodySmall,
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: AppColors.darkField,
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (showTrailing)
              Expanded(
                flex: 3,
                child: wantChatIcon
                    ? ChatIconButton(onTap: onTrailing, showBadge: showBadge)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Image.asset(
                            carImage ?? "",
                            height: 32,
                            width: 56,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 6),
                          RichText(
                            maxLines: 2,
                            text: TextSpan(
                              children: [
                                if ((carName ?? '').trim().isNotEmpty)
                                  TextSpan(
                                    text: carName!.trim(),
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.lightTextSecondary,
                                        ),
                                  ),
                                if ((carName ?? '').trim().isNotEmpty &&
                                    (vehicleType ?? '').trim().isNotEmpty)
                                  TextSpan(
                                    text: ' - ',
                                    style: context.textTheme.bodySmall,
                                  ),
                                if ((vehicleType ?? '').trim().isNotEmpty)
                                  TextSpan(
                                    text: vehicleType!.trim(),
                                    style: context.textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
          ],
        ),
      ],
    );
  }
}


//default use 
// DriverInfoSection(
//   profileImage: 'assets/profile.png',
//   userName: 'Ali',
//   rating: 4.8,
//   carImage: 'assets/car.png',
//   carName: 'Toyota Corolla',
//   city: 'Miami',
// )

//icon kai sath use
// DriverInfoSection(
//   profileImage: 'assets/profile.png',
//   userName: 'Ali',
//   rating: 4.8,
//   carImage: 'assets/car.png',
//   carName: 'Toyota Corolla',
//   city: 'Miami',
//   carIconOnlyMode: true,
//   onCarIconTap: () {
//     debugPrint('Car icon tapped');
//   },
// )
