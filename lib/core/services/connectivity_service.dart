// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/foundation.dart';

// import '../utils/app_log.dart';

// /// Lightweight connectivity checker — no third-party package needed.
// ///
// /// Tries a DNS lookup to determine if the device has internet.
// /// Listen to [isOnline] for reactive updates.
// class ConnectivityService {
//   ConnectivityService._();
//   static final ConnectivityService instance = ConnectivityService._();

//   final ValueNotifier<bool> isOnline = ValueNotifier(true);

//   Timer? _timer;

//   /// Start periodic checks every [interval].
//   void startMonitoring({Duration interval = const Duration(seconds: 5)}) {
//     _timer?.cancel();
//     _checkConnectivity(); // check immediately
//     _timer = Timer.periodic(interval, (_) => _checkConnectivity());
//   }

//   void stopMonitoring() {
//     _timer?.cancel();
//     _timer = null;
//   }

//   Future<bool> _checkConnectivity() async {
//     try {
//       final result = await InternetAddress.lookup(
//         'google.com',
//       ).timeout(const Duration(seconds: 5));
//       final connected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//       isOnline.value = connected;
//       return connected;
//     } catch (_) {
//       isOnline.value = false;
//       log('📡 No internet connection', name: 'Connectivity');
//       return false;
//     }
//   }

//   /// One-shot connectivity check.
//   Future<bool> get hasConnection => _checkConnectivity();

//   void dispose() {
//     stopMonitoring();
//     isOnline.dispose();
//   }
// }

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionChangeController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionChangeController.stream;

  bool _hasConnection = true;
  bool get lastStatus => _hasConnection;

  late StreamSubscription<List<ConnectivityResult>> _subscription;

  Future<void> initialize() async {
    final List<ConnectivityResult> result = await _connectivity
        .checkConnectivity();
    _checkStatus(result);
    _subscription = _connectivity.onConnectivityChanged.listen(_checkStatus);
  }

  void _checkStatus(List<ConnectivityResult> result) {
    bool previousConnection = _hasConnection;
    _hasConnection = !result.contains(ConnectivityResult.none);

    if (previousConnection != _hasConnection) {
      _connectionChangeController.add(_hasConnection);
    }
  }

  Future<bool> get hasConnection async {
    final List<ConnectivityResult> result = await _connectivity
        .checkConnectivity();
    _hasConnection = !result.contains(ConnectivityResult.none);
    return _hasConnection;
  }

  void dispose() {
    _subscription.cancel();
    _connectionChangeController.close();
  }
}
