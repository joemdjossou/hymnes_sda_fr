import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/audio_service.dart';
import '../../../core/services/posthog_service.dart';

// Events
abstract class AudioEvent extends Equatable {
  const AudioEvent();

  @override
  List<Object?> get props => [];
}

class InitializeAudio extends AudioEvent {}

enum VoiceType {
  allVoices,
  soprano,
  alto,
  tenor,
  bass,
  countertenor,
  baritone,
}

class PlayAudio extends AudioEvent {
  final String hymnNumber;
  final VoiceType voiceType;
  final String? voiceFile;

  const PlayAudio(this.hymnNumber,
      {this.voiceType = VoiceType.allVoices, this.voiceFile});

  @override
  List<Object?> get props => [hymnNumber, voiceType, voiceFile];
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

class DisposeAudio extends AudioEvent {}

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
  final VoiceType currentVoiceType;
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
    this.currentVoiceType = VoiceType.allVoices,
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
        currentVoiceType,
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
    VoiceType? currentVoiceType,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isPaused,
    bool? isLoading,
    bool? isRetrying,
    String? lastError,
    int? retryCount,
    bool clearError = false,
    bool clearHymnNumber = false,
  }) {
    return AudioLoaded(
      playerState: playerState ?? this.playerState,
      currentHymnNumber: clearHymnNumber
          ? null
          : (currentHymnNumber ?? this.currentHymnNumber),
      currentVoiceType: currentVoiceType ?? this.currentVoiceType,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      isLoading: isLoading ?? this.isLoading,
      isRetrying: isRetrying ?? this.isRetrying,
      lastError: clearError ? null : (lastError ?? this.lastError),
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
  final AudioService _audioService;
  final PostHogService _posthog = PostHogService();
  bool _isDisposed = false;

  AudioBloc({AudioService? audioService})
      : _audioService = audioService ?? AudioService(),
        super(AudioInitial()) {
    on<InitializeAudio>(_onInitializeAudio);
    on<PlayAudio>(_onPlayAudio);
    on<PauseAudio>(_onPauseAudio);
    on<ResumeAudio>(_onResumeAudio);
    on<StopAudio>(_onStopAudio);
    on<SeekAudio>(_onSeekAudio);
    on<SetAudioVolume>(_onSetAudioVolume);
    on<ClearAudioError>(_onClearAudioError);
    on<RetryAudio>(_onRetryAudio);
    on<DisposeAudio>(_onDisposeAudio);
    on<UpdateAudioPosition>(_onUpdateAudioPosition);
  }

  void _onAudioServiceChanged() {
    if (_isDisposed) return;

    try {
      add(UpdateAudioPosition(
        position: _audioService.position,
        duration: _audioService.duration,
        isPlaying: _audioService.isPlaying,
      ));
    } catch (e) {
      // Ignore errors if disposed
      if (!_isDisposed) {
        add(UpdateAudioPosition(
          position: _audioService.position,
          duration: _audioService.duration,
          isPlaying: _audioService.isPlaying,
        ));
      }
    }
  }

  Future<void> _onInitializeAudio(
      InitializeAudio event, Emitter<AudioState> emit) async {
    if (_isDisposed) return;

    try {
      await _audioService.initialize();

      if (_isDisposed) return;

      // Add listener after initialization
      _audioService.addListener(_onAudioServiceChanged);

      if (_isDisposed) return;

      emit(AudioLoaded(
        playerState: _audioService.state,
        currentHymnNumber: _audioService.currentHymnNumber,
        currentVoiceType: _audioService.currentVoiceType,
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
      if (!_isDisposed) {
        emit(AudioError(e.toString()));
      }
    }
  }

  Future<void> _onPlayAudio(PlayAudio event, Emitter<AudioState> emit) async {
    if (_isDisposed) return;

    try {
      final currentState = state;
      if (currentState is AudioLoaded && !_isDisposed) {
        // Immediately update UI to show loading state
        emit(currentState.copyWith(
          isLoading: true,
          currentHymnNumber: event.hymnNumber,
          currentVoiceType: event.voiceType,
          playerState: AudioPlayerState.loading,
          clearError: true,
        ));
      }

      if (_isDisposed) return;

      await _audioService.playHymn(event.hymnNumber,
          voiceType: event.voiceType, voiceFile: event.voiceFile);

      // Track PostHog event
      await _posthog.trackAudioEvent(
        eventType: 'play',
        hymnNumber: event.hymnNumber,
        duration: _audioService.duration.inSeconds.toDouble(),
      );

      // The audio service will trigger _onAudioServiceChanged
      // which will emit the final state with correct values
    } catch (e) {
      if (!_isDisposed) {
        final currentState = state;
        if (currentState is AudioLoaded) {
          emit(currentState.copyWith(
            lastError: e.toString(),
            isLoading: false,
            playerState: AudioPlayerState.error,
          ));
        } else {
          emit(AudioError(e.toString()));
        }
      }
    }
  }

  Future<void> _onPauseAudio(PauseAudio event, Emitter<AudioState> emit) async {
    if (_isDisposed) return;

    try {
      await _audioService.pause();

      // Track PostHog event
      final currentState = state;
      if (currentState is AudioLoaded) {
        await _posthog.trackAudioEvent(
          eventType: 'pause',
          hymnNumber: currentState.currentHymnNumber,
          position: _audioService.position.inSeconds.toDouble(),
          duration: _audioService.duration.inSeconds.toDouble(),
        );
      }

      if (_isDisposed) return;

      if (currentState is AudioLoaded) {
        emit(currentState.copyWith(
          playerState: _audioService.state,
          isPlaying: _audioService.isPlaying,
          isPaused: _audioService.isPaused,
        ));
      }
    } catch (e) {
      if (!_isDisposed) {
        final currentState = state;
        if (currentState is AudioLoaded) {
          emit(currentState.copyWith(lastError: e.toString()));
        } else {
          emit(AudioError(e.toString()));
        }
      }
    }
  }

  Future<void> _onResumeAudio(
      ResumeAudio event, Emitter<AudioState> emit) async {
    if (_isDisposed) return;

    try {
      await _audioService.resume();

      if (_isDisposed) return;

      final currentState = state;
      if (currentState is AudioLoaded) {
        emit(currentState.copyWith(
          playerState: _audioService.state,
          isPlaying: _audioService.isPlaying,
          isPaused: _audioService.isPaused,
        ));
      }
    } catch (e) {
      if (!_isDisposed) {
        final currentState = state;
        if (currentState is AudioLoaded) {
          emit(currentState.copyWith(lastError: e.toString()));
        } else {
          emit(AudioError(e.toString()));
        }
      }
    }
  }

  Future<void> _onStopAudio(StopAudio event, Emitter<AudioState> emit) async {
    if (_isDisposed) return;

    try {
      await _audioService.stop();

      if (_isDisposed) return;

      final currentState = state;
      if (currentState is AudioLoaded) {
        emit(currentState.copyWith(
          playerState: _audioService.state,
          clearHymnNumber: true,
          position: Duration.zero,
          isPlaying: false,
          isPaused: false,
        ));
      }
    } catch (e) {
      if (!_isDisposed) {
        final currentState = state;
        if (currentState is AudioLoaded) {
          emit(currentState.copyWith(lastError: e.toString()));
        } else {
          emit(AudioError(e.toString()));
        }
      }
    }
  }

  Future<void> _onSeekAudio(SeekAudio event, Emitter<AudioState> emit) async {
    if (_isDisposed) return;

    try {
      await _audioService.seekTo(event.position);

      if (_isDisposed) return;

      final currentState = state;
      if (currentState is AudioLoaded) {
        emit(currentState.copyWith(position: event.position));
      }
    } catch (e) {
      if (!_isDisposed) {
        final currentState = state;
        if (currentState is AudioLoaded) {
          emit(currentState.copyWith(lastError: e.toString()));
        } else {
          emit(AudioError(e.toString()));
        }
      }
    }
  }

  Future<void> _onSetAudioVolume(
      SetAudioVolume event, Emitter<AudioState> emit) async {
    if (_isDisposed) return;

    try {
      await _audioService.setVolume(event.volume);
    } catch (e) {
      if (!_isDisposed) {
        final currentState = state;
        if (currentState is AudioLoaded) {
          emit(currentState.copyWith(lastError: e.toString()));
        } else {
          emit(AudioError(e.toString()));
        }
      }
    }
  }

  Future<void> _onClearAudioError(
      ClearAudioError event, Emitter<AudioState> emit) async {
    if (_isDisposed) return;

    try {
      _audioService.clearError();

      if (_isDisposed) return;

      final currentState = state;
      if (currentState is AudioLoaded) {
        emit(currentState.copyWith(clearError: true));
      }
    } catch (e) {
      // Ignore errors when clearing error
    }
  }

  Future<void> _onRetryAudio(RetryAudio event, Emitter<AudioState> emit) async {
    if (_isDisposed) return;

    try {
      await _audioService.retryPlay();
    } catch (e) {
      if (!_isDisposed) {
        final currentState = state;
        if (currentState is AudioLoaded) {
          emit(currentState.copyWith(lastError: e.toString()));
        } else {
          emit(AudioError(e.toString()));
        }
      }
    }
  }

  Future<void> _onDisposeAudio(
      DisposeAudio event, Emitter<AudioState> emit) async {
    await _cleanup();
  }

  Future<void> _onUpdateAudioPosition(
      UpdateAudioPosition event, Emitter<AudioState> emit) async {
    if (_isDisposed) return;

    final currentState = state;
    if (currentState is AudioLoaded) {
      emit(currentState.copyWith(
        position: event.position,
        duration: event.duration,
        isPlaying: event.isPlaying,
        currentVoiceType: _audioService.currentVoiceType,
        playerState: _audioService.state,
        isLoading: _audioService.isLoading,
        isRetrying: _audioService.isRetrying,
        lastError: _audioService.lastError,
        retryCount: _audioService.retryCount,
      ));
    }
  }

  Future<void> _cleanup() async {
    try {
      _audioService.removeListener(_onAudioServiceChanged);
      await _audioService.disposeAsync();
    } catch (e) {
      // Ignore errors during cleanup
    }
  }

  @override
  Future<void> close() async {
    _isDisposed = true;
    await _cleanup();
    return super.close();
  }
}
