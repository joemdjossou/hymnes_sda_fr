import 'package:logger/logger.dart';

import '../../features/favorites/models/favorite_hymn.dart';
import '../models/hymn.dart';
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
  final Logger _logger = Logger();

  bool _isInitialized = false;
  bool _isOnline = true;

  /// Initialize the hybrid repository
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // StorageService is already initialized in main.dart
      // No need to initialize it again here
      _isInitialized = true;
      _logger.d('Hybrid favorites repository initialized');
    } catch (e) {
      _logger.e('Error initializing hybrid favorites repository: $e');
      rethrow;
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
      final localFavorites = await _localStorage.getFavorites();

      // If online and authenticated, try to sync with Firestore
      if (_isOnline && isAuthenticated) {
        try {
          await _syncFavorites();
          // Return the synced favorites
          return await _localStorage.getFavorites();
        } catch (e) {
          _logger.w('Failed to sync with Firestore, using local favorites: $e');
        }
      }

      return localFavorites;
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

      // Always add to local storage first
      await _localStorage.addToFavorites(hymn);
      _logger.d('Added hymn ${hymn.number} to local favorites');

      // If online and authenticated, also add to Firestore
      if (_isOnline && isAuthenticated) {
        try {
          await _firestoreRepository.addToFavorites(hymn);
          _logger.d('Added hymn ${hymn.number} to Firestore favorites');
        } catch (e) {
          _logger.w('Failed to add to Firestore, will sync later: $e');
        }
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

      // Always remove from local storage first
      await _localStorage.removeFromFavorites(hymnNumber);
      _logger.d('Removed hymn $hymnNumber from local favorites');

      // If online and authenticated, also remove from Firestore
      if (_isOnline && isAuthenticated) {
        try {
          await _firestoreRepository.removeFromFavorites(hymnNumber);
          _logger.d('Removed hymn $hymnNumber from Firestore favorites');
        } catch (e) {
          _logger.w('Failed to remove from Firestore, will sync later: $e');
        }
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

  /// Sync favorites between local storage and Firestore
  Future<void> _syncFavorites() async {
    try {
      final localFavorites = await _localStorage.getFavorites();
      final firestoreFavorites = await _firestoreRepository.getFavorites();

      // Compare timestamps to determine which data is newer
      final localLastModified = _getLastModified(localFavorites);
      final firestoreLastModified = _getLastModified(firestoreFavorites);

      if (localLastModified.isAfter(firestoreLastModified)) {
        // Local data is newer, sync to Firestore
        await _syncLocalToFirestore(localFavorites);
        _logger.d('Synced local favorites to Firestore');
      } else if (firestoreLastModified.isAfter(localLastModified)) {
        // Firestore data is newer, sync to local
        await _syncFirestoreToLocal(firestoreFavorites);
        _logger.d('Synced Firestore favorites to local');
      }
      // If timestamps are equal, no sync needed
    } catch (e) {
      _logger.e('Error syncing favorites: $e');
      rethrow;
    }
  }

  /// Get the last modified timestamp from a list of favorites
  DateTime _getLastModified(List<FavoriteHymn> favorites) {
    if (favorites.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return favorites
        .map((f) => f.dateAdded)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// Sync local favorites to Firestore
  Future<void> _syncLocalToFirestore(List<FavoriteHymn> localFavorites) async {
    try {
      // Clear Firestore favorites first
      final firestoreFavorites = await _firestoreRepository.getFavorites();
      for (final favorite in firestoreFavorites) {
        await _firestoreRepository.removeFromFavorites(favorite.hymn.number);
      }

      // Add local favorites to Firestore
      for (final favorite in localFavorites) {
        await _firestoreRepository.addToFavorites(favorite.hymn);
      }
    } catch (e) {
      _logger.e('Error syncing local to Firestore: $e');
      rethrow;
    }
  }

  /// Sync Firestore favorites to local
  Future<void> _syncFirestoreToLocal(
      List<FavoriteHymn> firestoreFavorites) async {
    try {
      // Clear local favorites first
      final localFavorites = await _localStorage.getFavorites();
      for (final favorite in localFavorites) {
        await _localStorage.removeFromFavorites(favorite.hymn.number);
      }

      // Add Firestore favorites to local storage
      for (final favorite in firestoreFavorites) {
        await _localStorage.addToFavorites(favorite.hymn);
      }
    } catch (e) {
      _logger.e('Error syncing Firestore to local: $e');
      rethrow;
    }
  }

  /// Force sync with Firestore
  Future<void> forceSync() async {
    if (!isAuthenticated) {
      _logger.w('Cannot sync: user not authenticated');
      return;
    }

    try {
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

      // Add new favorites from Firestore
      for (final firestoreFavorite in firestoreFavorites) {
        if (!localNumbers.contains(firestoreFavorite.hymn.number)) {
          await _localStorage.addToFavorites(firestoreFavorite.hymn);
        }
      }
    } catch (e) {
      _logger.e('Error updating local storage from Firestore: $e');
    }
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final localCount = await getFavoritesCount();
      final firestoreCount =
          isAuthenticated ? await _firestoreRepository.getFavoritesCount() : 0;

      return {
        'localCount': localCount,
        'firestoreCount': firestoreCount,
        'isOnline': _isOnline,
        'isAuthenticated': isAuthenticated,
        'isSynced': localCount == firestoreCount,
      };
    } catch (e) {
      _logger.e('Error getting sync status: $e');
      return {
        'localCount': 0,
        'firestoreCount': 0,
        'isOnline': _isOnline,
        'isAuthenticated': isAuthenticated,
        'isSynced': false,
        'error': e.toString(),
      };
    }
  }
}
