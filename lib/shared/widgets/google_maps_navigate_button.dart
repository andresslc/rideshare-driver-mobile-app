import 'package:flutter/material.dart';
import 'neon_maps_cta_button.dart';

/// A styled button that opens Google Maps navigation.
///
/// Displays a map pin icon with localized "Navigate in Google Maps" text.
/// Used across ride sheets to let the driver open turn-by-turn directions.
class GoogleMapsNavigateButton extends StatelessWidget {
  const GoogleMapsNavigateButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return NeonMapsCTAButton(onTap: onPressed);
  }
}
