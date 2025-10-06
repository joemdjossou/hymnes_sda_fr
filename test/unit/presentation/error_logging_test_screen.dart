import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../lib/core/utils/error_logging_test.dart';
import '../../../lib/core/utils/global_error_handler.dart';

/// Test screen for demonstrating error logging functionality
/// This screen provides buttons to test various error logging scenarios
class ErrorLoggingTestScreen extends StatefulWidget {
  const ErrorLoggingTestScreen({super.key});

  @override
  State<ErrorLoggingTestScreen> createState() => _ErrorLoggingTestScreenState();
}

class _ErrorLoggingTestScreenState extends State<ErrorLoggingTestScreen> {
  final ErrorLoggingTest _errorTest = ErrorLoggingTest();
  final GlobalErrorHandler _globalErrorHandler = GlobalErrorHandler();

  bool _isLoading = false;
  String _lastTestResult = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Logging Test'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error Logging Test Suite',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'Test various error logging scenarios and verify they appear in your Sentry dashboard.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (_lastTestResult.isNotEmpty) ...[
                      const Gap(16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _lastTestResult,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const Gap(16),

            // Test Buttons
            _buildTestButton(
              'Run All Tests',
              'Execute comprehensive error logging tests',
              Icons.play_arrow,
              () => _runAllTests(),
            ),

            const Gap(12),

            _buildTestButton(
              'Test Basic Logging',
              'Test info, warning, and error logging',
              Icons.info_outline,
              () => _runBasicTest(),
            ),

            const Gap(12),

            _buildTestButton(
              'Test Specialized Logging',
              'Test network, database, auth, audio, and UI errors',
              Icons.bug_report,
              () => _runSpecializedTest(),
            ),

            const Gap(12),

            _buildTestButton(
              'Test User Context',
              'Test user identification and context setting',
              Icons.person,
              () => _runUserContextTest(),
            ),

            const Gap(12),

            _buildTestButton(
              'Test Breadcrumbs',
              'Test breadcrumb tracking functionality',
              Icons.timeline,
              () => _runBreadcrumbsTest(),
            ),

            const Gap(12),

            _buildTestButton(
              'Test Performance',
              'Test performance monitoring and transactions',
              Icons.speed,
              () => _runPerformanceTest(),
            ),

            const Gap(12),

            _buildTestButton(
              'Test Severity Levels',
              'Test different error severity levels',
              Icons.warning,
              () => _runSeverityTest(),
            ),

            const Gap(12),

            _buildTestButton(
              'Test Complex Context',
              'Test error logging with complex context data',
              Icons.data_object,
              () => _runComplexContextTest(),
            ),

            const Gap(24),

            // Manual Error Tests
            Text(
              'Manual Error Tests',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const Gap(12),

            _buildTestButton(
              'Trigger Flutter Error',
              'Manually trigger a Flutter framework error',
              Icons.error,
              () => _triggerFlutterError(),
              isDestructive: true,
            ),

            const Gap(12),

            _buildTestButton(
              'Trigger Async Error',
              'Manually trigger an async error',
              Icons.sync,
              () => _triggerAsyncError(),
              isDestructive: true,
            ),

            const Gap(12),

            _buildTestButton(
              'Trigger Custom Error',
              'Manually trigger a custom error with context',
              Icons.build,
              () => _triggerCustomError(),
              isDestructive: true,
            ),

            const Gap(24),

            // Instructions
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: theme.colorScheme.primary,
                        ),
                        const Gap(8),
                        Text(
                          'Instructions',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),
                    Text(
                      '1. Run the tests above to generate various error events\n'
                      '2. Check your Sentry dashboard to see the logged events\n'
                      '3. Verify that errors include proper context and stack traces\n'
                      '4. Test user context and breadcrumb functionality\n'
                      '5. Monitor performance transactions and metrics',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(
    String title,
    String description,
    IconData icon,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: _isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isDestructive
                      ? theme.colorScheme.onErrorContainer
                      : theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? theme.colorScheme.error : null,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isLoading = true;
      _lastTestResult = 'Running all tests...';
    });

    try {
      await _errorTest.runAllTests();
      setState(() {
        _lastTestResult =
            '✅ All tests completed successfully! Check your Sentry dashboard.';
      });
    } catch (e) {
      setState(() {
        _lastTestResult = '❌ Some tests failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runBasicTest() async {
    setState(() {
      _isLoading = true;
      _lastTestResult = 'Running basic logging test...';
    });

    try {
      await _errorTest.testBasicErrorLogging();
      setState(() {
        _lastTestResult = '✅ Basic logging test completed!';
      });
    } catch (e) {
      setState(() {
        _lastTestResult = '❌ Basic logging test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runSpecializedTest() async {
    setState(() {
      _isLoading = true;
      _lastTestResult = 'Running specialized logging test...';
    });

    try {
      await _errorTest.testSpecializedErrorLogging();
      setState(() {
        _lastTestResult = '✅ Specialized logging test completed!';
      });
    } catch (e) {
      setState(() {
        _lastTestResult = '❌ Specialized logging test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runUserContextTest() async {
    setState(() {
      _isLoading = true;
      _lastTestResult = 'Running user context test...';
    });

    try {
      await _errorTest.testUserContext();
      setState(() {
        _lastTestResult = '✅ User context test completed!';
      });
    } catch (e) {
      setState(() {
        _lastTestResult = '❌ User context test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runBreadcrumbsTest() async {
    setState(() {
      _isLoading = true;
      _lastTestResult = 'Running breadcrumbs test...';
    });

    try {
      await _errorTest.testBreadcrumbs();
      setState(() {
        _lastTestResult = '✅ Breadcrumbs test completed!';
      });
    } catch (e) {
      setState(() {
        _lastTestResult = '❌ Breadcrumbs test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runPerformanceTest() async {
    setState(() {
      _isLoading = true;
      _lastTestResult = 'Running performance test...';
    });

    try {
      await _errorTest.testPerformanceMonitoring();
      setState(() {
        _lastTestResult = '✅ Performance test completed!';
      });
    } catch (e) {
      setState(() {
        _lastTestResult = '❌ Performance test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runSeverityTest() async {
    setState(() {
      _isLoading = true;
      _lastTestResult = 'Running severity levels test...';
    });

    try {
      await _errorTest.testSeverityLevels();
      setState(() {
        _lastTestResult = '✅ Severity levels test completed!';
      });
    } catch (e) {
      setState(() {
        _lastTestResult = '❌ Severity levels test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runComplexContextTest() async {
    setState(() {
      _isLoading = true;
      _lastTestResult = 'Running complex context test...';
    });

    try {
      await _errorTest.testComplexContext();
      setState(() {
        _lastTestResult = '✅ Complex context test completed!';
      });
    } catch (e) {
      setState(() {
        _lastTestResult = '❌ Complex context test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _triggerFlutterError() {
    setState(() {
      _lastTestResult = 'Triggering Flutter error...';
    });

    // This will trigger a Flutter framework error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      throw FlutterError('This is a test Flutter framework error');
    });
  }

  void _triggerAsyncError() {
    setState(() {
      _lastTestResult = 'Triggering async error...';
    });

    // This will trigger an async error
    Future.delayed(const Duration(milliseconds: 100), () {
      throw Exception('This is a test async error');
    });
  }

  void _triggerCustomError() {
    setState(() {
      _lastTestResult = 'Triggering custom error...';
    });

    _globalErrorHandler.handleCustomError(
      'ErrorLoggingTestScreen',
      Exception('This is a test custom error'),
      stackTrace: StackTrace.current,
      context: {
        'screen': 'ErrorLoggingTestScreen',
        'action': 'manual_error_trigger',
        'timestamp': DateTime.now().toIso8601String(),
      },
      showUserMessage: true,
      userMessage: 'This is a test error message for the user.',
    );
  }
}
