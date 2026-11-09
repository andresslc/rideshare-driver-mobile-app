import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/navigation/app_router.dart';
import 'package:flutter/services.dart';

class Validators {
  static final navigatorKey = rootNavigatorKey;
  static String? vinValidator(String? value) {
    final l10 = navigatorKey.currentContext?.l10n;
    final trimmed = (value ?? '').trim().toUpperCase();
    if (trimmed.isEmpty) {
      return l10?.profileFieldRequired;
    }
    if (trimmed.length != 17) {
      return l10?.profileVinInvalidLength;
    }
    if (!RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(trimmed)) {
      return l10?.profileVinInvalidFormat;
    }
    return null;
  }

  static String? Function(String?) get addressValidator => (value) {
    final l10n = navigatorKey.currentContext?.l10n;
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return l10n?.field_required;
    }

    if (text.length < 5) {
      return l10n?.minimum_5_characters_required;
    }

    // 123456
    if (RegExp(r'^\d+$').hasMatch(text)) {
      return l10n?.address_cannot_be_only_numbers;
    }

    // @#$%^&*
    if (RegExp(r"^[^A-Za-z0-9]+$", unicode: true).hasMatch(text)) {
      return l10n?.address_invalid;
    }

    return null;
  };

  static String? numberPlateValidator(String? value) {
    final l10 = navigatorKey.currentContext?.l10n;
    final trimmed = (value ?? '').trim().toUpperCase();
    if (trimmed.isEmpty) {
      return l10?.profileFieldRequired;
    }
    if (!RegExp(r'^[A-Z0-9]{1,7}$').hasMatch(trimmed)) {
      return l10?.profileNumberPlateInvalid;
    }
    return null;
  }

  static String? ssnValidator(String? value) {
    final l10 = navigatorKey.currentContext?.l10n;

    final raw = (value ?? '').replaceAll(RegExp(r'\D'), '');

    if (raw.isEmpty) {
      return l10?.field_required;
    }

    if (raw.length != 9) {
      return l10?.ssn_field_valid;
    }

    return null;
  }
  // static String? ssnValidator(String? value) {
  //   final trimmed = (value ?? '').trim();

  //   if (trimmed.isEmpty) {
  //     return "Field is required";
  //   }

  //   // Only digits, exactly 9
  //   if (!RegExp(r'^\d{8}$').hasMatch(trimmed)) {
  //     return "SSN must be exactly 8 digits";
  //   }

  //   return null;
  // }

  static String? licensePlateValidator(String? value) {
    return numberPlateValidator(value);
  }

  static String? registrationNumberValidator(String? value) {
    final l10 = navigatorKey.currentContext?.l10n;
    final trimmed = (value ?? '').trim().toUpperCase();
    if (trimmed.isEmpty) {
      return l10?.profileFieldRequired;
    }
    if (!RegExp(r'^[A-Z0-9]{1,8}$').hasMatch(trimmed)) {
      return l10?.profileRegistrationNumberInvalid;
    }
    return null;
  }

  static String? yearValidator(String? value) {
    final l10 = navigatorKey.currentContext?.l10n;

    if ((value ?? '').trim().isEmpty) {
      return l10?.profileFieldRequired;
    }

    final year = int.tryParse(value!);
    if (year == null || value.length != 4) {
      return l10?.profileEnterValidYear;
    }

    final currentYear = DateTime.now().year;
    final minAllowedYear = currentYear - 15;

    if (year < minAllowedYear) {
      return l10?.profileYearTooOld(minAllowedYear);
    }

    if (year > currentYear) {
      return l10?.profileYearFuture;
    }

    return null;
  }

  static String? Function(String?) get requiredFieldValidator => (value) {
    if ((value?.trim() ?? '').isEmpty) {
      return navigatorKey.currentContext?.l10n.field_required;
    }
    return null;
  };

  static String? Function(String?) get fullNameValidator => (value) {
    final trimmedValue = value?.trim() ?? '';

    if (trimmedValue.isEmpty) {
      return navigatorKey.currentContext?.l10n.field_required;
    }

    if (trimmedValue.length < 3) {
      return navigatorKey.currentContext?.l10n.name_min_length(
        3,
      ); // assumes you have l10n with param
    }

    if (RegExp(r'\d').hasMatch(trimmedValue)) {
      return navigatorKey.currentContext?.l10n.name_no_numbers;
    }

    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(trimmedValue)) {
      return navigatorKey.currentContext?.l10n.name_invalid_characters;
    }

    return null;
  };

  static String? Function(String?) get validateUSPhoneNumber => (value) {
    final trimmedValue = value?.trim() ?? '';

    // if (trimmedValue.isEmpty) {
    //   return navigatorKey.currentContext?.l10n.field_required;
    // }

    final digits = trimmedValue.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      return navigatorKey.currentContext?.l10n.phone_invalid;
    }

    return null;
  };

  static String? Function(String?) get emailValidator => (value) {
    final trimmedValue = value?.trim() ?? '';

    if (trimmedValue.isEmpty) {
      return navigatorKey.currentContext?.l10n.field_required;
    }

    final emailPattern = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!emailPattern.hasMatch(trimmedValue)) {
      return 'Enter a valid email address';
    }

    return null;
  };

  //
  static String? Function(String?) get licenseValidator => (value) {
    if ((value ?? '').trim().isEmpty) {
      return navigatorKey.currentContext?.l10n.profileFieldRequired;
    }
    if ((value?.length ?? 0) < 6) {
      return "License number is too short";
    }

    return null;
  };

  static String? Function(String?, double) get amountValidator =>
      (value, balance) {
        final trimmedValue = value?.trim() ?? '';
        if (trimmedValue.isEmpty) {
          return navigatorKey.currentContext?.l10n.field_required;
        }

        final amount = double.tryParse(trimmedValue);

        if (amount == null) {
          return navigatorKey.currentContext?.l10n.valid_amount;
        }

        if (amount <= 0) {
          return navigatorKey
              .currentContext
              ?.l10n
              .amount_must_be_greater_than_0;
        }
        if (amount > balance) {
          return navigatorKey.currentContext?.l10n.insufficient_balance;
        }

        // check max 2 decimal places
        if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(trimmedValue)) {
          return navigatorKey.currentContext?.l10n.max_2_decimal_places_allowed;
        }

        return null;
      };

  static String? Function(String?) get stateValidator => (value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return navigatorKey.currentContext?.l10n.field_required ??
          'Field is required';
    }

    final normalized = text.toLowerCase();
    final isFlorida = normalized == 'florida' || normalized == 'fl';

    if (!isFlorida) {
      return navigatorKey
              .currentContext
              ?.l10n
              .only_florida_addresses_supported ??
          'Only Florida (FL) addresses are supported';
    }

    return null;
  };
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
