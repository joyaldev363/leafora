import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Contract for checking network connectivity state.
///
/// **Important Architectural Note:**
/// Connectivity status confirms whether a local network interface
/// (e.g., Wi-Fi, Cellular, Ethernet) is currently active and available.
/// It does **not** guarantee that a specific remote server or internet endpoint
/// is reachable, as local gateways or DNS servers might be down or behind captive portals.
abstract interface class NetworkInfo {
  /// Checks whether an active network interface is currently connected.
  Future<bool> get isConnected;

  /// Stream emitting connectivity availability changes.
  Stream<bool> get onConnectivityChanged;
}

/// Production implementation of [NetworkInfo] using [Connectivity].
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _hasActiveConnection(results);
    } catch (_) {
      // If connectivity lookup fails or state is unknown, safely return false.
      return false;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged
        .map(_hasActiveConnection)
        .distinct();
  }

  /// Determines whether any of the active connectivity results indicate
  /// an active network interface.
  static bool _hasActiveConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn,
    );
  }
}
