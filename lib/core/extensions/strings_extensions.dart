import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Common string utilities.
extension StringExtension on String {
  /// Capitalise the first letter.
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Title case every word.
  String get titleCase => split(' ').map((w) => w.capitalised).join(' ');

  /// Check if string is a valid email (basic regex).
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  /// Return null if empty, otherwise the string itself.
  String? get nullIfEmpty => isEmpty ? null : this;

  Future<void> copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: this));
  }
}
extension USNumberFormatter on String {
  String toUSPhoneFormat({bool formatWithCode = false}) {
    // Remove everything except digits
    final digits = replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) return '';

    // Keep last 10 digits (US number)
    final cleaned = digits.length > 10
        ? digits.substring(digits.length - 10)
        : digits;

    final buffer = StringBuffer();

    for (int i = 0; i < cleaned.length; i++) {
      if (i == 0) {
        if (formatWithCode) buffer.write('+1 ');
        buffer.write('(');
      }

      if (i == 3) buffer.write(') ');
      if (i == 6) buffer.write('-');

      buffer.write(cleaned[i]);
    }

    return buffer.toString();
  }

   String get formatAsPhone {
    final digitsOnly = replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length >= 10) {
      final main = digitsOnly.substring(digitsOnly.length - 10);
      return '+1 (${main.substring(0, 3)}) ${main.substring(3, 6)}-${main.substring(6)}';
    }
    return this;
  }
}