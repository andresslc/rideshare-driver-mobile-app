// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:driver_app/core/core.dart';
import 'package:driver_app/features/user_profile/presentation/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:driver_app/features/ride_room/domain/entities/ride_entities.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:driver_app/features/ride_room/presentation/states/ride_state.dart';

import '../../../../core/extensions/strings_extensions.dart';

class ProfileToggleWidget extends ConsumerStatefulWidget {
  final RideEntity? currentRide;
  final Function(bool)? onChanged;
  final double? rating;

  const ProfileToggleWidget({
    super.key,
    this.currentRide,
    this.onChanged,
    this.rating,
  });

  @override
  ConsumerState<ProfileToggleWidget> createState() =>
      _ProfileToggleWidgetState();
}

class _ProfileToggleWidgetState extends ConsumerState<ProfileToggleWidget> {
  @override
  Widget build(BuildContext context) {
    final name = ref.watch(
      userProfileProvider.select((user) => user.profile?.user.displayName),
    );
    final profileImage = ref.watch(
      userProfileProvider.select((user) => user.profile?.user.profilePicture),
    );
    final isOnline = ref.watch(
      rideSocketProvider.select((state) => state.isOnline),
    );
    final isToggleLoading = ref.watch(
      rideSocketProvider.select(
        (state) =>
            state.status == SocketStatus.loading &&
            state.action == SocketAction.driverOnline,
      ),
    );

    return Row(
      children: [
        // Left Side (Profile + Texts)
        Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: profileImage != null
                    ? NetworkImage(profileImage)
                    : null,
                child: profileImage == null ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.hello,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      (name?.capitalised ?? "Driver"),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.rating != null) ...[
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => context.pushNamed(Routes.reviews.name),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brand.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.brand.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.rating!.toStringAsFixed(1)} ${context.l10n.ratings}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        GestureDetector(
          onTap: isToggleLoading
              ? null
              : () {
                  final newValue = !isOnline;
                  if (widget.onChanged != null) {
                    widget.onChanged!(newValue);
                  } else {
                    final notifier = ref.read(rideSocketProvider.notifier);
                    if (newValue) {
                      notifier.toggleDriverOnline(true);
                    } else {
                      notifier.toggleDriverOffline();
                    }
                  }
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 60,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),

              color: isOnline
                  ? AppColors.brand
                  : Color(0xff787880).withValues(alpha: .16),
            ),
            alignment: isOnline ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 36,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: isToggleLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      isOnline ? "ON" : "OFF",
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        // color: Colors.transparent,
                        // color: Color(0xff787880).withValues(alpha: .16),
                        color: isOnline ? AppColors.brand : Colors.black,
                      ),
                    ),
            ),
          ),
        ),

        // // Right Side (Toggle)
        // Switch(
        //   value: isOnline,
        //   onChanged: isToggleLoading
        //       ? null
        //       : (value) {
        //           ref
        //               .read(rideSocketProvider.notifier)
        //               .toggleDriverOnline(value);
        //           if (widget.onChanged != null) {
        //             widget.onChanged!(value);
        //           }
        //         },
        // ),
      ],
    );
  }
}
