import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

/// Service to monitor network connectivity status
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final Logger _logger = Logger();

  bool _isInitialized = false;
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Stream controllers for connectivity changes
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  /// Stream of connectivity changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Current connectivity status
  bool get isOnline => _isOnline;

  /// Initialize the connectivity service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set initial status optimistically
      _isOnline = true; // Assume online initially
      _logger.d('Connectivity service initializing...');

      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (error) {
          _logger.e('Connectivity stream error: $error');
        },
      );

      _isInitialized = true;
      _logger.d('Connectivity service initialized');

      // Check initial connectivity status asynchronously (non-blocking)
      _checkInitialConnectivity();
    } catch (e) {
      _logger.e('Error initializing connectivity service: $e');
      // Don't rethrow - allow app to continue without connectivity service
      _isInitialized = true;
    }
  }

  /// Check initial connectivity status asynchronously
  Future<void> _checkInitialConnectivity() async {
    try {
      // Add a small delay to prevent blocking the main thread
      await Future.delayed(const Duration(milliseconds: 100));

      final connectivityResults = await _connectivity.checkConnectivity();
      _isOnline = _hasInternetConnection(connectivityResults);
      _logger.d(
          'Initial connectivity status: ${_isOnline ? 'online' : 'offline'}');
    } catch (e) {
      _logger.e('Error checking initial connectivity: $e');
      // Keep the optimistic online status
    }
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = _hasInternetConnection(results);

    if (wasOnline != _isOnline) {
      _logger.d('Connectivity changed: ${_isOnline ? 'online' : 'offline'}');
      _connectivityController.add(_isOnline);
    }
  }

  /// Check if there's an internet connection
  bool _hasInternetConnection(List<ConnectivityResult> results) {
    // If no connectivity results, assume offline
    if (results.isEmpty) return false;

    // Check if any of the connectivity results indicate internet access
    for (final result in results) {
      switch (result) {
        case ConnectivityResult.wifi:
        case ConnectivityResult.mobile:
        case ConnectivityResult.ethernet:
        case ConnectivityResult.vpn:
        case ConnectivityResult.bluetooth:
        case ConnectivityResult.other:
          return true;
        case ConnectivityResult.none:
          continue;
      }
    }
    return false;
  }

  /// Check connectivity status manually
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isOnline = _hasInternetConnection(results);
      return _isOnline;
    } catch (e) {
      _logger.e('Error checking connectivity: $e');
      // Return current status as fallback
      return _isOnline;
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
    _isInitialized = false;
  }
}
