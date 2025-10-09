import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hymnes_sda_fr/firebase_options.dart';
import 'package:hymnes_sda_fr/hymnes.dart';
import 'package:hymnes_sda_fr/shared/constants/app_configs.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'core/services/error_logging_service.dart';
import 'core/services/favorites_sync_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/posthog_service.dart';
import 'core/services/storage_service.dart';
import 'core/utils/global_error_handler.dart';

void main() async {
  // Initialize Sentry binding instead of regular WidgetsFlutterBinding
  SentryWidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize PostHog service
  await PostHogService().initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize services
  await StorageService().initialize();
  await FavoritesSyncService().initialize();
  await NotificationService().initialize();

  // Track app launch
  await PostHogService().trackAppLaunch();

  // Initialize OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(AppConfigs.onesignalAppId);
  OneSignal.Notifications.requestPermission(false);

  await SentryFlutter.init(
    (options) {
      options.dsn = AppConfigs.sentryDsn;
      // Adds request headers and IP for users, for more info visit:
      // https://docs.sentry.io/platforms/dart/guides/flutter/data-management/data-collected/
      options.sendDefaultPii = true;
      options.enableLogs = true;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      options.profilesSampleRate = 1.0;
      // Configure Session Replay
      options.replay.sessionSampleRate = 0.1;
      options.replay.onErrorSampleRate = 1.0;
      options.privacy.unmask<WebViewWidget>();
    },
    appRunner: () async {
      // Initialize error logging system
      await ErrorLoggingService().initialize();
      await GlobalErrorHandler().initialize();

      runApp(const HymnesApp());
    },
  );
}
