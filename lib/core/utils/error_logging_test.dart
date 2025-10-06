import 'package:flutter/foundation.dart';

import '../services/error_logging_service.dart';

/// Test utility for error logging functionality
/// This class provides methods to test various error logging scenarios
class ErrorLoggingTest {
  static final ErrorLoggingTest _instance = ErrorLoggingTest._internal();
  factory ErrorLoggingTest() => _instance;
  ErrorLoggingTest._internal();

  final ErrorLoggingService _errorLogger = ErrorLoggingService();

  /// Test basic error logging functionality
  Future<void> testBasicErrorLogging() async {
    try {
      await _errorLogger.logInfo(
        'ErrorLoggingTest',
        'Testing basic error logging functionality',
        context: {
          'testType': 'basic',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      await _errorLogger.logWarning(
        'ErrorLoggingTest',
        'This is a test warning message',
        context: {
          'testType': 'warning',
          'severity': 'medium',
        },
      );

      await _errorLogger.logError(
        'ErrorLoggingTest',
        'This is a test error message',
        error: Exception('Test exception for error logging'),
        stackTrace: StackTrace.current,
        context: {
          'testType': 'error',
          'severity': 'high',
        },
      );

      debugPrint('✅ Basic error logging test completed successfully');
    } catch (e) {
      debugPrint('❌ Basic error logging test failed: $e');
    }
  }

  /// Test specialized error logging methods
  Future<void> testSpecializedErrorLogging() async {
    try {
      // Test network error logging
      await _errorLogger.logNetworkError(
        'ErrorLoggingTest',
        'https://example.com/api/test',
        404,
        'Test network error',
        error: Exception('Network connection failed'),
        stackTrace: StackTrace.current,
        requestContext: {
          'method': 'GET',
          'headers': {'Content-Type': 'application/json'},
        },
      );

      // Test database error logging
      await _errorLogger.logDatabaseError(
        'ErrorLoggingTest',
        'SELECT * FROM hymns',
        'Test database error',
        error: Exception('Database connection timeout'),
        stackTrace: StackTrace.current,
        queryContext: {
          'table': 'hymns',
          'operation': 'SELECT',
        },
      );

      // Test authentication error logging
      await _errorLogger.logAuthError(
        'ErrorLoggingTest',
        'email_password',
        'Test authentication error',
        error: Exception('Invalid credentials'),
        stackTrace: StackTrace.current,
        authContext: {
          'email': 'test@example.com',
          'provider': 'email_password',
        },
      );

      // Test audio error logging
      await _errorLogger.logAudioError(
        'ErrorLoggingTest',
        '001',
        'Test audio error',
        error: Exception('Audio file not found'),
        stackTrace: StackTrace.current,
        audioContext: {
          'url': 'https://example.com/audio/h001.mp3',
          'format': 'mp3',
        },
      );

      // Test UI error logging
      await _errorLogger.logUIError(
        'ErrorLoggingTest',
        'TestScreen',
        'Test UI error',
        error: Exception('Widget build failed'),
        stackTrace: StackTrace.current,
        uiContext: {
          'screen': 'TestScreen',
          'widget': 'TestWidget',
        },
      );

      debugPrint('✅ Specialized error logging test completed successfully');
    } catch (e) {
      debugPrint('❌ Specialized error logging test failed: $e');
    }
  }

  /// Test user context functionality
  Future<void> testUserContext() async {
    try {
      // Set user context
      await _errorLogger.setUserContext(
        userId: 'test_user_123',
        email: 'test@example.com',
        username: 'testuser',
        additionalData: {
          'appVersion': '1.0.0',
          'platform': defaultTargetPlatform.name,
        },
      );

      // Log an error with user context
      await _errorLogger.logError(
        'ErrorLoggingTest',
        'Test error with user context',
        context: {
          'testType': 'userContext',
        },
      );

      // Clear user context
      await _errorLogger.clearUserContext();

      debugPrint('✅ User context test completed successfully');
    } catch (e) {
      debugPrint('❌ User context test failed: $e');
    }
  }

  /// Test breadcrumb functionality
  Future<void> testBreadcrumbs() async {
    try {
      // Add some breadcrumbs
      await _errorLogger.addBreadcrumb(
        'User opened app',
        category: 'navigation',
      );

      await _errorLogger.addBreadcrumb(
        'User navigated to home screen',
        category: 'navigation',
        data: {
          'screen': 'HomeScreen',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      await _errorLogger.addBreadcrumb(
        'User searched for hymns',
        category: 'user_action',
        data: {
          'query': 'test search',
          'resultsCount': 5,
        },
      );

      // Log an error that will include the breadcrumbs
      await _errorLogger.logError(
        'ErrorLoggingTest',
        'Test error with breadcrumbs',
        context: {
          'testType': 'breadcrumbs',
        },
      );

      debugPrint('✅ Breadcrumbs test completed successfully');
    } catch (e) {
      debugPrint('❌ Breadcrumbs test failed: $e');
    }
  }

  /// Test performance monitoring
  Future<void> testPerformanceMonitoring() async {
    try {
      // Start a transaction
      final transaction = _errorLogger.startTransaction(
        'TestOperation',
        'test',
        description: 'Testing performance monitoring',
        data: {
          'testType': 'performance',
        },
      );

      // Simulate some work
      await Future.delayed(const Duration(milliseconds: 100));

      // Log performance metrics
      await _errorLogger.logPerformance(
        'ErrorLoggingTest',
        'TestOperation',
        const Duration(milliseconds: 100),
        context: {
          'testType': 'performance',
          'operation': 'TestOperation',
        },
      );

      // Finish the transaction
      transaction?.finish();

      debugPrint('✅ Performance monitoring test completed successfully');
    } catch (e) {
      debugPrint('❌ Performance monitoring test failed: $e');
    }
  }

  /// Run all error logging tests
  Future<void> runAllTests() async {
    debugPrint('🧪 Starting comprehensive error logging tests...');

    await testBasicErrorLogging();
    await testSpecializedErrorLogging();
    await testUserContext();
    await testBreadcrumbs();
    await testPerformanceMonitoring();

    debugPrint('🎉 All error logging tests completed!');
    debugPrint('📊 Check your Sentry dashboard to see the logged events.');
  }

  /// Test error logging with different severity levels
  Future<void> testSeverityLevels() async {
    try {
      await _errorLogger.logDebug(
        'ErrorLoggingTest',
        'Debug level message',
        context: {'level': 'debug'},
      );

      await _errorLogger.logInfo(
        'ErrorLoggingTest',
        'Info level message',
        context: {'level': 'info'},
      );

      await _errorLogger.logWarning(
        'ErrorLoggingTest',
        'Warning level message',
        context: {'level': 'warning'},
      );

      await _errorLogger.logError(
        'ErrorLoggingTest',
        'Error level message',
        context: {'level': 'error'},
      );

      debugPrint('✅ Severity levels test completed successfully');
    } catch (e) {
      debugPrint('❌ Severity levels test failed: $e');
    }
  }

  /// Test error logging with complex context data
  Future<void> testComplexContext() async {
    try {
      final complexContext = {
        'user': {
          'id': 'user_123',
          'email': 'user@example.com',
          'preferences': {
            'theme': 'dark',
            'language': 'en',
            'notifications': true,
          },
        },
        'app': {
          'version': '1.0.0',
          'buildNumber': '123',
          'platform': defaultTargetPlatform.name,
        },
        'session': {
          'startTime': DateTime.now().toIso8601String(),
          'duration': '5 minutes',
          'actions': ['login', 'search', 'view_hymn'],
        },
        'device': {
          'model': 'iPhone 14',
          'os': 'iOS 16.0',
          'screenSize': '390x844',
        },
      };

      await _errorLogger.logError(
        'ErrorLoggingTest',
        'Test error with complex context',
        context: complexContext,
      );

      debugPrint('✅ Complex context test completed successfully');
    } catch (e) {
      debugPrint('❌ Complex context test failed: $e');
    }
  }
}
