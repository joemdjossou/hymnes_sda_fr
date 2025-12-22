import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';

import '../models/hymns_version_metadata.dart';

/// Multi-layer validation for hymns data files
class HymnsValidator {
  static final Logger _logger = Logger();

  /// Level 1: File integrity validation
  /// Checks file size and checksum
  static Future<ValidationResult> validateFileIntegrity(
    File file,
    RemoteHymnsMetadata metadata,
  ) async {
    try {
      // Check if file exists
      if (!await file.exists()) {
        return ValidationResult.failure(
          layer: 'File Integrity',
          reason: 'File does not exist',
        );
      }

      // Check file size (only if provided and > 0)
      if (metadata.fileSize > 0) {
        final fileSize = await file.length();
        final expectedSize = metadata.fileSize;
        final sizeVariance = (expectedSize * 0.01).round();
        final minSize = expectedSize - sizeVariance;
        final maxSize = expectedSize + sizeVariance;

        if (fileSize < minSize || fileSize > maxSize) {
          return ValidationResult.failure(
            layer: 'File Integrity',
            reason: 'File size mismatch: expected ~$expectedSize bytes, got $fileSize bytes',
          );
        }
      }

      // Validate checksum if provided (not empty)
      if (metadata.checksum.isNotEmpty) {
        final actualChecksum = await _calculateChecksum(file);
        if (actualChecksum != metadata.checksum) {
          return ValidationResult.failure(
            layer: 'File Integrity',
            reason: 'Checksum mismatch: expected ${metadata.checksum}, got $actualChecksum',
          );
        }
      }

      return ValidationResult.success(
        layer: 'File Integrity',
        message: 'File size and checksum validated',
      );
    } catch (e) {
      return ValidationResult.failure(
        layer: 'File Integrity',
        reason: 'Error during integrity check: $e',
      );
    }
  }

  /// Level 2: JSON structure validation
  /// Ensures the file is valid JSON and has expected structure
  static Future<ValidationResult> validateJsonStructure(File file) async {
    try {
      // Read with UTF-8 encoding to preserve accents and special characters
      final content = await file.readAsString(encoding: utf8);

      // Try to parse JSON
      final dynamic parsed = json.decode(content);

      // Check if it's a list
      if (parsed is! List) {
        return ValidationResult.failure(
          layer: 'JSON Structure',
          reason: 'Root element must be a JSON array',
        );
      }

      // Check if list is not empty
      if (parsed.isEmpty) {
        return ValidationResult.failure(
          layer: 'JSON Structure',
          reason: 'Hymns list is empty',
        );
      }

      return ValidationResult.success(
        layer: 'JSON Structure',
        message: 'Valid JSON array with ${parsed.length} items',
      );
    } on FormatException catch (e) {
      return ValidationResult.failure(
        layer: 'JSON Structure',
        reason: 'Invalid JSON format: ${e.message}',
      );
    } catch (e) {
      return ValidationResult.failure(
        layer: 'JSON Structure',
        reason: 'Error parsing JSON: $e',
      );
    }
  }

  /// Level 3: Required fields validation
  /// Checks if each hymn has all required fields
  static Future<ValidationResult> validateRequiredFields(File file) async {
    try {
      // Read with UTF-8 encoding to preserve accents and special characters
      final content = await file.readAsString(encoding: utf8);
      final List<dynamic> hymns = json.decode(content) as List<dynamic>;

      // Fields that must exist and be non-empty
      final criticalFields = [
        'number',
        'title',
        'lyrics',
      ];

      // Fields that must exist but can be empty
      final optionalFields = [
        'author',
        'composer',
        'style',
        'sopranoFile',
        'altoFile',
        'tenorFile',
        'bassFile',
        'midiFile',
        'theme',
        'subtheme',
        'story',
      ];

      for (int i = 0; i < hymns.length; i++) {
        final hymn = hymns[i];

        if (hymn is! Map<String, dynamic>) {
          return ValidationResult.failure(
            layer: 'Required Fields',
            reason: 'Hymn at index $i is not a valid object',
          );
        }

        // Check critical fields (must exist and be non-empty)
        for (final field in criticalFields) {
          if (!hymn.containsKey(field)) {
            return ValidationResult.failure(
              layer: 'Required Fields',
              reason: 'Hymn at index $i missing critical field: $field',
            );
          }

          if (hymn[field] == null || hymn[field].toString().trim().isEmpty) {
            return ValidationResult.failure(
              layer: 'Required Fields',
              reason: 'Hymn at index $i has empty critical field: $field',
            );
          }
        }

        // Check optional fields (must exist but can be empty)
        for (final field in optionalFields) {
          if (!hymn.containsKey(field)) {
            return ValidationResult.failure(
              layer: 'Required Fields',
              reason: 'Hymn at index $i missing optional field: $field',
            );
          }
          // Field exists, but can be empty/null - that's OK
        }
      }

      return ValidationResult.success(
        layer: 'Required Fields',
        message: 'All hymns have required fields',
      );
    } catch (e) {
      return ValidationResult.failure(
        layer: 'Required Fields',
        reason: 'Error validating fields: $e',
      );
    }
  }

  /// Level 4: Data consistency validation
  /// Checks hymn count and data consistency
  static Future<ValidationResult> validateDataConsistency(
    File file,
    RemoteHymnsMetadata metadata,
  ) async {
    try {
      // Read with UTF-8 encoding to preserve accents and special characters
      final content = await file.readAsString(encoding: utf8);
      final List<dynamic> hymns = json.decode(content) as List<dynamic>;

      final actualCount = hymns.length;

      // Check hymn count (only if provided and > 0, allow ±5% variance)
      if (metadata.hymnsCount > 0) {
        final expectedCount = metadata.hymnsCount;
        final countVariance = (expectedCount * 0.05).round();
        final minCount = expectedCount - countVariance;
        final maxCount = expectedCount + countVariance;

        if (actualCount < minCount || actualCount > maxCount) {
          return ValidationResult.failure(
            layer: 'Data Consistency',
            reason: 'Hymn count mismatch: expected ~$expectedCount, got $actualCount',
          );
        }
      }

      return ValidationResult.success(
        layer: 'Data Consistency',
        message: 'Data consistency validated: $actualCount hymns',
      );
    } catch (e) {
      return ValidationResult.failure(
        layer: 'Data Consistency',
        reason: 'Error validating consistency: $e',
      );
    }
  }

  /// Level 5: Business logic validation
  /// Validates hymn numbers are unique and properly formatted
  static Future<ValidationResult> validateBusinessLogic(File file) async {
    try {
      // Read with UTF-8 encoding to preserve accents and special characters
      final content = await file.readAsString(encoding: utf8);
      final List<dynamic> hymns = json.decode(content) as List<dynamic>;

      final Set<String> hymnNumbers = {};

      for (int i = 0; i < hymns.length; i++) {
        final hymn = hymns[i] as Map<String, dynamic>;
        final number = hymn['number']?.toString() ?? '';

        // Check if number is not empty
        if (number.isEmpty) {
          return ValidationResult.failure(
            layer: 'Business Logic',
            reason: 'Hymn at index $i has empty number',
          );
        }

        // Check for duplicates
        if (hymnNumbers.contains(number)) {
          return ValidationResult.failure(
            layer: 'Business Logic',
            reason: 'Duplicate hymn number found: $number',
          );
        }

        hymnNumbers.add(number);
      }

      return ValidationResult.success(
        layer: 'Business Logic',
        message: 'All hymn numbers are unique and valid',
      );
    } catch (e) {
      return ValidationResult.failure(
        layer: 'Business Logic',
        reason: 'Error validating business logic: $e',
      );
    }
  }

  /// Run all validation layers
  static Future<ValidationSummary> validateAll(
    File file,
    RemoteHymnsMetadata metadata,
  ) async {
    _logger.i('Starting comprehensive validation for: ${file.path}');

    final results = <ValidationResult>[];

    // Run all validation layers in sequence
    results.add(await validateFileIntegrity(file, metadata));
    if (!results.last.isValid) {
      return ValidationSummary(results: results);
    }

    results.add(await validateJsonStructure(file));
    if (!results.last.isValid) {
      return ValidationSummary(results: results);
    }

    results.add(await validateRequiredFields(file));
    if (!results.last.isValid) {
      return ValidationSummary(results: results);
    }

    results.add(await validateDataConsistency(file, metadata));
    if (!results.last.isValid) {
      return ValidationSummary(results: results);
    }

    results.add(await validateBusinessLogic(file));

    return ValidationSummary(results: results);
  }

  /// Calculate MD5 checksum of file
  static Future<String> _calculateChecksum(File file) async {
    final bytes = await file.readAsBytes();
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Quick validation for existing local files (without metadata)
  static Future<bool> quickValidate(File file) async {
    try {
      if (!await file.exists()) return false;

      // Check file size is reasonable (not empty, not too small)
      final size = await file.length();
      if (size < 1000) return false; // Less than 1KB is suspicious

      // Try to parse JSON
      // Read with UTF-8 encoding to preserve accents and special characters
      final content = await file.readAsString(encoding: utf8);
      final parsed = json.decode(content);

      // Check if it's a non-empty list
      if (parsed is! List || parsed.isEmpty) return false;

      // Check first item has required structure
      final first = parsed[0];
      if (first is! Map<String, dynamic>) return false;

      // Check for essential fields
      final hasEssentialFields = first.containsKey('number') &&
          first.containsKey('title') &&
          first.containsKey('lyrics');

      return hasEssentialFields;
    } catch (e) {
      _logger.w('Quick validation failed: $e');
      return false;
    }
  }
}

/// Result of a single validation layer
class ValidationResult {
  final String layer;
  final bool isValid;
  final String message;

  const ValidationResult({
    required this.layer,
    required this.isValid,
    required this.message,
  });

  factory ValidationResult.success({
    required String layer,
    required String message,
  }) {
    return ValidationResult(
      layer: layer,
      isValid: true,
      message: message,
    );
  }

  factory ValidationResult.failure({
    required String layer,
    required String reason,
  }) {
    return ValidationResult(
      layer: layer,
      isValid: false,
      message: reason,
    );
  }

  @override
  String toString() {
    final status = isValid ? '✓' : '✗';
    return '$status [$layer] $message';
  }
}

/// Summary of all validation results
class ValidationSummary {
  final List<ValidationResult> results;

  const ValidationSummary({required this.results});

  bool get isValid => results.every((r) => r.isValid);

  bool get hasFailures => results.any((r) => !r.isValid);

  ValidationResult? get firstFailure =>
      results.firstWhere((r) => !r.isValid, orElse: () => results.first);

  int get passedCount => results.where((r) => r.isValid).length;

  int get totalCount => results.length;

  String get summary {
    if (isValid) {
      return 'All validations passed ($totalCount/$totalCount)';
    } else {
      return 'Validation failed ($passedCount/$totalCount passed)\n'
          'First failure: ${firstFailure?.message}';
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Validation Summary:');
    for (final result in results) {
      buffer.writeln('  $result');
    }
    buffer.writeln('Overall: ${isValid ? 'PASSED ✓' : 'FAILED ✗'}');
    return buffer.toString();
  }
}

