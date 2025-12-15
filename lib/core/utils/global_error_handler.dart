import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hymnes_sda_fr/core/navigation/navigation_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../services/error_logging_service.dart';

/// Global error handler for Flutter applications
/// Catches and logs all unhandled errors, exceptions, and framework errors
class GlobalErrorHandler {
  static final GlobalErrorHandler _instance = GlobalErrorHandler._internal();
  factory GlobalErrorHandler() => _instance;
  GlobalErrorHandler._internal();

  final ErrorLoggingService _errorLogger = ErrorLoggingService();
  bool _isInitialized = false;

  /// Initialize the global error handler
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set up Flutter error handling
      FlutterError.onError = (FlutterErrorDetails details) {
        _handleFlutterError(details);
      };

      // Set up zone error handling for async errors
      runZonedGuarded(
        () {
          // This is where your app runs
        },
        (error, stackTrace) {
          _handleZoneError(error, stackTrace);
        },
      );

      // Set up isolate error handling
      Isolate.current.addErrorListener(
        RawReceivePort((pair) async {
          final List<dynamic> errorAndStacktrace = pair;
          final error = errorAndStacktrace[0];
          final stackTrace = errorAndStacktrace[1];
          await _handleIsolateError(error, stackTrace);
        }).sendPort,
      );

      _isInitialized = true;
      await _errorLogger.logInfo(
        'GlobalErrorHandler',
        'Global error handler initialized successfully',
      );
    } catch (e) {
      debugPrint('Failed to initialize GlobalErrorHandler: $e');
      rethrow;
    }
  }

  /// Handle Flutter framework errors
  Future<void> _handleFlutterError(FlutterErrorDetails details) async {
    try {
      // Log to console in debug mode
      if (kDebugMode) {
        FlutterError.presentError(details);
      }

      // Log to Sentry
      await _errorLogger.logError(
        'FlutterError',
        'Flutter framework error: ${details.exception}',
        error: details.exception,
        stackTrace: details.stack,
        context: {
          'library': details.library,
          'context': details.context?.toString(),
          'informationCollector':
              details.informationCollector?.call().toString(),
        },
      );

      // Also capture with Sentry directly for Flutter errors
      await Sentry.captureException(
        details.exception,
        stackTrace: details.stack,
        withScope: (scope) {
          scope.setTag('error_type', 'flutter_error');
          scope.setTag('environment', kDebugMode ? 'debug' : 'production');
        },
      );
      
      // Note: Sentry automatically sends events, no need to flush
    } catch (e) {
      debugPrint('Error in _handleFlutterError: $e');
    }
  }

  /// Handle zone errors (async errors)
  Future<void> _handleZoneError(dynamic error, StackTrace stackTrace) async {
    try {
      await _errorLogger.logError(
        'ZoneError',
        'Unhandled async error: ${error.toString()}',
        error: error,
        stackTrace: stackTrace,
        context: {
          'error_type': error.runtimeType.toString(),
        },
      );

      // Also capture with Sentry directly
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('error_type', 'zone_error');
          scope.setTag('environment', kDebugMode ? 'debug' : 'production');
        },
      );
      
      // Note: Sentry automatically sends events, no need to flush
    } catch (e) {
      debugPrint('Error in _handleZoneError: $e');
    }
  }

  /// Handle isolate errors
  Future<void> _handleIsolateError(dynamic error, StackTrace stackTrace) async {
    try {
      await _errorLogger.logError(
        'IsolateError',
        'Isolate error: ${error.toString()}',
        error: error,
        stackTrace: stackTrace,
        context: {
          'error_type': error.runtimeType.toString(),
        },
      );

      // Also capture with Sentry directly
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('error_type', 'isolate_error');
          scope.setTag('environment', kDebugMode ? 'debug' : 'production');
        },
      );
      
      // Note: Sentry automatically sends events, no need to flush
    } catch (e) {
      debugPrint('Error in _handleIsolateError: $e');
    }
  }

  /// Handle specific error types with custom logic
  Future<void> handleCustomError(
    String source,
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String? userId,
    bool showUserMessage = false,
    String? userMessage,
  }) async {
    try {
      await _errorLogger.logError(
        source,
        'Custom error: ${error.toString()}',
        error: error,
        stackTrace: stackTrace,
        context: context,
        userId: userId,
      );

      // Show user-friendly message if requested
      if (showUserMessage && userMessage != null) {
        // You can integrate with your toast/notification system here
        debugPrint('User message: $userMessage');
      }
    } catch (e) {
      debugPrint('Error in handleCustomError: $e');
    }
  }

  /// Wrap a function with error handling
  Future<T?> safeExecute<T>(
    Future<T> Function() function, {
    String? source,
    Map<String, dynamic>? context,
    String? userId,
    T? fallbackValue,
    bool logErrors = true,
  }) async {
    try {
      return await function();
    } catch (error, stackTrace) {
      if (logErrors) {
        await _errorLogger.logError(
          source ?? 'SafeExecute',
          'Error in safe execution: ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
          context: context,
          userId: userId,
        );
      }
      return fallbackValue;
    }
  }

  /// Wrap a synchronous function with error handling
  T? safeExecuteSync<T>(
    T Function() function, {
    String? source,
    Map<String, dynamic>? context,
    String? userId,
    T? fallbackValue,
    bool logErrors = true,
  }) {
    try {
      return function();
    } catch (error, stackTrace) {
      if (logErrors) {
        _errorLogger.logError(
          source ?? 'SafeExecuteSync',
          'Error in safe sync execution: ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
          context: context,
          userId: userId,
        );
      }
      return fallbackValue;
    }
  }
}

/// Extension to add error handling to BuildContext
extension ErrorHandlingContext on BuildContext {
  /// Show error dialog with Sentry logging
  Future<void> showErrorDialog(
    String title,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String? userId,
  }) async {
    try {
      // Log the error
      await ErrorLoggingService().logUIError(
        'ErrorDialog',
        ModalRoute.of(this)?.settings.name ?? 'Unknown',
        message,
        error: error,
        stackTrace: stackTrace,
        uiContext: context,
        userId: userId,
      );

      // Show dialog
      if (mounted) {
        showDialog(
          context: this,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => NavigationService.pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error showing error dialog: $e');
    }
  }

  /// Show error snackbar with Sentry logging
  Future<void> showErrorSnackBar(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String? userId,
    Duration duration = const Duration(seconds: 4),
  }) async {
    try {
      // Log the error
      await ErrorLoggingService().logUIError(
        'ErrorSnackBar',
        ModalRoute.of(this)?.settings.name ?? 'Unknown',
        message,
        error: error,
        stackTrace: stackTrace,
        uiContext: context,
        userId: userId,
      );

      // Show snackbar
      if (mounted) {
        ScaffoldMessenger.of(this).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: duration,
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(this).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error showing error snackbar: $e');
    }
  }
}
