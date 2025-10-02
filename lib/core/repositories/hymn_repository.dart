import '../models/hymn.dart';
import '../services/hymn_data_service.dart';
import '../services/storage_service.dart';
import 'i_hymn_repository.dart';

class HymnRepository
    implements IHymnRepository, IFavoriteRepository, IRecentlyPlayedRepository {
  static final HymnRepository _instance = HymnRepository._internal();
  factory HymnRepository() => _instance;
  HymnRepository._internal();

  final StorageService _storageService = StorageService();

  // In-memory cache for hymns
  List<Hymn>? _hymnsCache;

  // Get all hymns
  @override
  Future<List<Hymn>> getAllHymns() async {
    if (_hymnsCache != null) {
      return _hymnsCache!;
    }

    // Load hymns from the data source
    _hymnsCache = await _loadHymnsFromDataSource();
    return _hymnsCache!;
  }

  // Get hymn by number
  @override
  Future<Hymn?> getHymnByNumber(String number) async {
    final hymns = await getAllHymns();
    try {
      return hymns.firstWhere((hymn) => hymn.number == number);
    } catch (e) {
      return null;
    }
  }

  // Search hymns
  @override
  Future<List<Hymn>> searchHymns(String query) async {
    final hymns = await getAllHymns();
    if (query.isEmpty) return hymns;

    final lowercaseQuery = query.toLowerCase();
    return hymns.where((hymn) {
      return hymn.title.toLowerCase().contains(lowercaseQuery) ||
          hymn.lyrics.toLowerCase().contains(lowercaseQuery) ||
          hymn.author.toLowerCase().contains(lowercaseQuery) ||
          hymn.composer.toLowerCase().contains(lowercaseQuery) ||
          hymn.number.contains(lowercaseQuery);
    }).toList();
  }

  // Get favorites
  @override
  Future<List<Hymn>> getFavorites() async {
    return _storageService.getFavorites();
  }

  // Add to favorites
  @override
  Future<void> addToFavorites(Hymn hymn) async {
    await _storageService.addToFavorites(hymn);
  }

  // Remove from favorites
  @override
  Future<void> removeFromFavorites(String hymnNumber) async {
    await _storageService.removeFromFavorites(hymnNumber);
  }

  // Check if hymn is favorite
  @override
  bool isFavorite(String hymnNumber) {
    return _storageService.isFavorite(hymnNumber);
  }

  // Get recently played
  @override
  Future<List<Hymn>> getRecentlyPlayed() async {
    return _storageService.getRecentlyPlayed();
  }

  // Add to recently played
  @override
  Future<void> addToRecentlyPlayed(Hymn hymn) async {
    await _storageService.addToRecentlyPlayed(hymn);
  }

  // Clear cache
  void clearCache() {
    _hymnsCache = null;
  }

  // Load hymns from data source
  Future<List<Hymn>> _loadHymnsFromDataSource() async {
    return await HymnDataService().getHymns();
  }
}
