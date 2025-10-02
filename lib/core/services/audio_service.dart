import 'dart:async';

import 'package:flutter/foundation.dart';

enum AudioPlayerState { stopped, playing, paused, loading }

class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayerState _state = AudioPlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _currentTrack;
  double _volume = 1.0;
  bool _isLooping = false;
  Timer? _positionTimer;

  // Getters
  AudioPlayerState get state => _state;
  Duration get position => _position;
  Duration get duration => _duration;
  String? get currentTrack => _currentTrack;
  double get volume => _volume;
  bool get isLooping => _isLooping;
  bool get isPlaying => _state == AudioPlayerState.playing;
  bool get isPaused => _state == AudioPlayerState.paused;
  bool get isStopped => _state == AudioPlayerState.stopped;
  bool get isLoading => _state == AudioPlayerState.loading;

  @override
  void dispose() {
    _positionTimer?.cancel();
    super.dispose();
  }

  Future<void> initialize() async {
    try {
      // Initialize audio service
      debugPrint('Audio service initialized');
    } catch (e) {
      debugPrint('Error initializing audio service: $e');
    }
  }

  Future<void> play(String audioPath) async {
    try {
      _state = AudioPlayerState.loading;
      _currentTrack = audioPath;
      notifyListeners();

      // Simulate audio loading
      await Future.delayed(const Duration(milliseconds: 500));

      _state = AudioPlayerState.playing;
      _duration = const Duration(minutes: 3, seconds: 30); // Simulated duration
      _position = Duration.zero;

      // Start position timer
      _startPositionTimer();

      notifyListeners();

      debugPrint('Playing audio: $audioPath');
    } catch (e) {
      debugPrint('Error playing audio: $e');
      _state = AudioPlayerState.stopped;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      _state = AudioPlayerState.paused;
      _positionTimer?.cancel();
      notifyListeners();
      debugPrint('Audio paused');
    } catch (e) {
      debugPrint('Error pausing audio: $e');
    }
  }

  Future<void> resume() async {
    try {
      _state = AudioPlayerState.playing;
      _startPositionTimer();
      notifyListeners();
      debugPrint('Audio resumed');
    } catch (e) {
      debugPrint('Error resuming audio: $e');
    }
  }

  Future<void> stop() async {
    try {
      _state = AudioPlayerState.stopped;
      _position = Duration.zero;
      _currentTrack = null;
      _positionTimer?.cancel();
      notifyListeners();
      debugPrint('Audio stopped');
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      _position = position;
      notifyListeners();
      debugPrint('Audio seeked to: ${position.inSeconds}s');
    } catch (e) {
      debugPrint('Error seeking audio: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      _volume = volume.clamp(0.0, 1.0);
      notifyListeners();
      debugPrint('Volume set to: $_volume');
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  Future<void> toggleLoop() async {
    try {
      _isLooping = !_isLooping;
      notifyListeners();
      debugPrint('Loop toggled: $_isLooping');
    } catch (e) {
      debugPrint('Error toggling loop: $e');
    }
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_state == AudioPlayerState.playing) {
        _position += const Duration(milliseconds: 100);

        // Check if audio finished
        if (_position >= _duration) {
          if (_isLooping) {
            _position = Duration.zero;
          } else {
            stop();
            return;
          }
        }

        notifyListeners();
      }
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  double get progress {
    if (_duration.inMilliseconds == 0) return 0.0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }
}
