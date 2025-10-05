enum FavoritesSortOption {
  numberAscending,
  numberDescending,
  dateAddedOldestFirst,
  dateAddedNewestFirst,
  titleAscending,
  titleDescending,
  authorAscending,
  authorDescending,
}

extension FavoritesSortOptionExtension on FavoritesSortOption {
  String get displayName {
    switch (this) {
      case FavoritesSortOption.numberAscending:
        return 'Number (Ascending)';
      case FavoritesSortOption.numberDescending:
        return 'Number (Descending)';
      case FavoritesSortOption.dateAddedOldestFirst:
        return 'Date Added (Oldest First)';
      case FavoritesSortOption.dateAddedNewestFirst:
        return 'Date Added (Newest First)';
      case FavoritesSortOption.titleAscending:
        return 'Title (A-Z)';
      case FavoritesSortOption.titleDescending:
        return 'Title (Z-A)';
      case FavoritesSortOption.authorAscending:
        return 'Author (A-Z)';
      case FavoritesSortOption.authorDescending:
        return 'Author (Z-A)';
    }
  }

  String get localizedKey {
    switch (this) {
      case FavoritesSortOption.numberAscending:
        return 'sortByNumber';
      case FavoritesSortOption.numberDescending:
        return 'sortByNumber';
      case FavoritesSortOption.dateAddedOldestFirst:
        return 'sortByDateAdded';
      case FavoritesSortOption.dateAddedNewestFirst:
        return 'sortByDateAdded';
      case FavoritesSortOption.titleAscending:
        return 'sortByTitle';
      case FavoritesSortOption.titleDescending:
        return 'sortByTitle';
      case FavoritesSortOption.authorAscending:
        return 'sortByAuthor';
      case FavoritesSortOption.authorDescending:
        return 'sortByAuthor';
    }
  }

  String get orderKey {
    switch (this) {
      case FavoritesSortOption.numberAscending:
      case FavoritesSortOption.titleAscending:
      case FavoritesSortOption.authorAscending:
        return 'sortAscending';
      case FavoritesSortOption.numberDescending:
      case FavoritesSortOption.titleDescending:
      case FavoritesSortOption.authorDescending:
        return 'sortDescending';
      case FavoritesSortOption.dateAddedOldestFirst:
        return 'sortOldestFirst';
      case FavoritesSortOption.dateAddedNewestFirst:
        return 'sortNewestFirst';
    }
  }
}
