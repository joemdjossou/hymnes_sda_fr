import '../../../core/models/hymn.dart';
import '../../../core/repositories/i_hymn_repository.dart';

/// Helper class for hymn navigation logic
/// Follows Single Responsibility Principle - only handles hymn navigation calculations
class HymnNavigationHelper {
  final IHymnRepository _hymnRepository;

  HymnNavigationHelper(this._hymnRepository);

  /// Get sorted hymns list
  Future<List<Hymn>> _getSortedHymns() async {
    final allHymns = await _hymnRepository.getAllHymns();
    if (allHymns.isEmpty) return [];

    // Sort hymns by number (convert to int for proper numeric sorting)
    final sortedHymns = List<Hymn>.from(allHymns)
      ..sort((a, b) {
        final aNum = int.tryParse(a.number) ?? 0;
        final bNum = int.tryParse(b.number) ?? 0;
        return aNum.compareTo(bNum);
      });

    return sortedHymns;
  }

  /// Get the previous hymn number
  Future<String?> getPreviousHymnNumber(String currentHymnId) async {
    try {
      final sortedHymns = await _getSortedHymns();
      if (sortedHymns.isEmpty) return null;

      final currentIndex = sortedHymns.indexWhere(
        (hymn) => hymn.number == currentHymnId,
      );

      if (currentIndex == -1 || currentIndex == 0) {
        return null; // No previous hymn
      }

      return sortedHymns[currentIndex - 1].number;
    } catch (e) {
      return null;
    }
  }

  /// Get the next hymn number
  Future<String?> getNextHymnNumber(String currentHymnId) async {
    try {
      final sortedHymns = await _getSortedHymns();
      if (sortedHymns.isEmpty) return null;

      final currentIndex = sortedHymns.indexWhere(
        (hymn) => hymn.number == currentHymnId,
      );

      if (currentIndex == -1 || currentIndex == sortedHymns.length - 1) {
        return null; // No next hymn
      }

      return sortedHymns[currentIndex + 1].number;
    } catch (e) {
      return null;
    }
  }
}

