import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/models/hymn.dart';
import '../../../core/repositories/i_hymn_repository.dart';

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

  const FavoritesLoaded({
    required this.favorites,
    required this.favoriteStatus,
  });

  @override
  List<Object?> get props => [favorites, favoriteStatus];

  FavoritesLoaded copyWith({
    List<Hymn>? favorites,
    Map<String, bool>? favoriteStatus,
  }) {
    return FavoritesLoaded(
      favorites: favorites ?? this.favorites,
      favoriteStatus: favoriteStatus ?? this.favoriteStatus,
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
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      emit(FavoritesLoading());

      final favorites = await _favoriteRepository.getFavorites();
      final favoriteStatus = <String, bool>{};

      // Build favorite status map for quick lookups
      for (final hymn in favorites) {
        favoriteStatus[hymn.number] = true;
      }

      emit(FavoritesLoaded(
        favorites: favorites,
        favoriteStatus: favoriteStatus,
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

        // Update state
        final updatedFavorites = [...currentState.favorites, hymn];
        final updatedStatus =
            Map<String, bool>.from(currentState.favoriteStatus);
        updatedStatus[hymn.number] = true;

        emit(currentState.copyWith(
          favorites: updatedFavorites,
          favoriteStatus: updatedStatus,
        ));
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

        // Update state
        final updatedFavorites = [...currentState.favorites, hymn];
        final updatedStatus =
            Map<String, bool>.from(currentState.favoriteStatus);
        updatedStatus[hymn.number] = true;

        emit(currentState.copyWith(
          favorites: updatedFavorites,
          favoriteStatus: updatedStatus,
        ));
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

  // Helper method to check if a hymn is favorite
  bool isFavorite(String hymnNumber) {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      return currentState.favoriteStatus[hymnNumber] ?? false;
    }
    return _favoriteRepository.isFavorite(hymnNumber);
  }
}
