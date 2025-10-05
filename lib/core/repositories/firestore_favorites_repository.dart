import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../../features/favorites/models/favorite_hymn.dart';
import '../models/hymn.dart';
import 'i_hymn_repository.dart';

/// Firestore implementation of favorites repository
/// Stores favorites in Firestore with user authentication
class FirestoreFavoritesRepository implements IFavoriteRepository {
  static final FirestoreFavoritesRepository _instance =
      FirestoreFavoritesRepository._internal();
  factory FirestoreFavoritesRepository() => _instance;
  FirestoreFavoritesRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  static const String _collectionName = 'favorites';

  /// Get the current user's favorites collection reference
  CollectionReference<Map<String, dynamic>> get _userFavoritesCollection {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection(_collectionName);
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Future<List<FavoriteHymn>> getFavorites() async {
    try {
      if (!isAuthenticated) {
        _logger.w('User not authenticated, returning empty favorites');
        return [];
      }

      final querySnapshot = await _userFavoritesCollection.get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID
        return FavoriteHymn.fromJson(data);
      }).toList();
    } catch (e) {
      _logger.e('Error getting favorites from Firestore: $e');
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
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final favoriteData = {
        ...hymn.toJson(),
        'dateAdded': FieldValue.serverTimestamp(),
        'userId': currentUserId,
      };

      // Use hymn number as document ID for easy lookup
      await _userFavoritesCollection.doc(hymn.number).set(favoriteData);

      _logger.d('Added hymn ${hymn.number} to favorites in Firestore');
    } catch (e) {
      _logger.e('Error adding favorite to Firestore: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeFromFavorites(String hymnNumber) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      await _userFavoritesCollection.doc(hymnNumber).delete();

      _logger.d('Removed hymn $hymnNumber from favorites in Firestore');
    } catch (e) {
      _logger.e('Error removing favorite from Firestore: $e');
      rethrow;
    }
  }

  @override
  bool isFavorite(String hymnNumber) {
    // This is a synchronous method, but Firestore operations are async
    // We'll need to handle this differently in the hybrid repository
    throw UnsupportedError(
      'isFavorite is synchronous but Firestore operations are async. '
      'Use isFavoriteAsync instead.',
    );
  }

  /// Async version of isFavorite for Firestore
  Future<bool> isFavoriteAsync(String hymnNumber) async {
    try {
      if (!isAuthenticated) {
        return false;
      }

      final doc = await _userFavoritesCollection.doc(hymnNumber).get();
      return doc.exists;
    } catch (e) {
      _logger.e('Error checking favorite status in Firestore: $e');
      return false;
    }
  }

  /// Sync favorites from Firestore to local storage
  Future<void> syncToLocal(IFavoriteRepository localRepository) async {
    try {
      if (!isAuthenticated) {
        return;
      }

      final firestoreFavorites = await getFavorites();

      // Clear local favorites first
      final localFavorites = await localRepository.getFavorites();
      for (final favorite in localFavorites) {
        await localRepository.removeFromFavorites(favorite.hymn.number);
      }

      // Add Firestore favorites to local storage
      for (final favorite in firestoreFavorites) {
        await localRepository.addToFavorites(favorite.hymn);
      }

      _logger.d(
          'Synced ${firestoreFavorites.length} favorites from Firestore to local');
    } catch (e) {
      _logger.e('Error syncing favorites from Firestore to local: $e');
    }
  }

  /// Sync favorites from local storage to Firestore
  Future<void> syncFromLocal(IFavoriteRepository localRepository) async {
    try {
      if (!isAuthenticated) {
        return;
      }

      final localFavorites = await localRepository.getFavorites();

      // Clear Firestore favorites first
      final firestoreFavorites = await getFavorites();
      for (final favorite in firestoreFavorites) {
        await removeFromFavorites(favorite.hymn.number);
      }

      // Add local favorites to Firestore
      for (final favorite in localFavorites) {
        await addToFavorites(favorite.hymn);
      }

      _logger.d(
          'Synced ${localFavorites.length} favorites from local to Firestore');
    } catch (e) {
      _logger.e('Error syncing favorites from local to Firestore: $e');
    }
  }

  /// Listen to favorites changes in real-time
  Stream<List<FavoriteHymn>> get favoritesStream {
    if (!isAuthenticated) {
      return Stream.value([]);
    }

    return _userFavoritesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return FavoriteHymn.fromJson(data);
      }).toList();
    });
  }

  /// Get favorites count
  Future<int> getFavoritesCount() async {
    try {
      if (!isAuthenticated) {
        return 0;
      }

      final querySnapshot = await _userFavoritesCollection.get();
      return querySnapshot.docs.length;
    } catch (e) {
      _logger.e('Error getting favorites count: $e');
      return 0;
    }
  }

  /// Clear all favorites for the current user
  Future<void> clearAllFavorites() async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final batch = _firestore.batch();
      final querySnapshot = await _userFavoritesCollection.get();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _logger.d('Cleared all favorites for user');
    } catch (e) {
      _logger.e('Error clearing all favorites: $e');
      rethrow;
    }
  }
}
