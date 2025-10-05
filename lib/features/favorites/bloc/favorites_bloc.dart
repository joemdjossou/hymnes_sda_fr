import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/models/hymn.dart';
import '../../../core/repositories/hybrid_favorites_repository.dart';
import '../../../core/repositories/i_hymn_repository.dart';
import '../../../core/services/posthog_service.dart';
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

class SyncFavorites extends FavoritesEvent {
  const SyncFavorites();
}

class ForceSyncFavorites extends FavoritesEvent {
  const ForceSyncFavorites();
}

class SetOnlineStatus extends FavoritesEvent {
  final bool isOnline;

  const SetOnlineStatus(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
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
  final bool isOnline;
  final bool isAuthenticated;
  final bool isSynced;

  const FavoritesLoaded({
    required this.favorites,
    required this.favoriteStatus,
    this.currentSortOption = FavoritesSortOption.dateAddedNewestFirst,
    this.isOnline = true,
    this.isAuthenticated = false,
    this.isSynced = true,
  });

  @override
  List<Object?> get props => [
        favorites,
        favoriteStatus,
        currentSortOption,
        isOnline,
        isAuthenticated,
        isSynced,
      ];

  FavoritesLoaded copyWith({
    List<Hymn>? favorites,
    Map<String, bool>? favoriteStatus,
    FavoritesSortOption? currentSortOption,
    bool? isOnline,
    bool? isAuthenticated,
    bool? isSynced,
  }) {
    return FavoritesLoaded(
      favorites: favorites ?? this.favorites,
      favoriteStatus: favoriteStatus ?? this.favoriteStatus,
      currentSortOption: currentSortOption ?? this.currentSortOption,
      isOnline: isOnline ?? this.isOnline,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isSynced: isSynced ?? this.isSynced,
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
  final HybridFavoritesRepository _hybridRepository;
  final PostHogService _posthog = PostHogService();

  FavoritesBloc({
    required IFavoriteRepository favoriteRepository,
    HybridFavoritesRepository? hybridRepository,
  })  : _hybridRepository = hybridRepository ?? HybridFavoritesRepository(),
        super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
    on<CheckFavoriteStatus>(_onCheckFavoriteStatus);
    on<SortFavorites>(_onSortFavorites);
    on<SyncFavorites>(_onSyncFavorites);
    on<ForceSyncFavorites>(_onForceSyncFavorites);
    on<SetOnlineStatus>(_onSetOnlineStatus);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      emit(FavoritesLoading());

      // Initialize hybrid repository if needed
      await _hybridRepository.initialize();

      final favoriteHymns = await _hybridRepository.getFavorites();
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

      // Get sync status
      final syncStatus = await _hybridRepository.getSyncStatus();

      emit(FavoritesLoaded(
        favorites: sortedFavorites,
        favoriteStatus: favoriteStatus,
        currentSortOption: FavoritesSortOption.dateAddedNewestFirst,
        isOnline: syncStatus['isOnline'] ?? true,
        isAuthenticated: syncStatus['isAuthenticated'] ?? false,
        isSynced: syncStatus['isSynced'] ?? true,
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
        await _hybridRepository.removeFromFavorites(hymn.number);

        // Track PostHog event
        await _posthog.trackFavoritesEvent(
          eventType: 'removed',
          hymnNumber: hymn.number,
          hymnTitle: hymn.title,
        );

        // Update state
        final updatedFavorites = currentState.favorites
            .where((h) => h.number != hymn.number)
            .toList();
        final updatedStatus =
            Map<String, bool>.from(currentState.favoriteStatus);
        updatedStatus[hymn.number] = false;

        // Get updated sync status
        final syncStatus = await _hybridRepository.getSyncStatus();

        emit(currentState.copyWith(
          favorites: updatedFavorites,
          favoriteStatus: updatedStatus,
          isSynced: syncStatus['isSynced'] ?? true,
        ));
      } else {
        await _hybridRepository.addToFavorites(hymn);

        // Track PostHog event
        await _posthog.trackFavoritesEvent(
          eventType: 'added',
          hymnNumber: hymn.number,
          hymnTitle: hymn.title,
        );

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
        await _hybridRepository.addToFavorites(hymn);

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
        await _hybridRepository.removeFromFavorites(hymnNumber);

        // Update state
        final updatedFavorites = currentState.favorites
            .where((h) => h.number != hymnNumber)
            .toList();
        final updatedStatus =
            Map<String, bool>.from(currentState.favoriteStatus);
        updatedStatus[hymnNumber] = false;

        // Get updated sync status
        final syncStatus = await _hybridRepository.getSyncStatus();

        emit(currentState.copyWith(
          favorites: updatedFavorites,
          favoriteStatus: updatedStatus,
          isSynced: syncStatus['isSynced'] ?? true,
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
      final isFavorite = _hybridRepository.isFavorite(hymnNumber);

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

      final favoriteHymns = await _hybridRepository.getFavorites();
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

  // New event handlers for sync operations
  Future<void> _onSyncFavorites(
    SyncFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! FavoritesLoaded) return;

      await _hybridRepository.forceSync();

      // Reload favorites after sync
      add(const LoadFavorites());
    } catch (e) {
      emit(FavoritesError('Failed to sync favorites: $e'));
    }
  }

  Future<void> _onForceSyncFavorites(
    ForceSyncFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! FavoritesLoaded) return;

      await _hybridRepository.forceSync();

      // Reload favorites after sync
      add(const LoadFavorites());
    } catch (e) {
      emit(FavoritesError('Failed to force sync favorites: $e'));
    }
  }

  Future<void> _onSetOnlineStatus(
    SetOnlineStatus event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! FavoritesLoaded) return;

      _hybridRepository.setOnlineStatus(event.isOnline);

      // Get updated sync status
      final syncStatus = await _hybridRepository.getSyncStatus();

      emit(currentState.copyWith(
        isOnline: event.isOnline,
        isSynced: syncStatus['isSynced'] ?? true,
      ));
    } catch (e) {
      emit(FavoritesError('Failed to set online status: $e'));
    }
  }

  // Helper method to check if a hymn is favorite
  bool isFavorite(String hymnNumber) {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      return currentState.favoriteStatus[hymnNumber] ?? false;
    }
    return _hybridRepository.isFavorite(hymnNumber);
  }
}
