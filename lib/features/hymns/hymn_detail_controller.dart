import 'package:flutter/foundation.dart';

import '../../core/models/hymn.dart';
import '../../core/repositories/i_hymn_repository.dart';

/// Controller for hymn detail screen following Single Responsibility Principle
/// Handles only business logic and state management
class HymnDetailController extends ChangeNotifier {
  final IHymnRepository _hymnRepository;
  final IFavoriteRepository _favoriteRepository;

  HymnDetailController({
    required IHymnRepository hymnRepository,
    required IFavoriteRepository favoriteRepository,
  })  : _hymnRepository = hymnRepository,
        _favoriteRepository = favoriteRepository;

  Hymn? _hymn;
  bool _isLoading = true;
  String? _error;

  // Getters
  Hymn? get hymn => _hymn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isFavorite =>
      _hymn != null ? _favoriteRepository.isFavorite(_hymn!.number) : false;

  /// Load hymn by number
  Future<void> loadHymn(String hymnId) async {
    _setLoading(true);
    _setError(null);

    try {
      final hymn = await _hymnRepository.getHymnByNumber(hymnId);
      _setHymn(hymn);
    } catch (e) {
      _setError('Error loading hymn: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite() async {
    if (_hymn == null) return;

    try {
      if (isFavorite) {
        await _favoriteRepository.removeFromFavorites(_hymn!.number);
      } else {
        await _favoriteRepository.addToFavorites(_hymn!);
      }
      notifyListeners(); // Notify UI of favorite status change
    } catch (e) {
      _setError('Error updating favorites: $e');
    }
  }

  // Private methods for state management
  void _setHymn(Hymn? hymn) {
    _hymn = hymn;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
