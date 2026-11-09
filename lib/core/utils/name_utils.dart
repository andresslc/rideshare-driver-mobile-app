class NameParts {
  final String firstName;
  final String? lastName;

  const NameParts({required this.firstName, this.lastName});

  String get fullName {
    final parts = <String>[firstName.trim(), lastName?.trim() ?? '']
        .where((part) => part.isNotEmpty);
    return parts.join(' ');
  }
}

NameParts splitFullName(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return const NameParts(firstName: '');
  }

  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return NameParts(firstName: parts.first);
  }

  return NameParts(
    firstName: parts.first,
    lastName: parts.sublist(1).join(' '),
  );
}

String composeFullName(String? firstName, String? lastName) {
  final parts = <String>[firstName?.trim() ?? '', lastName?.trim() ?? '']
      .where((part) => part.isNotEmpty);
  return parts.join(' ');
}

String fallbackDisplayName({
  String? firstName,
  String? lastName,
  String? legacyName,
  String fallback = '',
}) {
  final composed = composeFullName(firstName, lastName).trim();
  if (composed.isNotEmpty) return composed;

  final legacy = legacyName?.trim() ?? '';
  if (legacy.isNotEmpty) return legacy;

  return fallback;
}
