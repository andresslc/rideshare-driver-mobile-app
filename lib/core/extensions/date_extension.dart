import 'package:driver_app/core/core.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
/// Date / DateTime helpers.
extension DateExtension on DateTime {
  /// Time string with localized AM/PM and numbers.
  String formatTimeWithFixedAmPm({String? localeName}) {
    final locale = localeName ?? Intl.getCurrentLocale();
    final localDateTime = toLocal();
    final timePart = DateFormat('h:mm', locale).format(localDateTime);
    final amPmPart = DateFormat('a', locale).format(localDateTime);
    return '$timePart $amPmPart';
  }

  /// "Jan 5, 2025"
  String get formatted => DateFormat.yMMMd().format(this);

  /// "3:45 PM"
  String get timeOnly => DateFormat.jm().format(this);

  /// "Jan 5, 2025 at 3:45 PM"
  String get fullFormatted => '$formatted at $timeOnly';

  /// "2 hours ago", "just now", etc.
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatted;
  }

  /// Helper: Format Ride Date with provided localized labels for today/yesterday.
  String formatRideDateLocalized(
    String todayLabel,
    String yesterdayLabel, {
    String? localeName,
  }) {
    final locale = localeName ?? Intl.getCurrentLocale();
    final localDateTime = toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final rideDay = DateTime(
      localDateTime.year,
      localDateTime.month,
      localDateTime.day,
    );

    if (rideDay == today) {
      return "$todayLabel, ${localDateTime.formatTimeWithFixedAmPm(localeName: locale)}";
    } else if (rideDay == yesterday) {
      return "$yesterdayLabel, ${localDateTime.formatTimeWithFixedAmPm(localeName: locale)}";
    } else {
      final datePart = DateFormat('MMM d', locale).format(localDateTime);
      final timePart =
          localDateTime.formatTimeWithFixedAmPm(localeName: locale);
      return '$datePart, $timePart';
    }
  }
}

extension RideDateFormatter on DateTime {
  String formatRideDate(
      BuildContext context, {
        bool timeOnly = false,
      }) {
    final locale = context.l10n.localeName;

    final localRideDate = toLocal();
    final now = DateTime.now().toLocal();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final rideDay = DateTime(
      localRideDate.year,
      localRideDate.month,
      localRideDate.day,
    );

    /// ✅ Handle AM/PM based on locale
    final isSpanish = locale.startsWith('es');

    final timeFormatter = DateFormat(
      'h:mm a',
      isSpanish ? 'es' : 'en',
    );

    String formattedTime = timeFormatter.format(localRideDate);

    /// Fix spacing for Spanish → "a. m." / "p. m."
    if (isSpanish) {
      formattedTime = formattedTime
          .replaceAll('AM', 'a. m.')
          .replaceAll('PM', 'p. m.')
          .replaceAll('a.m.', 'a. m.')
          .replaceAll('p.m.', 'p. m.');
    }

    /// ✅ If only time is needed → skip day labels entirely
    if (timeOnly) {
      return formattedTime;
    }

    if (rideDay == today) {
      return "${context.l10n.ride_date_today}, $formattedTime";
    } else if (rideDay == yesterday) {
      return "${context.l10n.ride_date_yesterday}, $formattedTime";
    } else {
      return "${DateFormat('d MMM', locale).format(localRideDate)}, $formattedTime";
    }
  }}
