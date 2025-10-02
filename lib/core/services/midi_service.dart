import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

enum MidiPlayerState {
  stopped,
  loading,
  playing,
  paused,
  error,
}

class MidiService extends ChangeNotifier {
  static final MidiService _instance = MidiService._internal();
  factory MidiService() => _instance;
  MidiService._internal();

  MidiPlayerState _state = MidiPlayerState.stopped;
  String? _currentMidiFile;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isInitialized = false;
  String? _lastError;
  bool _isPlaying = false;
  
  // Simple audio player for MIDI playback
  AudioPlayer? _audioPlayer;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  // Getters
  MidiPlayerState get state => _state;
  String? get currentMidiFile => _currentMidiFile;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _isPlaying;
  bool get isPaused => _state == MidiPlayerState.paused;
  bool get isLoading => _state == MidiPlayerState.loading;
  String? get lastError => _lastError;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _audioPlayer = AudioPlayer();
      
      // Listen to position changes
      _positionSubscription = _audioPlayer!.positionStream.listen((position) {
        _position = position;
        notifyListeners();
      });

      // Listen to duration changes
      _durationSubscription = _audioPlayer!.durationStream.listen((duration) {
        if (duration != null) {
          _duration = duration;
          notifyListeners();
        }
      });

      // Listen to player state changes
      _playerStateSubscription = _audioPlayer!.playerStateStream.listen((state) {
        switch (state.processingState) {
          case ProcessingState.loading:
          case ProcessingState.buffering:
            _state = MidiPlayerState.loading;
            _isPlaying = false;
            break;
          case ProcessingState.ready:
            if (state.playing) {
              _state = MidiPlayerState.playing;
              _isPlaying = true;
            } else {
              _state = MidiPlayerState.paused;
              _isPlaying = false;
            }
            break;
          case ProcessingState.completed:
            _state = MidiPlayerState.stopped;
            _isPlaying = false;
            _position = Duration.zero;
            break;
          case ProcessingState.idle:
            _state = MidiPlayerState.stopped;
            _isPlaying = false;
            break;
        }
        notifyListeners();
      });

      _isInitialized = true;
      debugPrint('MIDI Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing MIDI Service: $e');
      _state = MidiPlayerState.error;
      _lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> playMidi(String midiFileName) async {
    if (!_isInitialized) await initialize();

    try {
      _state = MidiPlayerState.loading;
      _currentMidiFile = midiFileName;
      _lastError = null;
      notifyListeners();

      // Construct the MIDI file path
      final midiPath = 'assets/midi/$midiFileName.mid';

      debugPrint('Attempting to play MIDI: $midiPath');

      // Try to load and play the MIDI file as audio
      await _audioPlayer!.setAsset(midiPath);
      await _audioPlayer!.play();

      debugPrint('Playing MIDI: $midiPath');
    } catch (e) {
      debugPrint('Error playing MIDI: $e');
      _state = MidiPlayerState.error;
      _lastError = 'Unable to play MIDI file. The file may not exist or may not be supported for audio playback.';
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.pause();
        debugPrint('MIDI playback paused');
      }
    } catch (e) {
      debugPrint('Error pausing MIDI: $e');
    }
  }

  Future<void> resume() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.play();
        debugPrint('MIDI playback resumed');
      }
    } catch (e) {
      debugPrint('Error resuming MIDI: $e');
    }
  }

  Future<void> stop() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
        _position = Duration.zero;
        _currentMidiFile = null;
        _lastError = null;
        debugPrint('MIDI playback stopped');
      }
    } catch (e) {
      debugPrint('Error stopping MIDI: $e');
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.seek(position);
        debugPrint('MIDI playback seeked to: ${position.inSeconds} seconds');
      }
    } catch (e) {
      debugPrint('Error seeking MIDI: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.setVolume(volume.clamp(0.0, 1.0));
        debugPrint('MIDI volume set to: ${(volume * 100).toInt()}%');
      }
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer?.dispose();
    super.dispose();
  }
}