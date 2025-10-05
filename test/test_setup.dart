import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hymnes_sda_fr/firebase_options.dart';

/// Setup Firebase for testing
Future<void> setupFirebaseForTesting() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

/// Setup Firebase with test configuration
Future<void> setupFirebaseTestApp() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with test configuration
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'test-api-key',
      appId: 'test-app-id',
      messagingSenderId: 'test-sender-id',
      projectId: 'hymnes-sda-fr',
      storageBucket: 'hymnes-sda-fr.firebasestorage.app',
    ),
  );
}
