import 'package:driver_app/core/constants/app_icons.dart';
import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/navigation/routes.dart';
import 'package:driver_app/features/notification/presentation/providers/notification_provider.dart';
import 'package:driver_app/features/notification/presentation/states/notification_state.dart';
import 'package:driver_app/features/settings/presentation/widgets/app_listtile.dart';
import 'package:driver_app/features/user_profile/presentation/providers/user_profile_provider.dart';
import 'package:driver_app/l10n/app_localizations.dart';
import 'package:driver_app/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/storage_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? fcm;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Refresh profile to get latest notification settings
      ref.read(userProfileProvider.notifier).fetchProfile(force: true);

      final userProfile = ref.read(userProfileProvider).profile;
      if (userProfile != null) {
        ref
            .read(notificationProvider.notifier)
            .setInitialValue(userProfile.user.isNotificationEnabled);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notificationState = ref.watch(notificationProvider);

    // Listen for profile changes (e.g. refresh)
    ref.listen(userProfileProvider, (previous, next) {
      if (next.profile != null && previous?.profile != next.profile) {
        ref
            .read(notificationProvider.notifier)
            .setInitialValue(next.profile!.user.isNotificationEnabled);
      }
    });

    // Listen for errors or success
    ref.listen(notificationProvider, (previous, next) {
      if (next.status == NotificationStatus.error && next.message != null) {
        context.showErrorToast(next.message.toString());
      }
    });
    return AppScaffold(
      appBar: AppBar(title: Text(l10n.settings), centerTitle: true),
      child: Column(
        children: [
          /// Notifications toggle
          AppListTile(
            leadingImage: AppIcons.notification,
            title: l10n.notifications,
            showToggle: true,
            toggleValue: notificationState.isNotificationEnabled,
            onToggleChanged: (val) async {
              final localFcm = locator<StorageService>().getFCMToken ?? '';
              fcm = localFcm.isEmpty
                  ? await locator<NotificationServices>().getDeviceToken()
                  : localFcm;
              ref
                  .read(notificationProvider.notifier)
                  .toggleNotification(val, fcm);
            },
          ).animate().fade(duration: 300.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: AppSizes.p12),

          /// Theme Setting
          AppListTile(
            leadingImage: AppIcons.mode,
            title: l10n.themePreferences,
            onTap: () {
              context.pushNamed(Routes.themePreferences.name);
            },
          ).animate(delay: 100.ms).fade(duration: 250.ms).slideY(begin: 0.2),
          const SizedBox(height: AppSizes.p12),

          /// Payment Method
          AppListTile(
            leadingImage: AppIcons.card,
            title: l10n.bank_account,
            onTap: () {
              context.pushNamed(Routes.bankAccount.name);
            },
          ).animate(delay: 100.ms).fade(duration: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: AppSizes.p12),

          /// Language
          AppListTile(
            leadingImage: AppIcons.globe,
            title: l10n.language,
            onTap: () {
              context.pushNamed(Routes.language.name);
            },
          ).animate(delay: 100.ms).fade(duration: 150.ms).slideY(begin: 0.2),

          const SizedBox(height: AppSizes.p12),

          /// Delete Account (destructive)
          AppListTile(
            leadingImage: AppIcons.delete,
            title: l10n.delete_account,
            onTap: () => context.pushNamed(Routes.deleteAccountOTP.name),
            showToggle: false,
            isDestructive: true,
          ).animate(delay: 120.ms).fade(duration: 100.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }
}
