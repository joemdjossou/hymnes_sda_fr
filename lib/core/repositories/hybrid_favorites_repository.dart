import 'package:logger/logger.dart';

import '../../features/favorites/models/favorite_hymn.dart';
import '../models/hymn.dart';
import '../services/connectivity_service.dart';
import '../services/pending_operations_service.dart';
import '../services/storage_service.dart';
import 'firestore_favorites_repository.dart';
import 'i_hymn_repository.dart';

/// Hybrid favorites repository that combines local storage with Firestore
/// Provides offline-first functionality with cloud sync
class HybridFavoritesRepository implements IFavoriteRepository {
  static final HybridFavoritesRepository _instance =
      HybridFavoritesRepository._internal();
  factory HybridFavoritesRepository() => _instance;
  HybridFavoritesRepository._internal();

  final StorageService _localStorage = StorageService();
  final FirestoreFavoritesRepository _firestoreRepository =
      FirestoreFavoritesRepository();
  final ConnectivityService _connectivityService = ConnectivityService();
  final PendingOperationsService _pendingOperationsService =
      PendingOperationsService();
  final Logger _logger = Logger();

  bool _isInitialized = false;
  bool _isOnline = true;

  /// Initialize the hybrid repository
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize connectivity service (non-blocking)
      try {
        await _connectivityService.initialize();

        // Listen to connectivity changes
        _connectivityService.connectivityStream.listen((isOnline) {
          _isOnline = isOnline;
          _logger
              .d('Network status changed: ${isOnline ? 'online' : 'offline'}');

          // If we're back online and authenticated, process pending operations
          if (isOnline && isAuthenticated) {
            _processPendingOperations();
          }
        });
      } catch (e) {
        _logger.w(
            'Connectivity service initialization failed, continuing without it: $e');
        // Set default online status
        _isOnline = true;
      }

      _isInitialized = true;
      _logger.d('Hybrid favorites repository initialized');
    } catch (e) {
      _logger.e('Error initializing hybrid favorites repository: $e');
      // Don't rethrow - allow app to continue without full functionality
      _isInitialized = true;
    }
  }

  /// Set online status
  void setOnlineStatus(bool isOnline) {
    _isOnline = isOnline;
    _logger.d('Network status changed: ${isOnline ? 'online' : 'offline'}');
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _firestoreRepository.isAuthenticated;

  @override
  Future<List<FavoriteHymn>> getFavorites() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Always get from local storage first (offline-first approach)
      // No automatic sync on read - sync only happens on user actions or login
      return await _localStorage.getFavorites();
    } catch (e) {
      _logger.e('Error getting favorites: $e');
      return [];
    }
  }

  @override
  Future<List<Hymn>> getFavoritesAsHymns() async {
    final favorites = await getFavorites();
    return favorites.map((favorite) => favorite.hymn).toList();
  }

  @override
  Future<void> addToFavorites(Hymn hymn) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Always add to local storage first (offline-first approach)
      await _localStorage.addToFavorites(hymn);
      _logger.d('Added hymn ${hymn.number} to local favorites');

      if (isAuthenticated) {
        if (_isOnline) {
          // User is authenticated and online - sync immediately
          try {
            await _firestoreRepository.addToFavorites(hymn);
            _logger.d('Added hymn ${hymn.number} to Firestore favorites');
          } catch (e) {
            _logger.w('Failed to add to Firestore, will retry later: $e');
            // Add to pending operations for later sync
            await _pendingOperationsService.addPendingOperation(
              PendingOperation(
                hymnNumber: hymn.number,
                type: PendingOperationType.ADD,
                hymn: hymn,
              ),
            );
          }
        } else {
          // User is authenticated but offline - add to pending operations
          _logger.d(
              'User offline, adding to pending operations for hymn ${hymn.number}');
          await _pendingOperationsService.addPendingOperation(
            PendingOperation(
              hymnNumber: hymn.number,
              type: PendingOperationType.ADD,
              hymn: hymn,
            ),
          );
        }
      } else {
        // User not authenticated - only local storage (no sync needed)
        _logger.d(
            'User not authenticated, only stored locally for hymn ${hymn.number}');
      }
    } catch (e) {
      _logger.e('Error adding to favorites: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeFromFavorites(String hymnNumber) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Always remove from local storage first (offline-first approach)
      await _localStorage.removeFromFavorites(hymnNumber);
      _logger.d('Removed hymn $hymnNumber from local favorites');

      if (isAuthenticated) {
        if (_isOnline) {
          // User is authenticated and online - sync immediately
          try {
            await _firestoreRepository.removeFromFavorites(hymnNumber);
            _logger.d('Removed hymn $hymnNumber from Firestore favorites');
          } catch (e) {
            _logger.w('Failed to remove from Firestore, will retry later: $e');
            // Add to pending operations for later sync
            await _pendingOperationsService.addPendingOperation(
              PendingOperation(
                hymnNumber: hymnNumber,
                type: PendingOperationType.REMOVE,
              ),
            );
          }
        } else {
          // User is authenticated but offline - add to pending operations
          _logger.d(
              'User offline, adding remove operation to pending for hymn $hymnNumber');
          await _pendingOperationsService.addPendingOperation(
            PendingOperation(
              hymnNumber: hymnNumber,
              type: PendingOperationType.REMOVE,
            ),
          );
        }
      } else {
        // User not authenticated - only local storage (no sync needed)
        _logger.d(
            'User not authenticated, only removed locally for hymn $hymnNumber');
      }
    } catch (e) {
      _logger.e('Error removing from favorites: $e');
      rethrow;
    }
  }

  @override
  bool isFavorite(String hymnNumber) {
    // Use local storage for synchronous check
    return _localStorage.isFavorite(hymnNumber);
  }

  /// Process pending operations when back online
  Future<void> _processPendingOperations() async {
    try {
      final pendingOperations =
          await _pendingOperationsService.getPendingOperations();
      if (pendingOperations.isEmpty) return;

      _logger.d('Processing ${pendingOperations.length} pending operations');

      for (final operation in pendingOperations) {
        try {
          if (operation.type == PendingOperationType.ADD &&
              operation.hymn != null) {
            await _firestoreRepository.addToFavorites(operation.hymn!);
            _logger.d(
                'Synced pending ADD operation for hymn ${operation.hymnNumber}');
          } else if (operation.type == PendingOperationType.REMOVE) {
            await _firestoreRepository
                .removeFromFavorites(operation.hymnNumber);
            _logger.d(
                'Synced pending REMOVE operation for hymn ${operation.hymnNumber}');
          }

          // Remove the operation from pending list
          await _pendingOperationsService
              .removePendingOperation(operation.hymnNumber);
        } catch (e) {
          _logger.e(
              'Failed to process pending operation for hymn ${operation.hymnNumber}: $e');
          // Keep the operation in pending list for next retry
        }
      }
    } catch (e) {
      _logger.e('Error processing pending operations: $e');
    }
  }

  /// Sync favorites between local storage and Firestore
  Future<void> _syncFavorites() async {
    try {
      final localFavorites = await _localStorage.getFavorites();
      final firestoreFavorites = await _firestoreRepository.getFavorites();

      // Get sets of hymn numbers for comparison
      final localHymnNumbers = localFavorites.map((f) => f.hymn.number).toSet();
      final firestoreHymnNumbers =
          firestoreFavorites.map((f) => f.hymn.number).toSet();

      // Find hymns that exist in local but not in Firestore
      final localOnlyHymns = localHymnNumbers.difference(firestoreHymnNumbers);
      for (final hymnNumber in localOnlyHymns) {
        final localFavorite =
            localFavorites.firstWhere((f) => f.hymn.number == hymnNumber);
        await _firestoreRepository.addToFavorites(localFavorite.hymn);
        _logger.d('Synced local-only hymn $hymnNumber to Firestore');
      }

      // Find hymns that exist in Firestore but not in local
      final firestoreOnlyHymns =
          firestoreHymnNumbers.difference(localHymnNumbers);
      for (final hymnNumber in firestoreOnlyHymns) {
        final firestoreFavorite =
            firestoreFavorites.firstWhere((f) => f.hymn.number == hymnNumber);
        await _localStorage.addToFavorites(firestoreFavorite.hymn);
        _logger.d('Synced Firestore-only hymn $hymnNumber to local');
      }

      _logger.d('Bidirectional sync completed');
    } catch (e) {
      _logger.e('Error syncing favorites: $e');
      rethrow;
    }
  }

  /// Force sync with Firestore
  Future<void> forceSync() async {
    if (!isAuthenticated) {
      _logger.w('Cannot sync: user not authenticated');
      return;
    }

    if (!_isOnline) {
      _logger.w('Cannot sync: device is offline');
      return;
    }

    try {
      // First process any pending operations
      await _processPendingOperations();

      // Then perform bidirectional sync
      await _syncFavorites();
      _logger.d('Force sync completed');
    } catch (e) {
      _logger.e('Error during force sync: $e');
      rethrow;
    }
  }

  /// Get favorites count
  Future<int> getFavoritesCount() async {
    final favorites = await getFavorites();
    return favorites.length;
  }

  /// Get sync status information
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final localFavorites = await _localStorage.getFavorites();
      final firestoreFavorites = isAuthenticated && _isOnline
          ? await _firestoreRepository.getFavorites()
          : <FavoriteHymn>[];
      final pendingOperations =
          await _pendingOperationsService.getPendingOperations();

      return {
        'localCount': localFavorites.length,
        'firestoreCount': firestoreFavorites.length,
        'pendingOperationsCount': pendingOperations.length,
        'isOnline': _isOnline,
        'isAuthenticated': isAuthenticated,
        'isSynced': pendingOperations.isEmpty &&
            localFavorites.length == firestoreFavorites.length,
      };
    } catch (e) {
      _logger.e('Error getting sync status: $e');
      return {
        'localCount': 0,
        'firestoreCount': 0,
        'pendingOperationsCount': 0,
        'isOnline': false,
        'isAuthenticated': false,
        'isSynced': false,
        'error': e.toString(),
      };
    }
  }

  /// Clear all favorites
  Future<void> clearAllFavorites() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Clear local storage
      final localFavorites = await _localStorage.getFavorites();
      for (final favorite in localFavorites) {
        await _localStorage.removeFromFavorites(favorite.hymn.number);
      }

      // Clear Firestore if online and authenticated
      if (_isOnline && isAuthenticated) {
        try {
          await _firestoreRepository.clearAllFavorites();
        } catch (e) {
          _logger.w('Failed to clear Firestore favorites: $e');
        }
      }

      _logger.d('Cleared all favorites');
    } catch (e) {
      _logger.e('Error clearing all favorites: $e');
      rethrow;
    }
  }

  /// Listen to real-time favorites changes from Firestore
  Stream<List<FavoriteHymn>> get favoritesStream {
    if (!isAuthenticated) {
      return Stream.value([]);
    }

    return _firestoreRepository.favoritesStream.map((firestoreFavorites) {
      // Update local storage when Firestore changes
      _updateLocalFromFirestore(firestoreFavorites);
      return firestoreFavorites;
    });
  }

  /// Update local storage based on Firestore data
  Future<void> _updateLocalFromFirestore(
      List<FavoriteHymn> firestoreFavorites) async {
    try {
      // Get current local favorites
      final localFavorites = await _localStorage.getFavorites();
      final localNumbers = localFavorites.map((f) => f.hymn.number).toSet();
      final firestoreNumbers =
          firestoreFavorites.map((f) => f.hymn.number).toSet();

      // Remove favorites that are no longer in Firestore
      for (final localFavorite in localFavorites) {
        if (!firestoreNumbers.contains(localFavorite.hymn.number)) {
          await _localStorage.removeFromFavorites(localFavorite.hymn.number);
        }
      }

      // Add only new favorites from Firestore (skip existing ones)
      final toAdd = firestoreNumbers.difference(localNumbers);
      for (final firestoreFavorite in firestoreFavorites) {
        if (toAdd.contains(firestoreFavorite.hymn.number)) {
          await _localStorage.addToFavorites(firestoreFavorite.hymn);
        }
      }
    } catch (e) {
      _logger.e('Error updating local storage from Firestore: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivityService.dispose();
    _isInitialized = false;
  }
}
