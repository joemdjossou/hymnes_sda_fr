import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Metadata for tracking hymns versions and update status
class HymnsVersionMetadata {
  // Current active version
  final String currentVersion;
  final String currentVersionChecksum;
  final int currentVersionTimestamp;
  final String currentVersionStatus; // "stable" | "failed" | "testing"

  // Previous version (for rollback)
  final String? previousVersion;
  final String? previousVersionChecksum;
  final int? previousVersionTimestamp;

  // Bundled version (from assets)
  final String bundledVersion;

  // Last check info
  final int lastUpdateCheck;
  final bool autoUpdateEnabled;

  // Failed versions blacklist
  final List<String> failedVersions;

  // Update settings
  final bool updateOnlyOnWifi;
  final bool showUpdateNotifications;
  final int updateCheckIntervalHours;

  const HymnsVersionMetadata({
    required this.currentVersion,
    required this.currentVersionChecksum,
    required this.currentVersionTimestamp,
    required this.currentVersionStatus,
    this.previousVersion,
    this.previousVersionChecksum,
    this.previousVersionTimestamp,
    required this.bundledVersion,
    required this.lastUpdateCheck,
    this.autoUpdateEnabled = true,
    this.failedVersions = const [],
    this.updateOnlyOnWifi = false, // Default: allow updates on any connection
    this.showUpdateNotifications = false,
    this.updateCheckIntervalHours = 24,
  });

  /// Create default metadata for first app launch
  factory HymnsVersionMetadata.initial({
    required String bundledVersion,
  }) {
    return HymnsVersionMetadata(
      currentVersion: bundledVersion,
      currentVersionChecksum: '',
      currentVersionTimestamp: DateTime.now().millisecondsSinceEpoch,
      currentVersionStatus: 'stable',
      bundledVersion: bundledVersion,
      lastUpdateCheck: 0,
      autoUpdateEnabled: true,
      failedVersions: [],
      updateOnlyOnWifi: false, // Allow updates on any connection (WiFi or mobile data)
      showUpdateNotifications: false,
      updateCheckIntervalHours: 24,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'currentVersion': currentVersion,
      'currentVersionChecksum': currentVersionChecksum,
      'currentVersionTimestamp': currentVersionTimestamp,
      'currentVersionStatus': currentVersionStatus,
      'previousVersion': previousVersion,
      'previousVersionChecksum': previousVersionChecksum,
      'previousVersionTimestamp': previousVersionTimestamp,
      'bundledVersion': bundledVersion,
      'lastUpdateCheck': lastUpdateCheck,
      'autoUpdateEnabled': autoUpdateEnabled,
      'failedVersions': failedVersions,
      'updateOnlyOnWifi': updateOnlyOnWifi,
      'showUpdateNotifications': showUpdateNotifications,
      'updateCheckIntervalHours': updateCheckIntervalHours,
    };
  }

  /// Create from JSON
  factory HymnsVersionMetadata.fromJson(Map<String, dynamic> json) {
    return HymnsVersionMetadata(
      currentVersion: json['currentVersion'] as String? ?? '1.0.0',
      currentVersionChecksum:
          json['currentVersionChecksum'] as String? ?? '',
      currentVersionTimestamp:
          json['currentVersionTimestamp'] as int? ?? 0,
      currentVersionStatus:
          json['currentVersionStatus'] as String? ?? 'stable',
      previousVersion: json['previousVersion'] as String?,
      previousVersionChecksum: json['previousVersionChecksum'] as String?,
      previousVersionTimestamp: json['previousVersionTimestamp'] as int?,
      bundledVersion: json['bundledVersion'] as String? ?? '1.0.0',
      lastUpdateCheck: json['lastUpdateCheck'] as int? ?? 0,
      autoUpdateEnabled: json['autoUpdateEnabled'] as bool? ?? true,
      failedVersions: (json['failedVersions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      updateOnlyOnWifi: json['updateOnlyOnWifi'] as bool? ?? false, // Default: any connection
      showUpdateNotifications:
          json['showUpdateNotifications'] as bool? ?? false,
      updateCheckIntervalHours:
          json['updateCheckIntervalHours'] as int? ?? 24,
    );
  }

  /// Copy with updated values
  HymnsVersionMetadata copyWith({
    String? currentVersion,
    String? currentVersionChecksum,
    int? currentVersionTimestamp,
    String? currentVersionStatus,
    String? previousVersion,
    String? previousVersionChecksum,
    int? previousVersionTimestamp,
    String? bundledVersion,
    int? lastUpdateCheck,
    bool? autoUpdateEnabled,
    List<String>? failedVersions,
    bool? updateOnlyOnWifi,
    bool? showUpdateNotifications,
    int? updateCheckIntervalHours,
  }) {
    return HymnsVersionMetadata(
      currentVersion: currentVersion ?? this.currentVersion,
      currentVersionChecksum:
          currentVersionChecksum ?? this.currentVersionChecksum,
      currentVersionTimestamp:
          currentVersionTimestamp ?? this.currentVersionTimestamp,
      currentVersionStatus: currentVersionStatus ?? this.currentVersionStatus,
      previousVersion: previousVersion ?? this.previousVersion,
      previousVersionChecksum:
          previousVersionChecksum ?? this.previousVersionChecksum,
      previousVersionTimestamp:
          previousVersionTimestamp ?? this.previousVersionTimestamp,
      bundledVersion: bundledVersion ?? this.bundledVersion,
      lastUpdateCheck: lastUpdateCheck ?? this.lastUpdateCheck,
      autoUpdateEnabled: autoUpdateEnabled ?? this.autoUpdateEnabled,
      failedVersions: failedVersions ?? this.failedVersions,
      updateOnlyOnWifi: updateOnlyOnWifi ?? this.updateOnlyOnWifi,
      showUpdateNotifications:
          showUpdateNotifications ?? this.showUpdateNotifications,
      updateCheckIntervalHours:
          updateCheckIntervalHours ?? this.updateCheckIntervalHours,
    );
  }

  /// Check if version is blacklisted
  bool isVersionBlacklisted(String version) {
    return failedVersions.contains(version);
  }

  /// Add version to blacklist
  HymnsVersionMetadata addToBlacklist(String version) {
    if (!failedVersions.contains(version)) {
      return copyWith(failedVersions: [...failedVersions, version]);
    }
    return this;
  }

  /// Remove version from blacklist
  HymnsVersionMetadata removeFromBlacklist(String version) {
    if (failedVersions.contains(version)) {
      return copyWith(
        failedVersions: failedVersions.where((v) => v != version).toList(),
      );
    }
    return this;
  }

  /// Clear all blacklisted versions
  HymnsVersionMetadata clearBlacklist() {
    return copyWith(failedVersions: []);
  }

  /// Compare versions (semantic versioning)
  static int compareVersions(String v1, String v2) {
    // Handle null/empty strings
    if (v1.isEmpty && v2.isEmpty) return 0;
    if (v1.isEmpty) return -1;
    if (v2.isEmpty) return 1;
    
    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLength = parts1.length > parts2.length ? parts1.length : parts2.length;

    for (int i = 0; i < maxLength; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;

      if (p1 > p2) return 1;
      if (p1 < p2) return -1;
    }

    return 0;
  }

  /// Check if update is needed
  bool needsUpdate(String remoteVersion) {
    // Don't update if remote version is blacklisted
    if (isVersionBlacklisted(remoteVersion)) {
      return false;
    }

    // Compare versions
    final comparison = compareVersions(remoteVersion, currentVersion);
    return comparison > 0;
  }

  /// Check if enough time has passed since last check
  bool shouldCheckForUpdate() {
    if (!autoUpdateEnabled) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final intervalMs = updateCheckIntervalHours * 60 * 60 * 1000;

    return (now - lastUpdateCheck) >= intervalMs;
  }

  @override
  String toString() {
    return 'HymnsVersionMetadata('
        'current: $currentVersion, '
        'previous: ${previousVersion ?? 'none'}, '
        'status: $currentVersionStatus, '
        'blacklisted: ${failedVersions.length}'
        ')';
  }
}

/// Service for persisting metadata to SharedPreferences
class HymnsMetadataStorage {
  static const String _key = 'hymns_version_metadata';

  /// Load metadata from SharedPreferences
  static Future<HymnsVersionMetadata?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);

      if (jsonString == null) return null;

      final json = Map<String, dynamic>.from(
        jsonDecode(jsonString) as Map,
      );

      return HymnsVersionMetadata.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Save metadata to SharedPreferences
  static Future<bool> save(HymnsVersionMetadata metadata) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(metadata.toJson());
      return await prefs.setString(_key, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Clear metadata
  static Future<bool> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_key);
    } catch (e) {
      return false;
    }
  }
}

/// Remote metadata from Firebase
class RemoteHymnsMetadata {
  final String version;
  final int lastUpdated;
  final String downloadUrl;
  final int fileSize;
  final int hymnsCount;
  final String checksum;
  final String minAppVersion;
  final String? releaseNotes;

  const RemoteHymnsMetadata({
    required this.version,
    required this.lastUpdated,
    required this.downloadUrl,
    required this.fileSize,
    required this.hymnsCount,
    required this.checksum,
    required this.minAppVersion,
    this.releaseNotes,
  });

  factory RemoteHymnsMetadata.fromJson(Map<String, dynamic> json) {
    return RemoteHymnsMetadata(
      version: json['version'] as String? ?? '1.0.0',
      lastUpdated: json['lastUpdated'] as int? ?? 0, // Can be 0 if not provided
      downloadUrl: json['downloadUrl'] as String? ?? '',
      fileSize: json['fileSize'] as int? ?? 0, // Can be 0 if not provided
      hymnsCount: json['hymnsCount'] as int? ?? 0, // Can be 0 if not provided
      checksum: json['checksum'] as String? ?? '', // Can be empty if not provided
      minAppVersion: json['minAppVersion'] as String? ?? '1.0.0',
      releaseNotes: json['releaseNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'lastUpdated': lastUpdated,
      'downloadUrl': downloadUrl,
      'fileSize': fileSize,
      'hymnsCount': hymnsCount,
      'checksum': checksum,
      'minAppVersion': minAppVersion,
      if (releaseNotes != null) 'releaseNotes': releaseNotes,
    };
  }

  @override
  String toString() {
    return 'RemoteHymnsMetadata('
        'version: $version, '
        'size: ${fileSize}B, '
        'hymns: $hymnsCount'
        ')';
  }
}

