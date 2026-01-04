import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service responsible for monitoring network connectivity status.
/// Provides a reactive stream of connection state for offline-mode handling.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() => _instance;

  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionChangeController =
      StreamController<bool>.broadcast();

  // Track the last known status to avoid emitting duplicate events
  bool _lastConnectionStatus = true;

  /// Stream emitting `true` when connected and `false` when disconnected.
  Stream<bool> get connectivityStream => _connectionChangeController.stream;

  /// Initializes the service and starts monitoring network changes.
  /// Must be called in main() before running the app.
  Future<void> init() async {
    // Check initial status
    final initialResult = await _connectivity.checkConnectivity();
    _updateConnectionStatus(initialResult);

    // Listen for changes
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      _updateConnectionStatus(result);
    });
  }

  /// Checks the current connectivity status on demand.
  /// Returns `true` if the device has a network interface (WiFi, Cellular, etc.),
  /// `false` otherwise.
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _hasConnection(result);
  }

  /// Evaluates the connectivity result list to determine boolean status.
  /// Note: specific behavior depends on connectivity_plus version,
  /// this implementation supports the List<ConnectivityResult> return type (v6+).
  bool _hasConnection(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.none)) {
      return false;
    }

    // Check for valid connection types
    // We treat any network interface as "connected" for the purpose of the app logic.
    // Actual internet reachability is handled by API timeouts/errors.
    return result.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn,
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final bool isOnline = _hasConnection(result);

    // Only emit if status has changed
    if (isOnline != _lastConnectionStatus) {
      _lastConnectionStatus = isOnline;
      _connectionChangeController.add(isOnline);

      if (kDebugMode) {
        print(
          '🌐 [Connectivity] Status changed: ${isOnline ? "ONLINE" : "OFFLINE"}',
        );
      }
    } else {
      // Ensure the stream always has a value for new listeners (optional, usually handled by BehaviorSubject/Riverpod)
      // For a standard StreamController, we don't replay, but we assume providers watch this.
    }
  }

  /// Disposes resources if the service is no longer needed.
  /// (Rarely called as this service typically lives as long as the app).
  void dispose() {
    _connectionChangeController.close();
  }
}
