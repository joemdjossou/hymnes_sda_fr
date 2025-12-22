import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/hymns_version_metadata.dart';
import 'error_logging_service.dart';
import 'hymn_data_service.dart';
import 'hymns_storage_service.dart';
import 'hymns_validator.dart';

/// Service for syncing hymns data from Firebase with offline-first approach
class HymnsSyncService {
  static final HymnsSyncService _instance = HymnsSyncService._internal();
  factory HymnsSyncService() => _instance;
  HymnsSyncService._internal();

  static final Logger _logger = Logger();

  final HymnsStorageService _storage = HymnsStorageService();
  final ErrorLoggingService _errorLogger = ErrorLoggingService();

  // Firebase paths
  static const String _metadataPath = 'hymns_metadata';

  // Sync status
  SyncStatus _status = SyncStatus.idle;

  // Callbacks for UI updates
  final _statusController = StreamController<SyncStatus>.broadcast();
  final _progressController = StreamController<double>.broadcast();

  Stream<SyncStatus> get statusStream => _statusController.stream;
  Stream<double> get progressStream => _progressController.stream;
  SyncStatus get currentStatus => _status;

  bool _isInitialized = false;

  /// Initialize sync service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _storage.initialize();
      _isInitialized = true;
      _logger.i('HymnsSyncService initialized');
    } catch (e) {
      _logger.e('Failed to initialize HymnsSyncService: $e');
      rethrow;
    }
  }

  /// Check for updates and download if available
  Future<SyncResult> checkForUpdates({bool forceCheck = false}) async {
    if (!_isInitialized) {
      await initialize();
    }

    _updateStatus(SyncStatus.checking);

    try {
      // Load local metadata
      var localMetadata = await HymnsMetadataStorage.load();

      // If no local metadata, initialize with bundled version
      if (localMetadata == null) {
        _logger.i('No local metadata found, initializing...');
        final initialMetadata = HymnsVersionMetadata.initial(
          bundledVersion: _storage.bundledVersion,
        );
        await HymnsMetadataStorage.save(initialMetadata);

        // Ensure bundled assets are saved locally
        if (!await _storage.hasCurrentFile()) {
          final assetsResult = await _storage.loadFromAssets();
          if (assetsResult.success) {
            await _storage.currentFile.writeAsString(
              jsonEncode(assetsResult.hymns),
            );
          }
        }

        _updateStatus(SyncStatus.idle);
        return SyncResult.skipped('Initialized with bundled version');
      }

      // MIGRATION: Update old metadata to allow updates on any connection
      // This ensures existing users get the new behavior
      if (localMetadata.updateOnlyOnWifi == true) {
        _logger.i('Migrating metadata: Enabling updates on any connection');
        localMetadata = localMetadata.copyWith(updateOnlyOnWifi: false);
        await HymnsMetadataStorage.save(localMetadata);
      }

      // Check if we should check for updates
      if (!forceCheck && !localMetadata.shouldCheckForUpdate()) {
        _logger.i('Skipping update check (not enough time has passed)');
        _updateStatus(SyncStatus.idle);
        return SyncResult.skipped('Update check not needed yet');
      }

      // Check internet connectivity
      final hasInternet = await _hasInternetConnection();
      if (!hasInternet) {
        _logger.i('No internet connection');
        _updateStatus(SyncStatus.idle);
        return SyncResult.skipped('No internet connection');
      }

      // Check WiFi requirement
      if (localMetadata.updateOnlyOnWifi) {
        final isWifi = await _isConnectedToWifi();
        if (!isWifi) {
          _logger.i('Not on WiFi, skipping update');
          _updateStatus(SyncStatus.idle);
          return SyncResult.skipped('Waiting for WiFi connection');
        }
      }

      // Fetch remote metadata from Firebase
      final remoteMetadata = await _fetchRemoteMetadata();
      if (remoteMetadata == null) {
        _updateStatus(SyncStatus.idle);
        return SyncResult.error('Failed to fetch remote metadata');
      }

      // Update last check timestamp
      await HymnsMetadataStorage.save(
        localMetadata.copyWith(
          lastUpdateCheck: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      // Check if update is needed
      final comparison = HymnsVersionMetadata.compareVersions(
        remoteMetadata.version,
        localMetadata.currentVersion,
      );
      final isBlacklisted =
          localMetadata.isVersionBlacklisted(remoteMetadata.version);

      _logger.i(
          'Version comparison: Remote ${remoteMetadata.version} vs Current ${localMetadata.currentVersion} = $comparison');

      if (isBlacklisted) {
        _logger.w(
            '⚠️ Version ${remoteMetadata.version} is blacklisted (previously failed). '
            'Skipping update. To retry, clear the blacklist in Settings → Hymns Data.');
      }

      if (!localMetadata.needsUpdate(remoteMetadata.version)) {
        final reason = isBlacklisted
            ? 'Version is blacklisted (previously failed)'
            : comparison <= 0
                ? 'Remote version is not newer'
                : 'Unknown reason';
        _logger.i('No update needed. Current: ${localMetadata.currentVersion}, '
            'Remote: ${remoteMetadata.version}, Comparison: $comparison, '
            'Blacklisted: $isBlacklisted, Reason: $reason');
        _updateStatus(SyncStatus.idle);
        return SyncResult.upToDate();
      }

      // Validate app compatibility
      final packageInfo = await PackageInfo.fromPlatform();
      final currentAppVersion = packageInfo.version;
      if (!_isAppVersionCompatible(
          currentAppVersion, remoteMetadata.minAppVersion)) {
        _logger.w('App version $currentAppVersion is not compatible with '
            'remote version (requires ${remoteMetadata.minAppVersion})');
        _updateStatus(SyncStatus.idle);
        return SyncResult.error('App update required');
      }

      // Check available storage
      final hasSpace = await _hasEnoughStorage(remoteMetadata.fileSize);
      if (!hasSpace) {
        _updateStatus(SyncStatus.idle);
        return SyncResult.error('Not enough storage space');
      }

      // Download new version
      _logger.i('Downloading hymns version ${remoteMetadata.version}');
      _updateStatus(SyncStatus.downloading);

      final downloadResult = await _downloadHymns(remoteMetadata);
      if (!downloadResult.success) {
        _updateStatus(SyncStatus.idle);
        await _errorLogger.logError(
          'HymnsSyncService',
          'Download failed: ${downloadResult.error}',
          context: {'version': remoteMetadata.version},
        );
        return SyncResult.error('Download failed: ${downloadResult.error}');
      }

      // Validate downloaded file
      _logger.i('Validating downloaded file');
      _updateStatus(SyncStatus.validating);

      final validationResult = await HymnsValidator.validateAll(
        _storage.tempFile,
        remoteMetadata,
      );

      if (!validationResult.isValid) {
        _logger.e('Validation failed: ${validationResult.summary}');
        await _storage.deleteTempFile();
        _updateStatus(SyncStatus.idle);

        // Add version to blacklist
        final updatedMetadata =
            localMetadata.addToBlacklist(remoteMetadata.version);
        await HymnsMetadataStorage.save(updatedMetadata);

        await _errorLogger.logError(
          'HymnsSyncService',
          'Validation failed: ${validationResult.summary}',
          context: {'version': remoteMetadata.version},
        );

        return SyncResult.error('Validation failed');
      }

      // Atomic swap: backup current → activate new
      _logger.i('Activating new version');
      _updateStatus(SyncStatus.installing);

      final swapResult = await _storage.atomicSwap();
      if (!swapResult.success) {
        _logger.e('Atomic swap failed: ${swapResult.error}');
        await _storage.deleteTempFile();
        _updateStatus(SyncStatus.idle);
        return SyncResult.error('Failed to activate new version');
      }

      // Update metadata
      final newMetadata = localMetadata.copyWith(
        previousVersion: localMetadata.currentVersion,
        previousVersionChecksum: localMetadata.currentVersionChecksum,
        previousVersionTimestamp: localMetadata.currentVersionTimestamp,
        currentVersion: remoteMetadata.version,
        currentVersionChecksum: remoteMetadata.checksum,
        currentVersionTimestamp: DateTime.now().millisecondsSinceEpoch,
        currentVersionStatus: 'stable',
      );

      await HymnsMetadataStorage.save(newMetadata);

      // Clear hymns cache so new version is loaded immediately
      try {
        final hymnDataService = HymnDataService();
        hymnDataService.clearCache();
        _logger.i('Cleared hymns cache after update');
      } catch (e) {
        _logger.w('Failed to clear hymns cache: $e');
      }

      _logger.i('Successfully updated to version ${remoteMetadata.version}');
      _updateStatus(SyncStatus.completed);

      // Log success to analytics
      await _errorLogger.logInfo(
        'HymnsSyncService',
        'Hymns updated successfully',
        context: {
          'from_version': localMetadata.currentVersion,
          'to_version': remoteMetadata.version,
          'hymns_count': remoteMetadata.hymnsCount,
        },
      );

      // Reset status after a delay
      Future.delayed(const Duration(seconds: 2), () {
        _updateStatus(SyncStatus.idle);
      });

      return SyncResult.success(
        oldVersion: localMetadata.currentVersion,
        newVersion: remoteMetadata.version,
        releaseNotes: remoteMetadata.releaseNotes,
      );
    } catch (e, stackTrace) {
      _logger.e('Error during update check: $e');
      await _errorLogger.logError(
        'HymnsSyncService',
        'Update check failed',
        error: e,
        stackTrace: stackTrace,
        context: {'error': e.toString()},
      );
      _updateStatus(SyncStatus.idle);
      return SyncResult.error('Update check failed: $e');
    }
  }

  /// Fetch metadata from Firebase Realtime Database
  Future<RemoteHymnsMetadata?> _fetchRemoteMetadata() async {
    try {
      final ref = FirebaseDatabase.instance.ref(_metadataPath);
      final snapshot = await ref.get();

      if (!snapshot.exists) {
        _logger.w('No remote metadata found in Firebase');
        return null;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final metadata = RemoteHymnsMetadata.fromJson(
        Map<String, dynamic>.from(data),
      );

      _logger.i('Fetched remote metadata: $metadata');
      return metadata;
    } catch (e) {
      _logger.e('Failed to fetch remote metadata: $e');
      return null;
    }
  }

  /// Download hymns file from Firebase Storage
  Future<DownloadResult> _downloadHymns(RemoteHymnsMetadata metadata) async {
    try {
      _updateProgress(0.0);

      final client = http.Client();
      final request = http.Request('GET', Uri.parse(metadata.downloadUrl));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        return DownloadResult(
          success: false,
          error: 'HTTP ${response.statusCode}',
        );
      }

      final contentLength = response.contentLength ?? metadata.fileSize;
      final List<int> bytes = [];

      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        final progress = bytes.length / contentLength;
        _updateProgress(progress);
      }

      // Save to temp file with UTF-8 encoding
      // Use utf8.decode to properly handle accents and special characters
      final content = utf8.decode(bytes, allowMalformed: false);
      final saved = await _storage.saveToTemp(content);

      if (!saved) {
        return DownloadResult(
          success: false,
          error: 'Failed to save downloaded file',
        );
      }

      _updateProgress(1.0);
      return DownloadResult(success: true);
    } catch (e) {
      _logger.e('Download error: $e');
      return DownloadResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Check internet connectivity
  Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      _logger.w('Failed to check connectivity: $e');
      return false;
    }
  }

  /// Check if connected to WiFi
  Future<bool> _isConnectedToWifi() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult == ConnectivityResult.wifi;
    } catch (e) {
      _logger.w('Failed to check WiFi: $e');
      return false;
    }
  }

  /// Check if app version is compatible with remote version
  bool _isAppVersionCompatible(String appVersion, String minRequiredVersion) {
    return HymnsVersionMetadata.compareVersions(
            appVersion, minRequiredVersion) >=
        0;
  }

  /// Check if there's enough storage space
  Future<bool> _hasEnoughStorage(int requiredBytes) async {
    // Require 2x the file size (for temp + current + previous)
    final requiredSpace = requiredBytes * 2;

    // On mobile, this is a rough estimate
    // In production, you might want to use a plugin to check actual free space
    return requiredSpace < 10 * 1024 * 1024; // Assuming we need less than 10MB
  }

  /// Update sync status
  void _updateStatus(SyncStatus status) {
    _status = status;
    _statusController.add(status);
    _logger.d('Sync status: $status');
  }

  /// Update download progress
  void _updateProgress(double progress) {
    _progressController.add(progress);
  }

  /// Dispose resources
  void dispose() {
    _statusController.close();
    _progressController.close();
  }
}

/// Sync status enum
enum SyncStatus {
  idle,
  checking,
  downloading,
  validating,
  installing,
  completed,
  error,
}

/// Result of sync operation
class SyncResult {
  final bool success;
  final String? message;
  final String? error;
  final String? oldVersion;
  final String? newVersion;
  final String? releaseNotes;

  const SyncResult({
    required this.success,
    this.message,
    this.error,
    this.oldVersion,
    this.newVersion,
    this.releaseNotes,
  });

  factory SyncResult.success({
    required String oldVersion,
    required String newVersion,
    String? releaseNotes,
  }) {
    return SyncResult(
      success: true,
      message: 'Updated from $oldVersion to $newVersion',
      oldVersion: oldVersion,
      newVersion: newVersion,
      releaseNotes: releaseNotes,
    );
  }

  factory SyncResult.skipped(String reason) {
    return SyncResult(
      success: false,
      message: reason,
    );
  }

  factory SyncResult.upToDate() {
    return const SyncResult(
      success: false,
      message: 'Already up to date',
    );
  }

  factory SyncResult.error(String error) {
    return SyncResult(
      success: false,
      error: error,
    );
  }

  @override
  String toString() {
    if (success) {
      return 'SyncResult: Success - $message';
    } else if (error != null) {
      return 'SyncResult: Error - $error';
    } else {
      return 'SyncResult: Skipped - $message';
    }
  }
}

/// Result of download operation
class DownloadResult {
  final bool success;
  final String? error;

  const DownloadResult({
    required this.success,
    this.error,
  });
}
