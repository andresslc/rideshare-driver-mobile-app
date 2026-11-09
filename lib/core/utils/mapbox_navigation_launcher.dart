import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/features/ride_room/presentation/providers/mapbox_navigation_provider.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_map_provider.dart';
import 'package:driver_app/features/ride_room/presentation/screens/mapbox_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Re-entry guard – prevents double-taps or concurrent launches from
/// pushing multiple MapboxNavigationScreens onto the navigator stack.
bool _isNavigating = false;

/// Launches Mapbox navigation from the driver's current location
/// to the given [destinationLat], [destinationLng].
///
/// Implements the dispose-before-launch pattern: detaches the GoogleMap
/// to free GPU resources before pushing the MapboxNavigationScreen, and reattaches
/// upon return.
Future<void> openMapboxNavigation(
  BuildContext context, {
  required WidgetRef ref,
  required double destinationLat,
  required double destinationLng,
  String? destinationName,
}) async {
  // ── Guard: block re-entry from double-taps or multiple call sites ──
  if (_isNavigating) return;
  _isNavigating = true;

  try {
    context.showLoader();
    final driverPosition = await ref
        .read(mapboxNavigationProvider.notifier)
        .getDriverCurrentPosition();
    if (!context.mounted) return;
    context.hideLoader();

    if (driverPosition == null) {
      context.showErrorToast(context.l10n.unable_to_open_google_maps);
      return;
    }

    final rideMapNotifier = ref.read(rideMapProvider.notifier);
    rideMapNotifier.detachForNavigation();

    // Allow Flutter to render a frame without Google Map, giving Android EGL time to release GPU buffer slots
    await Future.delayed(const Duration(milliseconds: 350));
    if (!context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MapboxNavigationScreen(
          originLat: driverPosition.latitude,
          originLng: driverPosition.longitude,
          destinationLat: destinationLat,
          destinationLng: destinationLng,
          destinationName: destinationName,
        ),
      ),
    );

    // Allow Mapbox render thread time to asynchronously destroy EGL surface,
    // stop trip session coroutines, and finish route exit animation.
    await Future.delayed(const Duration(milliseconds: 800));
    rideMapNotifier.reattachAfterNavigation();
  } finally {
    if (context.mounted) {
      context.hideLoader();
    }
    _isNavigating = false;
  }
}
