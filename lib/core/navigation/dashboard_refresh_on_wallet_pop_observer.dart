import 'dart:async';

import 'package:driver_app/core/navigation/routes.dart';
import 'package:driver_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Refreshes dashboard when the user returns from the wallet route.
///
/// [GoRouter] sets [Route.settings.name] from the matched route (`wallet`, etc.).
final class DashboardRefreshOnWalletPopObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final name = route.settings.name;
    if (name != Routes.wallet.name && name != Routes.wallet.path) {
      return;
    }

    final navigatorContext = navigator?.context;
    if (navigatorContext == null) return;

    ProviderContainer container;
    try {
      container = ProviderScope.containerOf(navigatorContext, listen: false);
    } catch (_) {
      return;
    }

    unawaited(
      container
          .read(dashboardProvider.notifier)
          .getDashboardData(showLoading: false),
    );
  }
}
