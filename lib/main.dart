import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hymnes_sda_fr/firebase_options.dart';
import 'package:hymnes_sda_fr/hymnes.dart';

import 'core/services/favorites_sync_service.dart';
import 'core/services/posthog_service.dart';
import 'core/services/storage_service.dart';

void main() async {
  // init WidgetsFlutterBinding if not yet
  WidgetsFlutterBinding.ensureInitialized();

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
  // Uncomment the line below to clear all data if you encounter type errors
  // await StorageService().clearAllData();

  // Track app launch
  await PostHogService().trackAppLaunch();

  runApp(const HymnesApp());
}
