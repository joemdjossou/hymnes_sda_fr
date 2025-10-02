import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/hymn.dart';
import '../../../core/services/audio_service.dart';

// Events
abstract class AudioEvent extends Equatable {
  const AudioEvent();

  @override
  List<Object?> get props => [];
}

class InitializeAudio extends AudioEvent {}

class PlayHymn extends AudioEvent {
  final Hymn hymn;
  final String? voiceType;

  const PlayHymn(this.hymn, {this.voiceType});

  @override
  List<Object?> get props => [hymn, voiceType];
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

class ToggleAudioLoop extends AudioEvent {}

class UpdateAudioPosition extends AudioEvent {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isPaused;
  final bool isLoading;
  final double volume;
  final bool isLooping;

  const UpdateAudioPosition({
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isPaused,
    required this.isLoading,
    required this.volume,
    required this.isLooping,
  });

  @override
  List<Object?> get props => [
        position,
        duration,
        isPlaying,
        isPaused,
        isLoading,
        volume,
        isLooping,
      ];
}

// States
abstract class AudioState extends Equatable {
  const AudioState();

  @override
  List<Object?> get props => [];
}

class AudioInitial extends AudioState {}

class AudioLoaded extends AudioState {
  final Hymn? currentHymn;
  final bool isPlaying;
  final bool isPaused;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final double volume;
  final bool isLooping;
  final double progress;

  const AudioLoaded({
    this.currentHymn,
    required this.isPlaying,
    required this.isPaused,
    required this.isLoading,
    required this.position,
    required this.duration,
    required this.volume,
    required this.isLooping,
    required this.progress,
  });

  @override
  List<Object?> get props => [
        currentHymn,
        isPlaying,
        isPaused,
        isLoading,
        position,
        duration,
        volume,
        isLooping,
        progress,
      ];

  AudioLoaded copyWith({
    Hymn? currentHymn,
    bool? isPlaying,
    bool? isPaused,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? isLooping,
    double? progress,
  }) {
    return AudioLoaded(
      currentHymn: currentHymn ?? this.currentHymn,
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isLooping: isLooping ?? this.isLooping,
      progress: progress ?? this.progress,
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
    on<PlayHymn>(_onPlayHymn);
    on<PauseAudio>(_onPauseAudio);
    on<ResumeAudio>(_onResumeAudio);
    on<StopAudio>(_onStopAudio);
    on<SeekAudio>(_onSeekAudio);
    on<SetAudioVolume>(_onSetAudioVolume);
    on<ToggleAudioLoop>(_onToggleAudioLoop);
    on<UpdateAudioPosition>(_onUpdateAudioPosition);

    // Initialize audio service
    add(InitializeAudio());
  }

  void _onAudioServiceChanged() {
    add(UpdateAudioPosition(
      position: _audioService.position,
      duration: _audioService.duration,
      isPlaying: _audioService.isPlaying,
      isPaused: _audioService.isPaused,
      isLoading: _audioService.isLoading,
      volume: _audioService.volume,
      isLooping: _audioService.isLooping,
    ));
  }

  Future<void> _onInitializeAudio(
      InitializeAudio event, Emitter<AudioState> emit) async {
    try {
      await _audioService.initialize();
      
      // Listen to audio service changes
      _audioService.addListener(_onAudioServiceChanged);

      emit(AudioLoaded(
        currentHymn: null,
        isPlaying: _audioService.isPlaying,
        isPaused: _audioService.isPaused,
        isLoading: _audioService.isLoading,
        position: _audioService.position,
        duration: _audioService.duration,
        volume: _audioService.volume,
        isLooping: _audioService.isLooping,
        progress: _audioService.progress,
      ));
    } catch (e) {
      emit(AudioError(e.toString()));
    }
  }

  Future<void> _onPlayHymn(PlayHymn event, Emitter<AudioState> emit) async {
    try {
      final currentState = state;
      if (currentState is AudioLoaded) {
        emit(currentState.copyWith(
          currentHymn: event.hymn,
          isLoading: true,
        ));
      }

      String audioFile;
      switch (event.voiceType) {
        case 'soprano':
          audioFile = event.hymn.sopranoFile;
          break;
        case 'alto':
          audioFile = event.hymn.altoFile;
          break;
        case 'tenor':
          audioFile = event.hymn.tenorFile;
          break;
        case 'bass':
          audioFile = event.hymn.bassFile;
          break;
        default:
          audioFile = event.hymn.sopranoFile; // Default to soprano
      }

      await _audioService.play(audioFile);

      if (state is AudioLoaded) {
        final loadedState = state as AudioLoaded;
        emit(loadedState.copyWith(
          currentHymn: event.hymn,
          isPlaying: _audioService.isPlaying,
          isLoading: _audioService.isLoading,
        ));
      }
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
          currentHymn: null,
          isPlaying: false,
          isPaused: false,
          position: Duration.zero,
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
      final currentState = state;
      if (currentState is AudioLoaded) {
        emit(currentState.copyWith(volume: event.volume));
      }
    } catch (e) {
      emit(AudioError(e.toString()));
    }
  }

  Future<void> _onToggleAudioLoop(
      ToggleAudioLoop event, Emitter<AudioState> emit) async {
    try {
      await _audioService.toggleLoop();
      final currentState = state;
      if (currentState is AudioLoaded) {
        emit(currentState.copyWith(isLooping: _audioService.isLooping));
      }
    } catch (e) {
      emit(AudioError(e.toString()));
    }
  }

  Future<void> _onUpdateAudioPosition(
      UpdateAudioPosition event, Emitter<AudioState> emit) async {
    final currentState = state;
    if (currentState is AudioLoaded) {
      emit(currentState.copyWith(
        position: event.position,
        duration: event.duration,
        isPlaying: event.isPlaying,
        isPaused: event.isPaused,
        isLoading: event.isLoading,
        volume: event.volume,
        isLooping: event.isLooping,
        progress: _audioService.progress,
      ));
    }
  }

  String formatDuration(Duration duration) {
    return _audioService.formatDuration(duration);
  }

  @override
  Future<void> close() {
    _audioService.removeListener(_onAudioServiceChanged);
    _audioService.dispose();
    return super.close();
  }
}