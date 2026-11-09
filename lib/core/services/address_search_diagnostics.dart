import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Local debugging only. A production destination remains a release dependency.
class AddressSearchDiagnostics {
  String version = '', build = '';
  Map<String, Object> sanitize(Map<String, Object> event) => {
    if (version.isNotEmpty) 'app_version': version,
    if (build.isNotEmpty) 'build_number': build,
    for (final entry in event.entries)
      if (const {
        'event',
        'application',
        'platform',
        'interaction',
        'field',
        'strategy',
        'method',
        'status',
        'elapsed_ms',
        'count',
        'reason',
        'category',
      }.contains(entry.key))
        entry.key: entry.value,
  };

  void observe(Map<String, Object> event) {
    if (kDebugMode)
      debugPrint(jsonEncode({'kind': 'address_search', ...sanitize(event)}));
  }
}
