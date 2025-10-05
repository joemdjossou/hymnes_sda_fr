import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../repositories/hybrid_favorites_repository.dart';
import 'auth_service.dart';

/// Service to handle favorites synchronization with authentication
class FavoritesSyncService {
  static final FavoritesSyncService _instance =
      FavoritesSyncService._internal();
  factory FavoritesSyncService() => _instance;
  FavoritesSyncService._internal();

  final AuthService _authService = AuthService();
  final HybridFavoritesRepository _hybridRepository =
      HybridFavoritesRepository();
  final Logger _logger = Logger();

  StreamSubscription<User?>? _authSubscription;
  bool _isInitialized = false;

  /// Initialize the sync service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _hybridRepository.initialize();

      // Listen to authentication state changes
      _authSubscription =
          _authService.authStateChanges.listen(_onAuthStateChanged);

      _isInitialized = true;
      _logger.d('Favorites sync service initialized');
    } catch (e) {
      _logger.e('Error initializing favorites sync service: $e');
      rethrow;
    }
  }

  /// Handle authentication state changes
  Future<void> _onAuthStateChanged(User? user) async {
    try {
      if (user != null) {
        // User signed in - sync favorites
        _logger.d('User signed in, syncing favorites for user: ${user.uid}');
        await _syncOnSignIn();
      } else {
        // User signed out - clear cloud sync but keep local favorites
        _logger.d('User signed out, keeping local favorites');
        await _handleSignOut();
      }
    } catch (e) {
      _logger.e('Error handling auth state change: $e');
    }
  }

  /// Sync favorites when user signs in
  Future<void> _syncOnSignIn() async {
    try {
      // Force sync to ensure local and cloud are in sync
      await _hybridRepository.forceSync();
      _logger.d('Favorites synced on sign in');
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
    _isInitialized = false;
  }
}
