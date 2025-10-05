import '../../features/favorites/models/favorite_hymn.dart';
import '../models/hymn.dart';

/// Abstract interface for hymn repository operations
/// Follows Interface Segregation Principle by defining specific contracts
abstract class IHymnRepository {
  Future<Hymn?> getHymnByNumber(String number);
  Future<List<Hymn>> getAllHymns();
  Future<List<Hymn>> searchHymns(String query);
}

/// Abstract interface for favorite operations
abstract class IFavoriteRepository {
  Future<List<FavoriteHymn>> getFavorites();
  Future<List<Hymn>> getFavoritesAsHymns();
  Future<void> addToFavorites(Hymn hymn);
  Future<void> removeFromFavorites(String hymnNumber);
  bool isFavorite(String hymnNumber);
}

/// Abstract interface for recently played operations
abstract class IRecentlyPlayedRepository {
  Future<List<Hymn>> getRecentlyPlayed();
  Future<void> addToRecentlyPlayed(Hymn hymn);
}
