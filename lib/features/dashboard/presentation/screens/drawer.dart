import 'package:driver_app/core/constants/api_endpoints.dart';
import 'package:driver_app/core/constants/app_colors.dart';
import 'package:driver_app/core/constants/app_icons.dart';
import 'package:driver_app/core/constants/app_images.dart';
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/core/navigation/routes.dart';
import 'package:driver_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:driver_app/features/auth/presentation/states/auth_state.dart';
import 'package:driver_app/l10n/app_localizations.dart';
import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:driver_app/shared/widgets/custom_dialogue.dart';
import 'package:driver_app/shared/widgets/loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/drawer_header_widget.dart';
import '../widgets/drawer_tile.dart';

class AppDrawer extends ConsumerWidget {
  final ZoomDrawerController zoomController;

  const AppDrawer({super.key, required this.zoomController});

  void showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return CustomDialogue(
          title: context.l10n.logoutDialogTitle,
          subtitle: context.l10n.subtitle_logout,
          icon: Icons.logout_rounded,

          // imagePath: AppIcons.logout,
          buttons: [
            AppButton(
              text: AppLocalizations.of(context)!.cancel,
              backgroundColor: context.appColors.lightButton,
              fontColor: context.appColors.brand,
              onPressed: () {
                Navigator.pop(context); // close dialog
              },
            ),
            AppButton(
              text: AppLocalizations.of(context)!.logout,
              backgroundColor: context.appColors.brand,
              fontColor: context.appColors.textPrimary,
              fontSize: 12,
              onPressed: () {
                _logout(context, ref); // call existing logout
              },
            ),
          ],
        );
      },
    );
  }

  //
  Future<void> _openWebUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      context.showErrorToast('Unable to open link.');
    }
  }

  //
  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    // context.pop(context);
    // context.showLoader();

    ref.read(authProvider.notifier).logout();
    if (!context.mounted) return;
    context.goNamed(Routes.login.name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // final CustomLoader loader = CustomLoader();

    // ref.listen<AuthState>(authProvider, (previous, next) {
    //   if (next is AuthLoading) {
    //     loader.showLoader(context);
    //   }

    //   if (next is LoggedOut) {
    //     loader.hideLoader();
    //     context.goNamed(Routes.login.name);
    //   }

    //   if (next is AuthError) {
    //     loader.hideLoader();
    //     context.showToast(next.message);
    //   }
    // });

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Container(
        decoration: BoxDecoration(
          image: isDarkMode
              ? const DecorationImage(
                  image: AssetImage(AppImages.bgTwo),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: SafeArea(
          child: Column(
            children: [
              /// Drawer Header
              CustomDrawerHeader(
                onViewProfile: () {
                  zoomController.close?.call();

                  context.pushNamed(Routes.profile.name);
                },
              ),

              /// Menu Items
              DrawerTile(
                icon: CupertinoIcons.home,
                title: l10n.dashboard,
                onTap: () => ZoomDrawer.of(context)?.close(),
              ),
              DrawerTile(
                icon: CupertinoIcons.clock,

                title: l10n.ride_history,
                onTap: () {
                  // Navigator.pop(context);
                  zoomController.close?.call();

                  context.pushNamed(Routes.ridehistory.name);
                },
              ),
              DrawerTile(
                icon: Icons.account_balance_wallet_rounded,

                title: l10n.wallet,
                onTap: () {
                  // Navigator.pop(context);
                  zoomController.close?.call();

                  context.pushNamed(Routes.wallet.name);
                },
              ),
              DrawerTile(
                icon: CupertinoIcons.settings,

                title: l10n.settings,
                onTap: () {
                  // Navigator.pop(context);
                  zoomController.close?.call();

                  context.pushNamed(Routes.settings.name);
                },
              ),
              DrawerTile(
                icon: CupertinoIcons.person_2,

                title: l10n.invite_drawer,
                onTap: () {
                  // Navigator.pop(context);
                  zoomController.close?.call();

                  context.pushNamed(Routes.invitefriends.name);
                },
              ),
              DrawerTile(
                icon: Icons.badge_outlined,

                title: l10n.referral_drawer,
                onTap: () {
                  zoomController.close?.call();

                  context.pushNamed(Routes.driverReferral.name);
                },
              ),
              DrawerTile(
                title: l10n.terms_conditions,
                icon: CupertinoIcons.doc_text,

                onTap: () {
                  // Navigator.pop(context);

                  _openWebUrl(context, ApiEndpoints.termsUrl);
                },
              ),
              DrawerTile(
                icon: CupertinoIcons.lock_shield,

                title: l10n.privacy_policy,
                onTap: () {
                  // Navigator.pop(context);

                  _openWebUrl(context, ApiEndpoints.privacyPolicyUrl);
                },
              ),
              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: DrawerTile(
                  icon: CupertinoIcons.square_arrow_right,

                  title: l10n.logout,
                  isDestructive: true,
                  onTap: () {
                    showLogoutDialog(context, ref);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
