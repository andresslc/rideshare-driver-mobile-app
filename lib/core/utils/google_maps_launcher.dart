import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:driver_app/core/extensions/context_extension.dart';

/// Launches Google Maps navigation from the driver's current location
/// to the given [destinationLat], [destinationLng].
///
/// On Android this opens the Google Maps app directly with navigation mode.
/// On iOS it opens the Google Maps app if installed, otherwise falls back
/// to Apple Maps.
Future<void> openGoogleMapsNavigation(
  BuildContext context, {
  required double destinationLat,
  required double destinationLng,
}) async {
  // google.navigation URI launches turn-by-turn navigation directly
  final Uri googleMapsUri = Uri.parse(
    'google.navigation:q=$destinationLat,$destinationLng&mode=d',
  );

  // Fallback: open the web URL which redirects to Google Maps on any platform
  final Uri fallbackUri = Uri.parse(
    'https://www.google.com/maps/dir/?api=1'
    '&destination=$destinationLat,$destinationLng'
    '&travelmode=driving',
  );

  try {
    final bool launched = await launchUrl(
      googleMapsUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      // Fallback to web URL if the google.navigation scheme isn't handled
      final bool fallbackLaunched = await launchUrl(
        fallbackUri,
        mode: LaunchMode.externalApplication,
      );

      if (!fallbackLaunched && context.mounted) {
        context.showErrorToast(context.l10n.unable_to_open_google_maps);
      }
    }
  } catch (_) {
    // If google.navigation throws (e.g. iOS), try fallback
    try {
      final bool fallbackLaunched = await launchUrl(
        fallbackUri,
        mode: LaunchMode.externalApplication,
      );
      if (!fallbackLaunched && context.mounted) {
        context.showErrorToast(context.l10n.unable_to_open_google_maps);
      }
    } catch (_) {
      if (context.mounted) {
        context.showErrorToast(context.l10n.unable_to_open_google_maps);
      }
    }
  }
}
