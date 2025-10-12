import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/hymn.dart';

/// Service to manage pending operations that need to be synced when back online
class PendingOperationsService {
  static final PendingOperationsService _instance =
      PendingOperationsService._internal();
  factory PendingOperationsService() => _instance;
  PendingOperationsService._internal();

  final Logger _logger = Logger();
  static const String _pendingOperationsKey = 'pending_favorites_operations';

  /// Add a pending operation
  Future<void> addPendingOperation(PendingOperation operation) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingOperations = await getPendingOperations();

      // Remove any existing operation for the same hymn number
      existingOperations
          .removeWhere((op) => op.hymnNumber == operation.hymnNumber);

      // Add the new operation
      existingOperations.add(operation);

      // Save back to SharedPreferences
      final operationsJson =
          existingOperations.map((op) => op.toJson()).toList();
      await prefs.setString(_pendingOperationsKey, jsonEncode(operationsJson));

      _logger.d(
          'Added pending operation: ${operation.type} for hymn ${operation.hymnNumber}');
    } catch (e) {
      _logger.e('Error adding pending operation: $e');
    }
  }

  /// Get all pending operations
  Future<List<PendingOperation>> getPendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final operationsJson = prefs.getString(_pendingOperationsKey);

      if (operationsJson == null) return [];

      final List<dynamic> operationsList = jsonDecode(operationsJson);
      return operationsList
          .map((json) => PendingOperation.fromJson(json))
          .toList();
    } catch (e) {
      _logger.e('Error getting pending operations: $e');
      return [];
    }
  }

  /// Remove a pending operation
  Future<void> removePendingOperation(String hymnNumber) async {
    try {
      final existingOperations = await getPendingOperations();
      existingOperations.removeWhere((op) => op.hymnNumber == hymnNumber);

      final prefs = await SharedPreferences.getInstance();
      final operationsJson =
          existingOperations.map((op) => op.toJson()).toList();
      await prefs.setString(_pendingOperationsKey, jsonEncode(operationsJson));

      _logger.d('Removed pending operation for hymn $hymnNumber');
    } catch (e) {
      _logger.e('Error removing pending operation: $e');
    }
  }

  /// Clear all pending operations
  Future<void> clearAllPendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingOperationsKey);
      _logger.d('Cleared all pending operations');
    } catch (e) {
      _logger.e('Error clearing pending operations: $e');
    }
  }

  /// Get pending operations count
  Future<int> getPendingOperationsCount() async {
    final operations = await getPendingOperations();
    return operations.length;
  }
}

/// Represents a pending operation that needs to be synced
class PendingOperation {
  final String hymnNumber;
  final PendingOperationType type;
  final Hymn? hymn; // Only for ADD operations
  final DateTime timestamp;

  PendingOperation({
    required this.hymnNumber,
    required this.type,
    this.hymn,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'hymnNumber': hymnNumber,
      'type': type.name,
      'hymn': hymn?.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PendingOperation.fromJson(Map<String, dynamic> json) {
    return PendingOperation(
      hymnNumber: json['hymnNumber'],
      type: PendingOperationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PendingOperationType.ADD,
      ),
      hymn: json['hymn'] != null ? Hymn.fromJson(json['hymn']) : null,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

enum PendingOperationType {
  ADD,
  REMOVE,
}
