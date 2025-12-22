import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'error_logging_service.dart';
import 'posthog_service.dart';

enum FeedbackType {
  general,
  bug,
  feature,
  review,
}

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final Logger _logger = Logger();
  final PostHogService _posthog = PostHogService();
  final ErrorLoggingService _errorLogger = ErrorLoggingService();

  /// Submit user feedback through multiple channels
  /// - PostHog: For analytics and tracking
  /// - Sentry: For bug reports and monitoring
  /// - Email: As backup and direct communication
  Future<void> submitFeedback({
    required String message,
    required FeedbackType type,
    String? userEmail,
    String? userName,
    String? userId,
  }) async {
    try {
      _logger.i('Submitting feedback: $type');

      // Get device and app info
      final deviceInfo = await _getDeviceInfo();
      final appInfo = await _getAppInfo();

      // Prepare feedback data
      final feedbackData = {
        'message': message,
        'type': type.toString().split('.').last,
        'user_email': userEmail ?? 'anonymous',
        'user_name': userName ?? 'Anonymous User',
        'user_id': userId ?? 'anonymous',
        'timestamp': DateTime.now().toIso8601String(),
        ...deviceInfo,
        ...appInfo,
      };

      // Send to PostHog for analytics
      await _sendToPostHog(feedbackData);

      // Send to Sentry for bug tracking
      await _sendToSentry(feedbackData);

      // Send email notification (optional)
      if (type == FeedbackType.bug || type == FeedbackType.feature) {
        await _sendEmailNotification(feedbackData);
      }

      _logger.i('Feedback submitted successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to submit feedback: $e');
      _errorLogger.logError(
        'FeedbackService',
        'Failed to submit feedback',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Send feedback to PostHog for analytics and tracking
  Future<void> _sendToPostHog(Map<String, dynamic> feedbackData) async {
    try {
      await _posthog.trackEvent(
        eventName: 'user_feedback_submitted',
        properties: feedbackData,
      );

      // Also track specific feedback type events
      final feedbackType = feedbackData['type'];
      await _posthog.trackEvent(
        eventName: 'feedback_$feedbackType',
        properties: feedbackData,
      );

      _logger.d('Feedback sent to PostHog');
    } catch (e) {
      _logger.e('Failed to send feedback to PostHog: $e');
    }
  }

  /// Send feedback to Sentry for bug tracking and monitoring
  Future<void> _sendToSentry(Map<String, dynamic> feedbackData) async {
    try {
      final feedbackType = feedbackData['type'];
      final message = feedbackData['message'] as String;
      final userName =
          feedbackData['user_name']?.toString() ?? 'Anonymous User';
      final userEmail = feedbackData['user_email']?.toString() ?? '';

      // Set user context for this feedback
      await Sentry.configureScope((scope) {
        scope.setUser(SentryUser(
          id: feedbackData['user_id']?.toString(),
          email: userEmail.isNotEmpty ? userEmail : null,
          username: userName,
        ));

        // Add feedback as tags for easy filtering in Sentry
        scope.setTag('feedback_type', feedbackType);
        scope.setTag(
            'platform', feedbackData['platform']?.toString() ?? 'unknown');
        scope.setTag('app_version',
            feedbackData['app_version']?.toString() ?? 'unknown');

        // Add device info as context
        scope.setContexts('device', {
          'platform': feedbackData['platform'],
          'os_name': feedbackData['os_name'],
          'os_version': feedbackData['os_version'],
          'device_type': feedbackData['device_type'],
          'locale': feedbackData['locale'],
          'app_version': feedbackData['app_version'],
          'app_build': feedbackData['app_build'],
        });

        // Add feedback details as context (using Contexts instead of deprecated setExtra)
        scope.setContexts('feedback', {
          'message': message,
          'timestamp': feedbackData['timestamp'],
          'type': feedbackType,
        });
      });

      // Capture the feedback as a message event
      final sentryId = await Sentry.captureMessage(
        '[$feedbackType] $message',
        level: _getSentryLevel(feedbackType),
      );

      _logger.d('Feedback sent to Sentry: $sentryId');

      // Clear the scope after sending
      await Sentry.configureScope((scope) => scope.clear());
    } catch (e) {
      _logger.e('Failed to send feedback to Sentry: $e');
    }
  }

  /// Send email notification for critical feedback (bugs, feature requests)
  Future<void> _sendEmailNotification(Map<String, dynamic> feedbackData) async {
    try {
      final subject = Uri.encodeComponent(
          'Hymnes SDA - ${feedbackData['type'].toString().toUpperCase()}: User Feedback');

      final body = Uri.encodeComponent(
        '''
Feedback Type: ${feedbackData['type']}
User: ${feedbackData['user_name']} (${feedbackData['user_email']})
User ID: ${feedbackData['user_id']}
Timestamp: ${feedbackData['timestamp']}

Message:
${feedbackData['message']}

---
Device Information:
Platform: ${feedbackData['platform']}
OS: ${feedbackData['os_name']} ${feedbackData['os_version']}
App Version: ${feedbackData['app_version']} (${feedbackData['app_build']})
Device Type: ${feedbackData['device_type']}
Locale: ${feedbackData['locale']}
        ''',
      );

      // Send to both email addresses
      final emailUri =
          Uri.parse('mailto:joemdjossou@gmail.com?subject=$subject&body=$body');

      // Note: This will open the user's email client
      // For server-side email sending, you'd need a backend API
      if (await canLaunchUrl(emailUri)) {
        // Don't auto-launch email client, just log for now
        // Users can still contact via feedback tracked in PostHog/Sentry
        _logger.d('Email notification prepared for both addresses: $emailUri');
      }
    } catch (e) {
      _logger.e('Failed to prepare email notification: $e');
    }
  }

  /// Get device information
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      return {
        'platform': _getPlatform(),
        'os_name': _getOSName(),
        'os_version': _getOSVersion(),
        'device_type': _getDeviceType(),
        'locale': Platform.localeName,
        'timezone': DateTime.now().timeZoneName,
        'is_debug': kDebugMode,
      };
    } catch (e) {
      _logger.e('Failed to get device info: $e');
      return {};
    }
  }

  /// Get app information
  Future<Map<String, dynamic>> _getAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return {
        'app_version': packageInfo.version,
        'app_build': packageInfo.buildNumber,
        'app_name': packageInfo.appName,
        'package_name': packageInfo.packageName,
      };
    } catch (e) {
      _logger.e('Failed to get app info: $e');
      return {
        'app_version': 'unknown',
        'app_build': 'unknown',
        'app_name': 'Hymnes SDA FR',
        'package_name': 'unknown',
      };
    }
  }

  String _getPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  String _getOSName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  String _getOSVersion() {
    try {
      return Platform.operatingSystemVersion;
    } catch (e) {
      return 'unknown';
    }
  }

  String _getDeviceType() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid || Platform.isIOS) return 'mobile';
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return 'desktop';
    }
    return 'unknown';
  }

  SentryLevel _getSentryLevel(String feedbackType) {
    switch (feedbackType) {
      case 'bug':
        return SentryLevel.error;
      case 'feature':
        return SentryLevel.info;
      case 'review':
        return SentryLevel.info;
      default:
        return SentryLevel.info;
    }
  }

  /// Send feedback via email directly (opens email client)
  Future<void> sendFeedbackEmail({
    required String message,
    required String type,
    String? userEmail,
  }) async {
    try {
      final deviceInfo = await _getDeviceInfo();
      final appInfo = await _getAppInfo();

      final subject = Uri.encodeComponent('Hymnes SDA - $type: User Feedback');
      final body = Uri.encodeComponent(
        '''
Feedback Type: $type
User Email: ${userEmail ?? 'Not provided'}
Timestamp: ${DateTime.now().toIso8601String()}

Message:
$message

---
Device Information:
Platform: ${deviceInfo['platform']}
OS: ${deviceInfo['os_name']} ${deviceInfo['os_version']}
App Version: ${appInfo['app_version']} (${appInfo['app_build']})
Device Type: ${deviceInfo['device_type']}
        ''',
      );

      // Send to both email addresses
      final emailUri =
          Uri.parse('mailto:joemdjossou@gmail.com?subject=$subject&body=$body');

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw Exception('Could not launch email client');
      }
    } catch (e) {
      _logger.e('Failed to send feedback email: $e');
      rethrow;
    }
  }
}
