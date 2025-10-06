import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Centralized error logging service that integrates with Sentry
/// Provides comprehensive error tracking across the entire application
class ErrorLoggingService {
  static final ErrorLoggingService _instance = ErrorLoggingService._internal();
  factory ErrorLoggingService() => _instance;
  ErrorLoggingService._internal();

  final Logger _logger = Logger();
  bool _isInitialized = false;

  /// Initialize the error logging service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isInitialized = true;
      _logger.i('ErrorLoggingService initialized successfully');

      // Log service initialization
      await logInfo('ErrorLoggingService', 'Service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize ErrorLoggingService: $e');
      rethrow;
    }
  }

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  // ============================================================================
  // ERROR LOGGING METHODS
  // ============================================================================

  /// Log an error with context information
  Future<void> logError(
    String source,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String? userId,
    SentryLevel level = SentryLevel.error,
  }) async {
    try {
      // Log to console in debug mode
      if (kDebugMode) {
        _logger.e('[$source] $message', error: error, stackTrace: stackTrace);
      }

      // Capture the event with Sentry
      await Sentry.captureEvent(
        SentryEvent(
          message: SentryMessage(message),
          level: level,
          logger: source,
          tags: {
            'source': source,
            'platform': defaultTargetPlatform.name,
          },
          user: userId != null ? SentryUser(id: userId) : null,
          exceptions: error != null
              ? [
                  SentryException(
                    type: error.runtimeType.toString(),
                    value: error.toString(),
                  ),
                ]
              : null,
        ),
      );
    } catch (e) {
      _logger.e('Failed to log error to Sentry: $e');
    }
  }

  /// Log an exception with full context
  Future<void> logException(
    String source,
    Exception exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String? userId,
    SentryLevel level = SentryLevel.error,
  }) async {
    await logError(
      source,
      'Exception occurred: ${exception.toString()}',
      error: exception,
      stackTrace: stackTrace,
      context: context,
      userId: userId,
      level: level,
    );
  }

  /// Log a warning
  Future<void> logWarning(
    String source,
    String message, {
    Map<String, dynamic>? context,
    String? userId,
  }) async {
    await logError(
      source,
      message,
      context: context,
      userId: userId,
      level: SentryLevel.warning,
    );
  }

  /// Log informational message
  Future<void> logInfo(
    String source,
    String message, {
    Map<String, dynamic>? context,
    String? userId,
  }) async {
    await logError(
      source,
      message,
      context: context,
      userId: userId,
      level: SentryLevel.info,
    );
  }

  /// Log debug information
  Future<void> logDebug(
    String source,
    String message, {
    Map<String, dynamic>? context,
    String? userId,
  }) async {
    if (kDebugMode) {
      await logError(
        source,
        message,
        context: context,
        userId: userId,
        level: SentryLevel.debug,
      );
    }
  }

  // ============================================================================
  // SPECIALIZED LOGGING METHODS
  // ============================================================================

  /// Log network-related errors
  Future<void> logNetworkError(
    String source,
    String url,
    int? statusCode,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? requestContext,
    String? userId,
  }) async {
    final context = {
      'url': url,
      'statusCode': statusCode,
      'requestContext': requestContext,
    };

    await logError(
      source,
      'Network error: $message',
      error: error,
      stackTrace: stackTrace,
      context: context,
      userId: userId,
    );
  }

  /// Log database-related errors
  Future<void> logDatabaseError(
    String source,
    String operation,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? queryContext,
    String? userId,
  }) async {
    final context = {
      'operation': operation,
      'queryContext': queryContext,
    };

    await logError(
      source,
      'Database error: $message',
      error: error,
      stackTrace: stackTrace,
      context: context,
      userId: userId,
    );
  }

  /// Log authentication-related errors
  Future<void> logAuthError(
    String source,
    String authMethod,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? authContext,
    String? userId,
  }) async {
    final context = {
      'authMethod': authMethod,
      'authContext': authContext,
    };

    await logError(
      source,
      'Authentication error: $message',
      error: error,
      stackTrace: stackTrace,
      context: context,
      userId: userId,
    );
  }

  /// Log audio-related errors
  Future<void> logAudioError(
    String source,
    String hymnNumber,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? audioContext,
    String? userId,
  }) async {
    final context = {
      'hymnNumber': hymnNumber,
      'audioContext': audioContext,
    };

    await logError(
      source,
      'Audio error: $message',
      error: error,
      stackTrace: stackTrace,
      context: context,
      userId: userId,
    );
  }

  /// Log UI-related errors
  Future<void> logUIError(
    String source,
    String screen,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? uiContext,
    String? userId,
  }) async {
    final context = {
      'screen': screen,
      'uiContext': uiContext,
    };

    await logError(
      source,
      'UI error: $message',
      error: error,
      stackTrace: stackTrace,
      context: context,
      userId: userId,
    );
  }

  // ============================================================================
  // USER CONTEXT METHODS
  // ============================================================================

  /// Set user context for error tracking
  Future<void> setUserContext({
    required String userId,
    String? email,
    String? username,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await Sentry.configureScope((scope) {
        scope.setUser(SentryUser(
          id: userId,
          email: email,
          username: username,
        ));
      });

      _logger.d('User context set for error tracking: $userId');
    } catch (e) {
      _logger.e('Failed to set user context: $e');
    }
  }

  /// Clear user context
  Future<void> clearUserContext() async {
    try {
      await Sentry.configureScope((scope) {
        scope.setUser(null);
      });

      _logger.d('User context cleared');
    } catch (e) {
      _logger.e('Failed to clear user context: $e');
    }
  }

  /// Add breadcrumb for debugging
  Future<void> addBreadcrumb(
    String message, {
    String? category,
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? data,
  }) async {
    try {
      await Sentry.addBreadcrumb(Breadcrumb(
        message: message,
        category: category,
        level: level,
        data: data,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _logger.e('Failed to add breadcrumb: $e');
    }
  }

  // ============================================================================
  // PERFORMANCE MONITORING
  // ============================================================================

  /// Start a performance transaction
  ISentrySpan? startTransaction(
    String name,
    String operation, {
    String? description,
    Map<String, dynamic>? data,
  }) {
    try {
      return Sentry.startTransaction(
        name,
        operation,
        description: description,
      );
    } catch (e) {
      _logger.e('Failed to start transaction: $e');
      return null;
    }
  }

  /// Log performance metrics
  Future<void> logPerformance(
    String source,
    String operation,
    Duration duration, {
    Map<String, dynamic>? context,
    String? userId,
  }) async {
    await logInfo(
      source,
      'Performance: $operation took ${duration.inMilliseconds}ms',
      context: {
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
        'context': context,
      },
      userId: userId,
    );
  }
}
