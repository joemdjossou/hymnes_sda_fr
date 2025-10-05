import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hymnes_sda_fr/firebase_options.dart';
import 'package:hymnes_sda_fr/hymnes.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'core/services/favorites_sync_service.dart';
import 'core/services/storage_service.dart';

void main() async {
  // init WidgetsFlutterBinding if not yet
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final config =
      PostHogConfig('phc_QDMI8BXsq8vFdtUfyogL4AWCZSkPPjT93idVFiKXSTT');
  config.host = 'https://us.i.posthog.com';
  config.debug = true;
  config.captureApplicationLifecycleEvents = true;
  // check https://posthog.com/docs/session-replay/installation?tab=Flutter
  // for more config and to learn about how we capture sessions on mobile
  // and what to expect
  config.sessionReplay = true;
  // choose whether to mask images or text
  config.sessionReplayConfig.maskAllTexts = false;
  config.sessionReplayConfig.maskAllImages = false;
  // Setup PostHog with the given Context and Config
  await Posthog().setup(config);

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
  // Uncomment the line below to clear all data if you encounter type errors
  // await StorageService().clearAllData();

  runApp(const HymnesApp());
}
