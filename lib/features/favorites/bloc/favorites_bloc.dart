import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/models/hymn.dart';
import '../../../core/repositories/i_hymn_repository.dart';
import '../models/favorite_hymn.dart';
import '../models/favorites_sort_option.dart';

// Events
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoritesEvent {
  const LoadFavorites();
}

class ToggleFavorite extends FavoritesEvent {
  final Hymn hymn;

  const ToggleFavorite(this.hymn);

  @override
  List<Object?> get props => [hymn];
}

class AddToFavorites extends FavoritesEvent {
  final Hymn hymn;

  const AddToFavorites(this.hymn);

  @override
  List<Object?> get props => [hymn];
}

class RemoveFromFavorites extends FavoritesEvent {
  final String hymnNumber;

  const RemoveFromFavorites(this.hymnNumber);

  @override
  List<Object?> get props => [hymnNumber];
}

class CheckFavoriteStatus extends FavoritesEvent {
  final String hymnNumber;

  const CheckFavoriteStatus(this.hymnNumber);

  @override
  List<Object?> get props => [hymnNumber];
}

class SortFavorites extends FavoritesEvent {
  final FavoritesSortOption sortOption;

  const SortFavorites(this.sortOption);

  @override
  List<Object?> get props => [sortOption];
}

// States
abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Hymn> favorites;
  final Map<String, bool> favoriteStatus;
  final FavoritesSortOption currentSortOption;

  const FavoritesLoaded({
    required this.favorites,
    required this.favoriteStatus,
    this.currentSortOption = FavoritesSortOption.dateAddedNewestFirst,
  });

  @override
  List<Object?> get props => [favorites, favoriteStatus, currentSortOption];

  FavoritesLoaded copyWith({
    List<Hymn>? favorites,
    Map<String, bool>? favoriteStatus,
    FavoritesSortOption? currentSortOption,
  }) {
    return FavoritesLoaded(
      favorites: favorites ?? this.favorites,
      favoriteStatus: favoriteStatus ?? this.favoriteStatus,
      currentSortOption: currentSortOption ?? this.currentSortOption,
    );
  }
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final IFavoriteRepository _favoriteRepository;

  FavoritesBloc({
    required IFavoriteRepository favoriteRepository,
  })  : _favoriteRepository = favoriteRepository,
        super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
    on<CheckFavoriteStatus>(_onCheckFavoriteStatus);
    on<SortFavorites>(_onSortFavorites);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      emit(FavoritesLoading());

      final favoriteHymns = await _favoriteRepository.getFavorites();
      final favoriteStatus = <String, bool>{};
      final favorites = <Hymn>[];

      // Build favorite status map and hymns list
      for (final favoriteHymn in favoriteHymns) {
        favoriteStatus[favoriteHymn.hymn.number] = true;
        favorites.add(favoriteHymn.hymn);
      }

      // Sort favorites by default (newest first)
      final sortedFavorites = _sortFavorites(
          favoriteHymns, FavoritesSortOption.dateAddedNewestFirst);

      emit(FavoritesLoaded(
        favorites: sortedFavorites,
        favoriteStatus: favoriteStatus,
        currentSortOption: FavoritesSortOption.dateAddedNewestFirst,
      ));
    } catch (e) {
      emit(FavoritesError('Failed to load favorites: $e'));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! FavoritesLoaded) return;

      final hymn = event.hymn;
      final isCurrentlyFavorite =
          currentState.favoriteStatus[hymn.number] ?? false;

      if (isCurrentlyFavorite) {
        await _favoriteRepository.removeFromFavorites(hymn.number);

        // Update state
        final updatedFavorites = currentState.favorites
            .where((h) => h.number != hymn.number)
            .toList();
        final updatedStatus =
            Map<String, bool>.from(currentState.favoriteStatus);
        updatedStatus[hymn.number] = false;

        emit(currentState.copyWith(
          favorites: updatedFavorites,
          favoriteStatus: updatedStatus,
        ));
      } else {
        await _favoriteRepository.addToFavorites(hymn);

        // Reload favorites to get the updated list with proper sorting
        add(const LoadFavorites());
      }
    } catch (e) {
      emit(FavoritesError('Failed to toggle favorite: $e'));
    }
  }

  Future<void> _onAddToFavorites(
    AddToFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! FavoritesLoaded) return;

      final hymn = event.hymn;
      final isAlreadyFavorite =
          currentState.favoriteStatus[hymn.number] ?? false;

      if (!isAlreadyFavorite) {
        await _favoriteRepository.addToFavorites(hymn);

        // Reload favorites to get the updated list with proper sorting
        add(const LoadFavorites());
      }
    } catch (e) {
      emit(FavoritesError('Failed to add to favorites: $e'));
    }
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! FavoritesLoaded) return;

      final hymnNumber = event.hymnNumber;
      final isCurrentlyFavorite =
          currentState.favoriteStatus[hymnNumber] ?? false;

      if (isCurrentlyFavorite) {
        await _favoriteRepository.removeFromFavorites(hymnNumber);

        // Update state
        final updatedFavorites = currentState.favorites
            .where((h) => h.number != hymnNumber)
            .toList();
        final updatedStatus =
            Map<String, bool>.from(currentState.favoriteStatus);
        updatedStatus[hymnNumber] = false;

        emit(currentState.copyWith(
          favorites: updatedFavorites,
          favoriteStatus: updatedStatus,
        ));
      }
    } catch (e) {
      emit(FavoritesError('Failed to remove from favorites: $e'));
    }
  }

  Future<void> _onCheckFavoriteStatus(
    CheckFavoriteStatus event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! FavoritesLoaded) return;

      final hymnNumber = event.hymnNumber;
      final isFavorite = _favoriteRepository.isFavorite(hymnNumber);

      // Update favorite status without changing the favorites list
      final updatedStatus = Map<String, bool>.from(currentState.favoriteStatus);
      updatedStatus[hymnNumber] = isFavorite;

      emit(currentState.copyWith(favoriteStatus: updatedStatus));
    } catch (e) {
      emit(FavoritesError('Failed to check favorite status: $e'));
    }
  }

  Future<void> _onSortFavorites(
    SortFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! FavoritesLoaded) return;

      final favoriteHymns = await _favoriteRepository.getFavorites();
      final sortedFavorites = _sortFavorites(favoriteHymns, event.sortOption);

      emit(currentState.copyWith(
        favorites: sortedFavorites,
        currentSortOption: event.sortOption,
      ));
    } catch (e) {
      emit(FavoritesError('Failed to sort favorites: $e'));
    }
  }

  List<Hymn> _sortFavorites(
      List<FavoriteHymn> favoriteHymns, FavoritesSortOption sortOption) {
    final sortedHymns = <Hymn>[];

    switch (sortOption) {
      case FavoritesSortOption.numberAscending:
        favoriteHymns.sort((a, b) =>
            int.parse(a.hymn.number).compareTo(int.parse(b.hymn.number)));
        break;
      case FavoritesSortOption.numberDescending:
        favoriteHymns.sort((a, b) =>
            int.parse(b.hymn.number).compareTo(int.parse(a.hymn.number)));
        break;
      case FavoritesSortOption.dateAddedNewestFirst:
        favoriteHymns.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
        break;
      case FavoritesSortOption.dateAddedOldestFirst:
        favoriteHymns.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case FavoritesSortOption.titleAscending:
        favoriteHymns.sort((a, b) =>
            a.hymn.title.toLowerCase().compareTo(b.hymn.title.toLowerCase()));
        break;
      case FavoritesSortOption.titleDescending:
        favoriteHymns.sort((a, b) =>
            b.hymn.title.toLowerCase().compareTo(a.hymn.title.toLowerCase()));
        break;
      case FavoritesSortOption.authorAscending:
        favoriteHymns.sort((a, b) =>
            a.hymn.author.toLowerCase().compareTo(b.hymn.author.toLowerCase()));
        break;
      case FavoritesSortOption.authorDescending:
        favoriteHymns.sort((a, b) =>
            b.hymn.author.toLowerCase().compareTo(a.hymn.author.toLowerCase()));
        break;
    }

    for (final favoriteHymn in favoriteHymns) {
      sortedHymns.add(favoriteHymn.hymn);
    }

    return sortedHymns;
  }

  // Helper method to check if a hymn is favorite
  bool isFavorite(String hymnNumber) {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      return currentState.favoriteStatus[hymnNumber] ?? false;
    }
    return _favoriteRepository.isFavorite(hymnNumber);
  }
}
