import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/map_style_state.dart';

final mapStyleProvider = AsyncNotifierProvider<MapStyleNotifier, MapStyleState>(
  MapStyleNotifier.new,
);

class MapStyleNotifier extends AsyncNotifier<MapStyleState> {
  @override
  Future<MapStyleState> build() async {
    try {
      final light = await rootBundle.loadString(
        'assets/map_style/light_map.json',
      );

      final dark = await rootBundle.loadString(
        'assets/map_style/dark_map.json',
      );

      return MapStyleState(light: light, dark: dark);
    } catch (e, s) {
      log('Map style load failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  String styleFor(Brightness brightness) {
    final value = state.value;

    if (value == null) return '';

    return brightness == Brightness.dark ? value.dark : value.light;
  }
}
