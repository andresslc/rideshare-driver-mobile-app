import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';

extension FormatAvgTimeExtension on num {
  String formatAvgTime(BuildContext context) {
    final totalMinutes = round();

    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;

    if (hours == 0) {
      return '$mins ${context.l10n.min}';
    }

    if (mins == 0) {
      return '$hours ${context.l10n.hour}';
    }

    return '$hours ${context.l10n.hour} $mins ${context.l10n.min}';
  }
}
