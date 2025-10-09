import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  // Correct stream type
  Stream<ConnectivityResult> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  // Checks if the device currently has internet connectivity
  Future<bool> isOnline() async {
    var result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
