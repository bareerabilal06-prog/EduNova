import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/services/connectivity_service.dart';

class ConnectivityProvider with ChangeNotifier {
  final ConnectivityService _service = ConnectivityService();
  bool _isOnline = false;

  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    _init();
  }

  void _init() async {
    // Check current status
    _isOnline = await _service.isOnline();
    notifyListeners();

    // Listen for real-time connectivity changes
    _service.connectivityStream.listen((result) {
      _isOnline = result != ConnectivityResult.none;
      notifyListeners();
    });
  }
}
