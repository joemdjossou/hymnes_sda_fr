import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../repositories/hybrid_favorites_repository.dart';
import 'auth_service.dart';
import 'connectivity_service.dart';

/// Service to handle favorites synchronization with authentication
class FavoritesSyncService {
  static final FavoritesSyncService _instance =
      FavoritesSyncService._internal();
  factory FavoritesSyncService() => _instance;
  FavoritesSyncService._internal();

  final AuthService _authService = AuthService();
  final HybridFavoritesRepository _hybridRepository =
      HybridFavoritesRepository();
  final ConnectivityService _connectivityService = ConnectivityService();
  final Logger _logger = Logger();

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isInitialized = false;

  /// Initialize the sync service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _hybridRepository.initialize();

      // Initialize connectivity service (non-blocking)
      try {
        await _connectivityService.initialize();
      } catch (e) {
        _logger.w(
            'Connectivity service initialization failed, continuing without it: $e');
      }

      // Listen to authentication state changes
      _authSubscription =
          _authService.authStateChanges.listen(_onAuthStateChanged);

      // Listen to connectivity changes (only if connectivity service is available)
      try {
        _connectivitySubscription =
            _connectivityService.connectivityStream.listen(
          _onConnectivityChanged,
          onError: (error) {
            _logger.e('Connectivity stream error: $error');
          },
        );
      } catch (e) {
        _logger.w('Could not listen to connectivity changes: $e');
      }

      _isInitialized = true;
      _logger.d('Favorites sync service initialized');
    } catch (e) {
      _logger.e('Error initializing favorites sync service: $e');
      // Don't rethrow - allow app to continue without sync service
      _isInitialized = true;
    }
  }

  /// Handle authentication state changes
  Future<void> _onAuthStateChanged(User? user) async {
    try {
      if (user != null) {
        // User signed in - sync favorites if online
        _logger.d(
            'User signed in, checking if sync is needed for user: ${user.uid}');
        await _syncOnSignIn();
      } else {
        // User signed out - keep local favorites, no sync needed
        _logger.d('User signed out, keeping local favorites');
        await _handleSignOut();
      }
    } catch (e) {
      _logger.e('Error handling auth state change: $e');
    }
  }

  /// Handle connectivity changes
  Future<void> _onConnectivityChanged(bool isOnline) async {
    try {
      _logger.d('Connectivity changed: ${isOnline ? 'online' : 'offline'}');

      // Update the hybrid repository's online status
      _hybridRepository.setOnlineStatus(isOnline);

      // If we're back online and authenticated, trigger sync
      if (isOnline && isAuthenticated) {
        _logger.d('Back online and authenticated, triggering sync');
        await forceSync();
      }
    } catch (e) {
      _logger.e('Error handling connectivity change: $e');
    }
  }

  /// Sync favorites when user signs in
  Future<void> _syncOnSignIn() async {
    try {
      // Check if we're online before attempting sync
      final isOnline = _connectivityService.isOnline;

      if (isOnline) {
        // We're online - perform full bidirectional sync
        _logger.d('User signed in and online, performing full sync');
        await _hybridRepository.forceSync();
        _logger.d('Favorites synced on sign in');
      } else {
        // We're offline - just log that sync will happen when back online
        final localFavorites = await _hybridRepository.getFavorites();
        _logger.d(
            'User signed in but offline. ${localFavorites.length} local favorites will sync when back online');
      }
    } catch (e) {
      _logger.e('Error syncing favorites on sign in: $e');
    }
  }

  /// Handle sign out
  Future<void> _handleSignOut() async {
    try {
      // Don't clear local favorites, just stop cloud sync
      _logger.d('Handled sign out - local favorites preserved');
    } catch (e) {
      _logger.e('Error handling sign out: $e');
    }
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final syncStatus = await _hybridRepository.getSyncStatus();
      final user = _authService.currentUser;

      return {
        ...syncStatus,
        'userId': user?.uid,
        'userEmail': user?.email,
        'userDisplayName': user?.displayName,
      };
    } catch (e) {
      _logger.e('Error getting sync status: $e');
      return {
        'localCount': 0,
        'firestoreCount': 0,
        'isOnline': false,
        'isAuthenticated': false,
        'isSynced': false,
        'error': e.toString(),
      };
    }
  }

  /// Force sync favorites
  Future<void> forceSync() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      await _hybridRepository.forceSync();
      _logger.d('Force sync completed');
    } catch (e) {
      _logger.e('Error during force sync: $e');
      rethrow;
    }
  }

  /// Set online status
  void setOnlineStatus(bool isOnline) {
    _hybridRepository.setOnlineStatus(isOnline);
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _authService.isSignedIn;

  /// Get current user
  User? get currentUser => _authService.currentUser;

  /// Listen to real-time favorites changes
  Stream<List<dynamic>> get favoritesStream {
    if (!isAuthenticated) {
      return Stream.value([]);
    }
    return _hybridRepository.favoritesStream;
  }

  /// Dispose resources
  void dispose() {
    _authSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _connectivityService.dispose();
    _isInitialized = false;
  }
}
