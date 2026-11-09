import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/features/auth/presentation/screens/account_review_status_screen.dart';
import 'package:driver_app/l10n/app_localizations.dart';
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/navigation/routes.dart';
import 'package:driver_app/features/user_profile/presentation/providers/user_profile_provider.dart';
import 'package:driver_app/features/user_profile/presentation/widgets/profile_section_tile.dart';
import 'package:driver_app/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/profile_empty_widget.dart';
import '../widgets/profile_header_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // bool get _isAccountNotApproved =>
  //     ref.read(userProfileProvider).profile?.user.accountStatus !=
  //     AccountReviewStatus.approved;

  // void _handleEditNavigation(String routeName, {Object? extra}) {
  //   if (!_isAccountNotApproved) {
  //     context.showReReviewWarning(() {
  //       context.pushNamed(routeName, extra: extra);
  //     });
  //   } else {
  //     context.pushNamed(routeName, extra: extra);
  //   }
  // }
  bool get _isAccountApproved =>
      ref.read(userProfileProvider).profile?.user.accountStatus ==
      AccountReviewStatus.approved;

  void _handleEditNavigation(
    String routeName, {
    Object? extra,
    bool showDialog = true,
  }) {
    final bool shouldShowDialog = showDialog && _isAccountApproved;

    if (shouldShowDialog) {
      context.showReReviewWarning(() {
        context.pushNamed(routeName, extra: extra);
      });
    } else {
      context.pushNamed(routeName, extra: extra);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProfileProvider);
    final profile = state.profile;

    ref.listen(userProfileProvider, (previous, next) {
      if (!mounted) return;
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        context.showErrorToast(next.errorMessage!);
        ref.read(userProfileProvider.notifier).clearMessages();
      }
    });

    return AppScaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: _isAccountApproved
              ? () => context.pop()
              : () => context.showGoBackWarning(
                  () => context.goNamed(Routes.root.name),
                ),
        ),
        // BackButton(
        //   onPressed: _isAccountApproved
        //       ? () => context.showGoBackWarning(
        //           () => context.goNamed(Routes.root.name),
        //         )
        //       : () => context.pop(),
        // ),
        title: Text(
          AppLocalizations.of(context)!.profileMyProfile,
        ).animate().fade(duration: 500.ms).slideY(begin: -0.2, end: 0),
      ),
      padding: const EdgeInsets.all(AppSizes.p16),
      child: profile == null
          ? ProfileEmptyState(
              isLoading: state.isFetchingProfile,
              onRetry: () {
                ref
                    .read(userProfileProvider.notifier)
                    .fetchProfile(force: true);
              },
            )
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(userProfileProvider.notifier)
                    .fetchProfile(force: true);
              },
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      ProfileHeader(
                            profilePicture: profile.user.profilePicture,
                            name: profile.user.displayName,
                            email: profile.user.email,
                            phone: profile.user.phone,
                            rating: profile.user.rating.toStringAsFixed(1),
                            reviewCount: profile.user.reviewsReceived,
                          )
                          .animate()
                          .fade(duration: 400.ms)
                          .slideY(begin: 0.15, end: 0),
                      const SizedBox(height: 20),
                      ProfileSectionTile(
                            title: l10n.profilePersonalInformation,
                            // review: profile.user.personalInfoReview,
                            // fileUrls: [
                            //   if ((profile.user.profilePicture ?? '').trim().isNotEmpty)
                            //     profile.user.profilePicture!,
                            // ],
                            onTap: () {
                              _handleEditNavigation(
                                showDialog: false,
                                Routes.editPersonalInformation.name,
                              );
                            },
                          )
                          .animate(delay: 100.ms)
                          .fade(duration: 300.ms)
                          .slideX(begin: 0.1, end: 0),
                      const SizedBox(height: 12),
                      ProfileSectionTile(
                            title: l10n.profileVehicleDetails,
                            // review: profile.user.vehicleDetails.review,
                            // fileUrls: profile.user.vehicleDetails.fileUrls,
                            onTap: () {
                              _handleEditNavigation(
                                Routes.editVehicleDetails.name,
                              );
                            },
                          )
                          .animate(delay: 200.ms)
                          .fade(duration: 300.ms)
                          .slideX(begin: 0.1, end: 0),
                      const SizedBox(height: 12),
                      ProfileSectionTile(
                            title: l10n.profileDrivingLicense,
                            // review: profile.user.driverLicense.review,
                            // fileUrls: profile.user.driverLicense.fileUrls,
                            onTap: () {
                              _handleEditNavigation(
                                Routes.editDriverLicense.name,
                              );
                            },
                          )
                          .animate(delay: 300.ms)
                          .fade(duration: 300.ms)
                          .slideX(begin: 0.1, end: 0),
                      const SizedBox(height: 12),
                      ProfileSectionTile(
                            title: l10n.profileVehicleRegistration,
                            // review: profile.user.vehicleRegistration.review,
                            // fileUrls: profile.user.vehicleRegistration.fileUrls,
                            onTap: () {
                              _handleEditNavigation(
                                Routes.editVehicleRegistration.name,
                              );
                            },
                          )
                          .animate(delay: 400.ms)
                          .fade(duration: 300.ms)
                          .slideX(begin: 0.1, end: 0),
                      const SizedBox(height: 12),
                      ProfileSectionTile(
                            title: l10n.profileInsuranceInformation,
                            // review: profile.user.insurance.review,
                            // fileUrls: profile.user.insurance.fileUrls,
                            onTap: () {
                              _handleEditNavigation(Routes.editInsurance.name);
                            },
                          )
                          .animate(delay: 500.ms)
                          .fade(duration: 300.ms)
                          .slideX(begin: 0.1, end: 0),
                    ],
                  );
                },
              ),
            ),
    );
  }
}
