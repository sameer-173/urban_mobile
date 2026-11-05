import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;

  final ValueNotifier<bool> isOnline = ValueNotifier<bool>(true);
  final ValueNotifier<DateTime> lastChecked = ValueNotifier<DateTime>(DateTime.now());

  Timer? _pollingTimer;
  bool _forceOfflineForTesting = false;

  ConnectivityService._internal() {
    checkConnection();
    _startMonitoring();
  }

  void _startMonitoring() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      checkConnection();
    });
  }

  Future<bool> checkConnection() async {
    if (_forceOfflineForTesting) {
      isOnline.value = false;
      lastChecked.value = DateTime.now();
      return false;
    }

    try {
      final lookup = await InternetAddress.lookup('dns.google')
          .timeout(const Duration(seconds: 3));
      final connected = lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
      isOnline.value = connected;
    } on SocketException catch (_) {
      isOnline.value = false;
    } on TimeoutException catch (_) {
      isOnline.value = false;
    } catch (_) {
      isOnline.value = false;
    }

    lastChecked.value = DateTime.now();
    return isOnline.value;
  }

  void toggleSimulatedOffline() {
    _forceOfflineForTesting = !_forceOfflineForTesting;
    checkConnection();
  }

  bool get isSimulatedOffline => _forceOfflineForTesting;

  void dispose() {
    _pollingTimer?.cancel();
  }
}
