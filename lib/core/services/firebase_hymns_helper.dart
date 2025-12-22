import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../models/hymns_version_metadata.dart';

/// Helper class for Firebase operations related to hymns sync
/// This is primarily for admin/developer use to upload new versions
class FirebaseHymnsHelper {
  static final Logger _logger = Logger();

  /// Upload hymns.json to Firebase Storage
  /// Note: This requires authentication and should be done manually
  static Future<String?> uploadHymnsToStorage({
    required String version,
    String? localFilePath,
  }) async {
    try {
      // Load hymns data (from local file or assets)
      String jsonContent;
      if (localFilePath != null) {
        // Load from local file path (for manual uploads)
        _logger.i('Loading hymns from local file: $localFilePath');
        jsonContent = await rootBundle.loadString(localFilePath);
      } else {
        // Load from assets (default)
        _logger.i('Loading hymns from assets');
        jsonContent = await rootBundle.loadString('assets/data/hymns.json');
      }

      final fileName = 'hymns_v$version.json';
      final storageRef = FirebaseStorage.instance.ref().child('hymns/$fileName');

      // Upload file
      _logger.i('Uploading $fileName to Firebase Storage...');
      final uploadTask = storageRef.putString(
        jsonContent,
        metadata: SettableMetadata(
          contentType: 'application/json',
          customMetadata: {
            'version': version,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _logger.i('Upload successful! Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _logger.e('Failed to upload hymns to storage: $e');
      return null;
    }
  }

  /// Update metadata in Firebase Realtime Database
  /// Note: This requires authentication and should be done manually
  static Future<bool> updateMetadataInDatabase({
    required String version,
    required String downloadUrl,
    required int fileSize,
    required int hymnsCount,
    required String checksum,
    String minAppVersion = '1.0.0',
    String? releaseNotes,
  }) async {
    try {
      final metadata = RemoteHymnsMetadata(
        version: version,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
        downloadUrl: downloadUrl,
        fileSize: fileSize,
        hymnsCount: hymnsCount,
        checksum: checksum,
        minAppVersion: minAppVersion,
        releaseNotes: releaseNotes,
      );

      final ref = FirebaseDatabase.instance.ref('hymns_metadata');
      await ref.set(metadata.toJson());

      _logger.i('Metadata updated in Firebase Realtime Database');
      return true;
    } catch (e) {
      _logger.e('Failed to update metadata: $e');
      return false;
    }
  }

  /// Calculate hymns count from JSON string
  static int calculateHymnsCount(String jsonContent) {
    try {
      final List<dynamic> hymns = json.decode(jsonContent) as List<dynamic>;
      return hymns.length;
    } catch (e) {
      _logger.e('Failed to calculate hymns count: $e');
      return 0;
    }
  }

  /// Calculate file size from JSON string
  static int calculateFileSize(String jsonContent) {
    return jsonContent.length;
  }

  /// Test metadata retrieval
  static Future<RemoteHymnsMetadata?> testFetchMetadata() async {
    try {
      final ref = FirebaseDatabase.instance.ref('hymns_metadata');
      final snapshot = await ref.get();

      if (!snapshot.exists) {
        _logger.w('No metadata found in Firebase');
        return null;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final metadata = RemoteHymnsMetadata.fromJson(
        Map<String, dynamic>.from(data),
      );

      _logger.i('Successfully fetched metadata: $metadata');
      return metadata;
    } catch (e) {
      _logger.e('Failed to fetch metadata: $e');
      return null;
    }
  }

  /// Get current metadata from Firebase (read-only)
  static Future<Map<String, dynamic>?> getCurrentMetadata() async {
    try {
      final ref = FirebaseDatabase.instance.ref('hymns_metadata');
      final snapshot = await ref.get();

      if (!snapshot.exists) {
        return null;
      }

      return Map<String, dynamic>.from(snapshot.value as Map);
    } catch (e) {
      _logger.e('Failed to get current metadata: $e');
      return null;
    }
  }
}

/// Example usage and documentation
/// 
/// IMPORTANT: These operations require Firebase Authentication and admin privileges
/// They should NOT be called from the mobile app directly
/// 
/// Use this helper during development to upload new versions:
/// 
/// ```dart
/// // Step 1: Upload hymns file to Firebase Storage
/// final downloadUrl = await FirebaseHymnsHelper.uploadHymnsToStorage(
///   version: '2.1.0',
/// );
/// 
/// if (downloadUrl != null) {
///   // Step 2: Update metadata in Realtime Database
///   await FirebaseHymnsHelper.updateMetadataInDatabase(
///     version: '2.1.0',
///     downloadUrl: downloadUrl,
///     fileSize: 803840, // Get from file stats
///     hymnsCount: 850,  // Count hymns in JSON
///     checksum: 'a3f5e8d...', // Calculate MD5
///     minAppVersion: '1.0.0',
///     releaseNotes: 'Added 15 new hymns',
///   );
/// }
/// ```
/// 
/// For production uploads, consider using Firebase Admin SDK from a secure backend

