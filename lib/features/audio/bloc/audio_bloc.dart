import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/audio_service.dart';

// Events
abstract class AudioEvent extends Equatable {
  const AudioEvent();

  @override
  List<Object?> get props => [];
}

class InitializeAudio extends AudioEvent {}

class PlayAudio extends AudioEvent {
  final String hymnNumber;

  const PlayAudio(this.hymnNumber);

  @override
  List<Object?> get props => [hymnNumber];
}

class PauseAudio extends AudioEvent {}

class ResumeAudio extends AudioEvent {}

class StopAudio extends AudioEvent {}

class SeekAudio extends AudioEvent {
  final Duration position;

  const SeekAudio(this.position);

  @override
  List<Object?> get props => [position];
}

class SetAudioVolume extends AudioEvent {
  final double volume;

  const SetAudioVolume(this.volume);

  @override
  List<Object?> get props => [volume];
}

class ClearAudioError extends AudioEvent {}

class RetryAudio extends AudioEvent {}

class UpdateAudioPosition extends AudioEvent {
  final Duration position;
  final Duration duration;
  final bool isPlaying;

  const UpdateAudioPosition({
    required this.position,
    required this.duration,
    required this.isPlaying,
  });

  @override
  List<Object?> get props => [position, duration, isPlaying];
}

// States
abstract class AudioState extends Equatable {
  const AudioState();

  @override
  List<Object?> get props => [];
}

class AudioInitial extends AudioState {}

class AudioLoaded extends AudioState {
  final AudioPlayerState playerState;
  final String? currentHymnNumber;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isPaused;
  final bool isLoading;
  final bool isRetrying;
  final String? lastError;
  final int retryCount;

  const AudioLoaded({
    required this.playerState,
    this.currentHymnNumber,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isPaused,
    required this.isLoading,
    required this.isRetrying,
    this.lastError,
    required this.retryCount,
  });

  @override
  List<Object?> get props => [
        playerState,
        currentHymnNumber,
        position,
        duration,
        isPlaying,
        isPaused,
        isLoading,
        isRetrying,
        lastError,
        retryCount,
      ];

  AudioLoaded copyWith({
    AudioPlayerState? playerState,
    String? currentHymnNumber,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isPaused,
    bool? isLoading,
    bool? isRetrying,
    String? lastError,
    int? retryCount,
  }) {
    return AudioLoaded(
      playerState: playerState ?? this.playerState,
      currentHymnNumber: currentHymnNumber ?? this.currentHymnNumber,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      isLoading: isLoading ?? this.isLoading,
      isRetrying: isRetrying ?? this.isRetrying,
      lastError: lastError ?? this.lastError,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

class AudioError extends AudioState {
  final String message;

  const AudioError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final AudioService _audioService = AudioService();

  AudioBloc() : super(AudioInitial()) {
    on<InitializeAudio>(_onInitializeAudio);
    on<PlayAudio>(_onPlayAudio);
    on<PauseAudio>(_onPauseAudio);
    on<ResumeAudio>(_onResumeAudio);
    on<StopAudio>(_onStopAudio);
    on<SeekAudio>(_onSeekAudio);
    on<SetAudioVolume>(_onSetAudioVolume);
    on<ClearAudioError>(_onClearAudioError);
    on<RetryAudio>(_onRetryAudio);
    on<UpdateAudioPosition>(_onUpdateAudioPosition);
  }

  void _onAudioServiceChanged() {
    // Logger().d(
    //     'AudioService changed - State: ${_audioService.state}, isPlaying: ${_audioService.isPlaying}, isLoading: ${_audioService.isLoading}');
    add(UpdateAudioPosition(
      position: _audioService.position,
      duration: _audioService.duration,
      isPlaying: _audioService.isPlaying,
    ));
  }

  Future<void> _onInitializeAudio(
      InitializeAudio event, Emitter<AudioState> emit) async {
    try {
      await _audioService.initialize();

      // Add listener after initialization
      _audioService.addListener(_onAudioServiceChanged);

      emit(AudioLoaded(
        playerState: _audioService.state,
        currentHymnNumber: _audioService.currentHymnNumber,
        position: _audioService.position,
        duration: _audioService.duration,
        isPlaying: _audioService.isPlaying,
        isPaused: _audioService.isPaused,
        isLoading: _audioService.isLoading,
        isRetrying: _audioService.isRetrying,
        lastError: _audioService.lastError,
        retryCount: _audioService.retryCount,
      ));
    } catch (e) {
      emit(AudioError(e.toString()));
    }
  }

  Future<void> _onPlayAudio(PlayAudio event, Emitter<AudioState> emit) async {
    try {
      final currentState = state;
      if (currentState is AudioLoaded) {
        // Immediately update UI to show loading state
        emit(currentState.copyWith(
          isLoading: true,
          currentHymnNumber: event.hymnNumber,
          playerState: AudioPlayerState.loading,
        ));
      }

      await _audioService.playHymn(event.hymnNumber);

      // The audio service will trigger _onAudioServiceChanged
      // which will emit the final state with correct values
    } catch (e) {
      emit(AudioError(e.toString()));
    }
  }

  Future<void> _onPauseAudio(PauseAudio event, Emitter<AudioState> emit) async {
    try {
      await _audioService.pause();
      final currentState = state;
      if (currentState is AudioLoaded) {
        emit(currentState.copyWith(
          playerState: _audioService.state,
          isPlaying: _audioService.isPlaying,
          isPaused: _audioService.isPaused,
        ));
      }
    } catch (e) {
      emit(AudioError(e.toString()));
    }
  }

  Future<void> _onResumeAudio(
      ResumeAudio event, Emitter<AudioState> emit) async {
    try {
      await _audioService.resume();
      final currentState = state;
      if (currentState is AudioLoaded) {
        emit(currentState.copyWith(
          playerState: _audioService.state,
          isPlaying: _audioService.isPlaying,
          isPaused: _audioService.isPaused,
        ));
      }
    } catch (e) {
      emit(AudioError(e.toString()));
    }
  }

  Future<void> _onStopAudio(StopAudio event, Emitter<AudioState> emit) async {
    try {
      await _audioService.stop();
      final currentState = state;
      if (currentState is AudioLoaded) {
        emit(currentState.copyWith(
          playerState: _audioService.state,
          currentHymnNumber: null,
          position: Duration.zero,
          isPlaying: false,
          isPaused: false,
        ));
      }
    } catch (e) {
      emit(AudioError(e.toString()));
    }
  }

  Future<void> _onSeekAudio(SeekAudio event, Emitter<AudioState> emit) async {
    try {
      await _audioService.seekTo(event.position);
      final currentState = state;
      if (currentState is AudioLoaded) {
        emit(currentState.copyWith(position: event.position));
      }
    } catch (e) {
      emit(AudioError(e.toString()));
    }
  }

  Future<void> _onSetAudioVolume(
      SetAudioVolume event, Emitter<AudioState> emit) async {
    try {
      await _audioService.setVolume(event.volume);
    } catch (e) {
      emit(AudioError(e.toString()));
    }
  }

  Future<void> _onClearAudioError(
      ClearAudioError event, Emitter<AudioState> emit) async {
    _audioService.clearError();
    final currentState = state;
    if (currentState is AudioLoaded) {
      emit(currentState.copyWith(lastError: null));
    }
  }

  Future<void> _onRetryAudio(RetryAudio event, Emitter<AudioState> emit) async {
    try {
      await _audioService.retryPlay();
    } catch (e) {
      emit(AudioError(e.toString()));
    }
  }

  Future<void> _onUpdateAudioPosition(
      UpdateAudioPosition event, Emitter<AudioState> emit) async {
    final currentState = state;
    if (currentState is AudioLoaded) {
      // Logger().d(
      //     'Updating audio position - Service state: ${_audioService.state}, isLoading: ${_audioService.isLoading}, isPlaying: ${_audioService.isPlaying}');
      emit(currentState.copyWith(
        position: event.position,
        duration: event.duration,
        isPlaying: event.isPlaying,
        playerState: _audioService.state,
        isLoading: _audioService.isLoading,
        isRetrying: _audioService.isRetrying,
        lastError: _audioService.lastError,
        retryCount: _audioService.retryCount,
      ));
    }
  }

  @override
  Future<void> close() {
    try {
      _audioService.removeListener(_onAudioServiceChanged);
    } catch (e) {
      // Listener might not have been added yet, ignore the error
    }
    return super.close();
  }
}
