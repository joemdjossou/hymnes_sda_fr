import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'hymns_validator.dart';

/// Service for managing local hymns file storage with rollback support
class HymnsStorageService {
  static final HymnsStorageService _instance = HymnsStorageService._internal();
  factory HymnsStorageService() => _instance;
  HymnsStorageService._internal();

  static final Logger _logger = Logger();

  // File names
  static const String _currentFileName = 'hymns_current.json';
  static const String _previousFileName = 'hymns_previous.json';
  static const String _tempFileName = 'hymns_temp.json';
  static const String _hymnsDirectory = 'hymns';

  // Assets path
  static const String _assetsPath = 'assets/data/hymns.json';

  // Bundled version (should match your current hymns.json)
  static const String _bundledVersion = '1.0.0';

  Directory? _hymnsDir;

  /// Initialize storage service
  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _hymnsDir = Directory('${appDir.path}/$_hymnsDirectory');

      // Create directory if it doesn't exist
      if (!await _hymnsDir!.exists()) {
        await _hymnsDir!.create(recursive: true);
        _logger.i('Created hymns directory: ${_hymnsDir!.path}');
      }
    } catch (e) {
      _logger.e('Failed to initialize HymnsStorageService: $e');
      rethrow;
    }
  }

  /// Get current hymns file
  File get currentFile => File('${_hymnsDir!.path}/$_currentFileName');

  /// Get previous hymns file (backup)
  File get previousFile => File('${_hymnsDir!.path}/$_previousFileName');

  /// Get temp hymns file (for downloads)
  File get tempFile => File('${_hymnsDir!.path}/$_tempFileName');

  /// Check if current file exists
  Future<bool> hasCurrentFile() async {
    return await currentFile.exists();
  }

  /// Check if previous file exists
  Future<bool> hasPreviousFile() async {
    return await previousFile.exists();
  }

  /// Load hymns from the best available source
  /// Priority: current → previous → assets
  Future<HymnsLoadResult> loadHymns() async {
    _logger.i('Loading hymns from best available source');

    // Try current file first
    if (await hasCurrentFile()) {
      _logger.i('Attempting to load from current file');
      final result = await _loadFromFile(currentFile, HymnsSource.current);
      if (result.success) {
        _logger.i('Successfully loaded from current file');
        return result;
      }
      _logger.w('Failed to load from current file: ${result.error}');
    }

    // Try previous file as fallback
    if (await hasPreviousFile()) {
      _logger.i('Attempting to load from previous file (fallback)');
      final result = await _loadFromFile(previousFile, HymnsSource.previous);
      if (result.success) {
        _logger.i('Successfully loaded from previous file');
        // Restore previous as current
        await _restorePreviousAsCurrent();
        return result;
      }
      _logger.w('Failed to load from previous file: ${result.error}');
    }

    // Ultimate fallback: load from assets
    _logger.i('Loading from bundled assets (ultimate fallback)');
    final result = await loadFromAssets();
    if (result.success) {
      // Save assets to current file for future use
      await _saveAssetsToCurrent(result.hymns);
    }

    return result;
  }

  /// Load hymns from assets (bundled with app)
  Future<HymnsLoadResult> loadFromAssets() async {
    try {
      _logger.i('Loading hymns from assets');
      final jsonString = await rootBundle.loadString(_assetsPath);
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      return HymnsLoadResult(
        success: true,
        hymns: jsonList,
        source: HymnsSource.assets,
        version: _bundledVersion,
      );
    } catch (e) {
      _logger.e('Failed to load from assets: $e');
      return HymnsLoadResult(
        success: false,
        hymns: [],
        source: HymnsSource.assets,
        error: 'Failed to load from assets: $e',
      );
    }
  }

  /// Load hymns from specific file
  Future<HymnsLoadResult> _loadFromFile(
    File file,
    HymnsSource source,
  ) async {
    try {
      // Quick validation first
      final isValid = await HymnsValidator.quickValidate(file);
      if (!isValid) {
        return HymnsLoadResult(
          success: false,
          hymns: [],
          source: source,
          error: 'File failed quick validation',
        );
      }

      // Read file with UTF-8 encoding to preserve accents
      final content = await file.readAsString(encoding: utf8);
      final List<dynamic> hymns = json.decode(content) as List<dynamic>;

      return HymnsLoadResult(
        success: true,
        hymns: hymns,
        source: source,
      );
    } catch (e) {
      _logger.e('Error loading from file ${file.path}: $e');
      return HymnsLoadResult(
        success: false,
        hymns: [],
        source: source,
        error: e.toString(),
      );
    }
  }

  /// Save hymns to temp file (for downloads)
  Future<bool> saveToTemp(String content) async {
    try {
      // Write with UTF-8 encoding to preserve accents and special characters
      await tempFile.writeAsString(content, encoding: utf8);
      _logger.i('Saved hymns to temp file with UTF-8 encoding');
      return true;
    } catch (e) {
      _logger.e('Failed to save to temp file: $e');
      return false;
    }
  }

  /// Atomic file swap: backup current → activate new
  /// This is the critical operation for safe updates
  Future<AtomicSwapResult> atomicSwap() async {
    _logger.i('Starting atomic file swap');

    try {
      // Step 1: Check if temp file exists and is valid
      if (!await tempFile.exists()) {
        return AtomicSwapResult(
          success: false,
          error: 'Temp file does not exist',
        );
      }

      // Step 2: Backup current to previous (if current exists)
      if (await currentFile.exists()) {
        _logger.i('Backing up current to previous');
        try {
          // Delete old previous if exists
          if (await previousFile.exists()) {
            await previousFile.delete();
          }

          // Copy current to previous
          await currentFile.copy(previousFile.path);
          _logger.i('Backup completed successfully');
        } catch (e) {
          _logger.e('Failed to backup current file: $e');
          return AtomicSwapResult(
            success: false,
            error: 'Failed to backup current file: $e',
          );
        }
      }

      // Step 3: Move temp to current (atomic operation)
      try {
        _logger.i('Moving temp to current');

        // Delete current if exists (on some platforms rename won't overwrite)
        if (await currentFile.exists()) {
          await currentFile.delete();
        }

        // Rename temp to current
        await tempFile.rename(currentFile.path);
        _logger.i('Atomic swap completed successfully');

        return AtomicSwapResult(success: true);
      } catch (e) {
        _logger.e('Failed to move temp to current: $e');

        // Try to restore from previous if we have it
        if (await previousFile.exists()) {
          _logger.w('Attempting to restore from previous');
          try {
            await previousFile.copy(currentFile.path);
            _logger.i('Restored from previous after failed swap');
          } catch (restoreError) {
            _logger.e('Failed to restore from previous: $restoreError');
          }
        }

        return AtomicSwapResult(
          success: false,
          error: 'Failed to move temp to current: $e',
        );
      }
    } catch (e) {
      _logger.e('Unexpected error during atomic swap: $e');
      return AtomicSwapResult(
        success: false,
        error: 'Unexpected error: $e',
      );
    }
  }

  /// Restore previous version as current (rollback)
  Future<bool> _restorePreviousAsCurrent() async {
    try {
      if (!await previousFile.exists()) {
        _logger.w('No previous file to restore');
        return false;
      }

      _logger.i('Restoring previous file as current');
      await previousFile.copy(currentFile.path);
      return true;
    } catch (e) {
      _logger.e('Failed to restore previous as current: $e');
      return false;
    }
  }

  /// Manual rollback to previous version
  Future<RollbackResult> rollbackToPrevious() async {
    _logger.i('Manual rollback requested');

    if (!await hasPreviousFile()) {
      return RollbackResult(
        success: false,
        error: 'No previous version available',
      );
    }

    try {
      // Validate previous file
      final isValid = await HymnsValidator.quickValidate(previousFile);
      if (!isValid) {
        return RollbackResult(
          success: false,
          error: 'Previous file is corrupted',
        );
      }

      // Copy previous to current
      await previousFile.copy(currentFile.path);

      _logger.i('Rollback completed successfully');
      return RollbackResult(success: true);
    } catch (e) {
      _logger.e('Rollback failed: $e');
      return RollbackResult(
        success: false,
        error: 'Rollback failed: $e',
      );
    }
  }

  /// Reset to bundled assets (nuclear option)
  Future<ResetResult> resetToAssets() async {
    _logger.i('Resetting to bundled assets');

    try {
      // Load from assets
      final assetsResult = await loadFromAssets();
      if (!assetsResult.success) {
        return ResetResult(
          success: false,
          error: 'Failed to load from assets',
        );
      }

      // Save to current
      await _saveAssetsToCurrent(assetsResult.hymns);

      // Delete previous and temp files
      if (await previousFile.exists()) {
        await previousFile.delete();
      }
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      _logger.i('Reset to assets completed');
      return ResetResult(success: true);
    } catch (e) {
      _logger.e('Reset to assets failed: $e');
      return ResetResult(
        success: false,
        error: 'Reset failed: $e',
      );
    }
  }

  /// Save assets content to current file
  Future<void> _saveAssetsToCurrent(List<dynamic> hymns) async {
    try {
      final jsonString = json.encode(hymns);
      // Write with UTF-8 encoding to preserve accents and special characters
      await currentFile.writeAsString(jsonString, encoding: utf8);
      _logger.i('Saved assets to current file with UTF-8 encoding');
    } catch (e) {
      _logger.e('Failed to save assets to current: $e');
    }
  }

  /// Delete temp file (cleanup)
  Future<void> deleteTempFile() async {
    try {
      if (await tempFile.exists()) {
        await tempFile.delete();
        _logger.i('Deleted temp file');
      }
    } catch (e) {
      _logger.e('Failed to delete temp file: $e');
    }
  }

  /// Get storage info for debugging/settings
  Future<StorageInfo> getStorageInfo() async {
    final info = StorageInfo();

    if (await hasCurrentFile()) {
      info.currentFileSize = await currentFile.length();
      info.currentFileExists = true;
    }

    if (await hasPreviousFile()) {
      info.previousFileSize = await previousFile.length();
      info.previousFileExists = true;
    }

    if (await tempFile.exists()) {
      info.tempFileSize = await tempFile.length();
      info.tempFileExists = true;
    }

    return info;
  }

  /// Get bundled version
  String get bundledVersion => _bundledVersion;
}

/// Result of loading hymns
class HymnsLoadResult {
  final bool success;
  final List<dynamic> hymns;
  final HymnsSource source;
  final String? version;
  final String? error;

  const HymnsLoadResult({
    required this.success,
    required this.hymns,
    required this.source,
    this.version,
    this.error,
  });
}

/// Source of loaded hymns
enum HymnsSource {
  current,
  previous,
  assets,
}

/// Result of atomic swap operation
class AtomicSwapResult {
  final bool success;
  final String? error;

  const AtomicSwapResult({
    required this.success,
    this.error,
  });
}

/// Result of rollback operation
class RollbackResult {
  final bool success;
  final String? error;

  const RollbackResult({
    required this.success,
    this.error,
  });
}

/// Result of reset operation
class ResetResult {
  final bool success;
  final String? error;

  const ResetResult({
    required this.success,
    this.error,
  });
}

/// Storage information
class StorageInfo {
  bool currentFileExists = false;
  bool previousFileExists = false;
  bool tempFileExists = false;
  int currentFileSize = 0;
  int previousFileSize = 0;
  int tempFileSize = 0;

  String get formattedCurrentSize => _formatBytes(currentFileSize);
  String get formattedPreviousSize => _formatBytes(previousFileSize);
  String get formattedTempSize => _formatBytes(tempFileSize);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  String toString() {
    return 'StorageInfo(\n'
        '  Current: ${currentFileExists ? formattedCurrentSize : 'Not found'}\n'
        '  Previous: ${previousFileExists ? formattedPreviousSize : 'Not found'}\n'
        '  Temp: ${tempFileExists ? formattedTempSize : 'Not found'}\n'
        ')';
  }
}
