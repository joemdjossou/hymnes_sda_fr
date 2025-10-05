import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/hymn.dart';
import '../../../core/repositories/hymn_repository.dart';

// Events
abstract class HymnsEvent extends Equatable {
  const HymnsEvent();

  @override
  List<Object?> get props => [];
}

class LoadHymns extends HymnsEvent {}

class SearchHymns extends HymnsEvent {
  final String query;

  const SearchHymns(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadFavorites extends HymnsEvent {}

class AddToFavorites extends HymnsEvent {
  final Hymn hymn;

  const AddToFavorites(this.hymn);

  @override
  List<Object?> get props => [hymn];
}

class RemoveFromFavorites extends HymnsEvent {
  final String hymnNumber;

  const RemoveFromFavorites(this.hymnNumber);

  @override
  List<Object?> get props => [hymnNumber];
}

class LoadRecentlyPlayed extends HymnsEvent {}

class AddToRecentlyPlayed extends HymnsEvent {
  final Hymn hymn;

  const AddToRecentlyPlayed(this.hymn);

  @override
  List<Object?> get props => [hymn];
}

// States
abstract class HymnsState extends Equatable {
  const HymnsState();

  @override
  List<Object?> get props => [];
}

class HymnsInitial extends HymnsState {}

class HymnsLoading extends HymnsState {}

class HymnsLoaded extends HymnsState {
  final List<Hymn> hymns;
  final List<Hymn> favorites;
  final List<Hymn> recentlyPlayed;
  final List<Hymn> searchResults;
  final String? searchQuery;

  const HymnsLoaded({
    required this.hymns,
    required this.favorites,
    required this.recentlyPlayed,
    required this.searchResults,
    this.searchQuery,
  });

  @override
  List<Object?> get props =>
      [hymns, favorites, recentlyPlayed, searchResults, searchQuery];

  HymnsLoaded copyWith({
    List<Hymn>? hymns,
    List<Hymn>? favorites,
    List<Hymn>? recentlyPlayed,
    List<Hymn>? searchResults,
    String? searchQuery,
  }) {
    return HymnsLoaded(
      hymns: hymns ?? this.hymns,
      favorites: favorites ?? this.favorites,
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class HymnsError extends HymnsState {
  final String message;

  const HymnsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class HymnsBloc extends Bloc<HymnsEvent, HymnsState> {
  final HymnRepository _hymnRepository;

  HymnsBloc({required HymnRepository hymnRepository})
      : _hymnRepository = hymnRepository,
        super(HymnsInitial()) {
    on<LoadHymns>(_onLoadHymns);
    on<SearchHymns>(_onSearchHymns);
    on<LoadFavorites>(_onLoadFavorites);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
    on<LoadRecentlyPlayed>(_onLoadRecentlyPlayed);
    on<AddToRecentlyPlayed>(_onAddToRecentlyPlayed);
  }

  Future<void> _onLoadHymns(LoadHymns event, Emitter<HymnsState> emit) async {
    try {
      emit(HymnsLoading());

      final hymns = await _hymnRepository.getAllHymns();
      final favorites = await _hymnRepository.getFavoritesAsHymns();
      final recentlyPlayed = await _hymnRepository.getRecentlyPlayed();

      emit(HymnsLoaded(
        hymns: hymns,
        favorites: favorites,
        recentlyPlayed: recentlyPlayed,
        searchResults: hymns,
      ));
    } catch (e) {
      emit(HymnsError(e.toString()));
    }
  }

  Future<void> _onSearchHymns(
      SearchHymns event, Emitter<HymnsState> emit) async {
    try {
      final currentState = state;
      if (currentState is HymnsLoaded) {
        final searchResults = await _hymnRepository.searchHymns(event.query);

        emit(currentState.copyWith(
          searchResults: searchResults,
          searchQuery: event.query.isEmpty ? null : event.query,
        ));
      }
    } catch (e) {
      emit(HymnsError(e.toString()));
    }
  }

  Future<void> _onLoadFavorites(
      LoadFavorites event, Emitter<HymnsState> emit) async {
    try {
      final currentState = state;
      if (currentState is HymnsLoaded) {
        final favorites = await _hymnRepository.getFavoritesAsHymns();

        emit(currentState.copyWith(favorites: favorites));
      }
    } catch (e) {
      emit(HymnsError(e.toString()));
    }
  }

  Future<void> _onAddToFavorites(
      AddToFavorites event, Emitter<HymnsState> emit) async {
    try {
      await _hymnRepository.addToFavorites(event.hymn);

      final currentState = state;
      if (currentState is HymnsLoaded) {
        final updatedFavorites = await _hymnRepository.getFavoritesAsHymns();

        emit(currentState.copyWith(favorites: updatedFavorites));
      }
    } catch (e) {
      emit(HymnsError(e.toString()));
    }
  }

  Future<void> _onRemoveFromFavorites(
      RemoveFromFavorites event, Emitter<HymnsState> emit) async {
    try {
      await _hymnRepository.removeFromFavorites(event.hymnNumber);

      final currentState = state;
      if (currentState is HymnsLoaded) {
        final updatedFavorites = await _hymnRepository.getFavoritesAsHymns();

        emit(currentState.copyWith(favorites: updatedFavorites));
      }
    } catch (e) {
      emit(HymnsError(e.toString()));
    }
  }

  Future<void> _onLoadRecentlyPlayed(
      LoadRecentlyPlayed event, Emitter<HymnsState> emit) async {
    try {
      final currentState = state;
      if (currentState is HymnsLoaded) {
        final recentlyPlayed = await _hymnRepository.getRecentlyPlayed();

        emit(currentState.copyWith(recentlyPlayed: recentlyPlayed));
      }
    } catch (e) {
      emit(HymnsError(e.toString()));
    }
  }

  Future<void> _onAddToRecentlyPlayed(
      AddToRecentlyPlayed event, Emitter<HymnsState> emit) async {
    try {
      await _hymnRepository.addToRecentlyPlayed(event.hymn);

      final currentState = state;
      if (currentState is HymnsLoaded) {
        final updatedRecentlyPlayed = await _hymnRepository.getRecentlyPlayed();

        emit(currentState.copyWith(recentlyPlayed: updatedRecentlyPlayed));
      }
    } catch (e) {
      emit(HymnsError(e.toString()));
    }
  }
}
