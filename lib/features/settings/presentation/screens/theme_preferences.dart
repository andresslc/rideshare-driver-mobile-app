import 'package:driver_app/l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../widgets/theme_preference_widget.dart';

class ThemePreferencesScreen extends StatefulWidget {
  const ThemePreferencesScreen({super.key});

  @override
  State<ThemePreferencesScreen> createState() => _ThemePreferencesScreenState();
}

class _ThemePreferencesScreenState extends State<ThemePreferencesScreen> {
  late String selectedTheme;

  @override
  void initState() {
    super.initState();
    selectedTheme = locator<ThemeNotifier>().selectedTheme;
  }

  void _onThemeChanged(String? val) {
    if (val == null) return;
    setState(() {
      selectedTheme = val;
    });

    final notifier = locator<ThemeNotifier>();
    switch (val) {
      case 'light':
        notifier.setLight();
        break;
      case 'dark':
        notifier.setDark();
        break;
      case 'automatic':
        notifier.setAutomatic();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      appBar: AppBar(title: Text(l10n.themePreferences)),
      child: Column(
        children: [
          ThemePreferencesWidget(
            title: l10n.themeAutomatic,
            subtitle: l10n.themeAutomaticSubtitle,
            value: 'automatic',
            groupValue: selectedTheme,
            onChanged: _onThemeChanged,
          ).animate().fade(delay: 100.ms).slideX(begin: 0.2, end: 0),
          const Gap(AppSizes.p12),
          ThemePreferencesWidget(
            title: l10n.themeDark,
            subtitle: l10n.themeDarkSubtitle,
            value: 'dark',
            groupValue: selectedTheme,
            onChanged: _onThemeChanged,
          ).animate().fade(delay: 150.ms).slideX(begin: 0.2, end: 0),
          const Gap(AppSizes.p12),
          ThemePreferencesWidget(
            title: l10n.themeLight,
            subtitle: l10n.themeLightSubtitle,
            value: 'light',
            groupValue: selectedTheme,
            onChanged: _onThemeChanged,
          ).animate().fade(delay: 200.ms).slideX(begin: 0.2, end: 0),
        ],
      ),
  );
  }
}
  