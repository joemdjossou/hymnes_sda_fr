import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/midi_service.dart';

// Events
abstract class MidiEvent extends Equatable {
  const MidiEvent();

  @override
  List<Object?> get props => [];
}

class InitializeMidi extends MidiEvent {}

class PlayMidi extends MidiEvent {
  final String midiFileName;

  const PlayMidi(this.midiFileName);

  @override
  List<Object?> get props => [midiFileName];
}

class PauseMidi extends MidiEvent {}

class ResumeMidi extends MidiEvent {}

class StopMidi extends MidiEvent {}

class SeekMidi extends MidiEvent {
  final Duration position;

  const SeekMidi(this.position);

  @override
  List<Object?> get props => [position];
}

class SetMidiVolume extends MidiEvent {
  final double volume;

  const SetMidiVolume(this.volume);

  @override
  List<Object?> get props => [volume];
}

class ClearMidiError extends MidiEvent {}

class UpdateMidiPosition extends MidiEvent {
  final Duration position;
  final Duration duration;
  final bool isPlaying;

  const UpdateMidiPosition({
    required this.position,
    required this.duration,
    required this.isPlaying,
  });

  @override
  List<Object?> get props => [position, duration, isPlaying];
}

// States
abstract class MidiState extends Equatable {
  const MidiState();

  @override
  List<Object?> get props => [];
}

class MidiInitial extends MidiState {}

class MidiLoaded extends MidiState {
  final MidiPlayerState playerState;
  final String? currentMidiFile;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isPaused;
  final bool isLoading;
  final String? lastError;

  const MidiLoaded({
    required this.playerState,
    this.currentMidiFile,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isPaused,
    required this.isLoading,
    this.lastError,
  });

  @override
  List<Object?> get props => [
        playerState,
        currentMidiFile,
        position,
        duration,
        isPlaying,
        isPaused,
        isLoading,
        lastError,
      ];

  MidiLoaded copyWith({
    MidiPlayerState? playerState,
    String? currentMidiFile,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isPaused,
    bool? isLoading,
    String? lastError,
  }) {
    return MidiLoaded(
      playerState: playerState ?? this.playerState,
      currentMidiFile: currentMidiFile ?? this.currentMidiFile,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      isLoading: isLoading ?? this.isLoading,
      lastError: lastError ?? this.lastError,
    );
  }
}

class MidiError extends MidiState {
  final String message;

  const MidiError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class MidiBloc extends Bloc<MidiEvent, MidiState> {
  final MidiService _midiService = MidiService();

  MidiBloc() : super(MidiInitial()) {
    on<InitializeMidi>(_onInitializeMidi);
    on<PlayMidi>(_onPlayMidi);
    on<PauseMidi>(_onPauseMidi);
    on<ResumeMidi>(_onResumeMidi);
    on<StopMidi>(_onStopMidi);
    on<SeekMidi>(_onSeekMidi);
    on<SetMidiVolume>(_onSetMidiVolume);
    on<ClearMidiError>(_onClearMidiError);
    on<UpdateMidiPosition>(_onUpdateMidiPosition);

    // Listen to MIDI service changes
    _midiService.addListener(_onMidiServiceChanged);
  }

  void _onMidiServiceChanged() {
    add(UpdateMidiPosition(
      position: _midiService.position,
      duration: _midiService.duration,
      isPlaying: _midiService.isPlaying,
    ));
  }

  Future<void> _onInitializeMidi(
      InitializeMidi event, Emitter<MidiState> emit) async {
    try {
      await _midiService.initialize();
      emit(MidiLoaded(
        playerState: _midiService.state,
        currentMidiFile: _midiService.currentMidiFile,
        position: _midiService.position,
        duration: _midiService.duration,
        isPlaying: _midiService.isPlaying,
        isPaused: _midiService.isPaused,
        isLoading: _midiService.isLoading,
        lastError: _midiService.lastError,
      ));
    } catch (e) {
      emit(MidiError(e.toString()));
    }
  }

  Future<void> _onPlayMidi(PlayMidi event, Emitter<MidiState> emit) async {
    try {
      final currentState = state;
      if (currentState is MidiLoaded) {
        emit(currentState.copyWith(isLoading: true));
      }

      await _midiService.playMidi(event.midiFileName);

      emit(MidiLoaded(
        playerState: _midiService.state,
        currentMidiFile: _midiService.currentMidiFile,
        position: _midiService.position,
        duration: _midiService.duration,
        isPlaying: _midiService.isPlaying,
        isPaused: _midiService.isPaused,
        isLoading: _midiService.isLoading,
        lastError: _midiService.lastError,
      ));
    } catch (e) {
      emit(MidiError(e.toString()));
    }
  }

  Future<void> _onPauseMidi(PauseMidi event, Emitter<MidiState> emit) async {
    try {
      await _midiService.pause();
      final currentState = state;
      if (currentState is MidiLoaded) {
        emit(currentState.copyWith(
          playerState: _midiService.state,
          isPlaying: _midiService.isPlaying,
          isPaused: _midiService.isPaused,
        ));
      }
    } catch (e) {
      emit(MidiError(e.toString()));
    }
  }

  Future<void> _onResumeMidi(ResumeMidi event, Emitter<MidiState> emit) async {
    try {
      await _midiService.resume();
      final currentState = state;
      if (currentState is MidiLoaded) {
        emit(currentState.copyWith(
          playerState: _midiService.state,
          isPlaying: _midiService.isPlaying,
          isPaused: _midiService.isPaused,
        ));
      }
    } catch (e) {
      emit(MidiError(e.toString()));
    }
  }

  Future<void> _onStopMidi(StopMidi event, Emitter<MidiState> emit) async {
    try {
      await _midiService.stop();
      final currentState = state;
      if (currentState is MidiLoaded) {
        emit(currentState.copyWith(
          playerState: _midiService.state,
          currentMidiFile: null,
          position: Duration.zero,
          isPlaying: false,
          isPaused: false,
        ));
      }
    } catch (e) {
      emit(MidiError(e.toString()));
    }
  }

  Future<void> _onSeekMidi(SeekMidi event, Emitter<MidiState> emit) async {
    try {
      await _midiService.seekTo(event.position);
      final currentState = state;
      if (currentState is MidiLoaded) {
        emit(currentState.copyWith(position: event.position));
      }
    } catch (e) {
      emit(MidiError(e.toString()));
    }
  }

  Future<void> _onSetMidiVolume(
      SetMidiVolume event, Emitter<MidiState> emit) async {
    try {
      await _midiService.setVolume(event.volume);
    } catch (e) {
      emit(MidiError(e.toString()));
    }
  }

  Future<void> _onClearMidiError(
      ClearMidiError event, Emitter<MidiState> emit) async {
    _midiService.clearError();
    final currentState = state;
    if (currentState is MidiLoaded) {
      emit(currentState.copyWith(lastError: null));
    }
  }

  Future<void> _onUpdateMidiPosition(
      UpdateMidiPosition event, Emitter<MidiState> emit) async {
    final currentState = state;
    if (currentState is MidiLoaded) {
      emit(currentState.copyWith(
        position: event.position,
        duration: event.duration,
        isPlaying: event.isPlaying,
        playerState: _midiService.state,
        lastError: _midiService.lastError,
      ));
    }
  }

  @override
  Future<void> close() {
    _midiService.removeListener(_onMidiServiceChanged);
    return super.close();
  }
}