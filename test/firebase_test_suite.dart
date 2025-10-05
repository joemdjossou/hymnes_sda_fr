import 'package:flutter_test/flutter_test.dart';

import 'unit/models/timestamp_handling_test.dart' as timestamp_handling_test;
import 'unit/repositories/firestore_integration_test.dart'
    as firestore_integration_test;
import 'unit/services/firebase_connection_test.dart'
    as firebase_connection_test;
import 'unit/services/simple_firebase_test.dart' as simple_firebase_test;

void main() {
  group('Firebase Test Suite', () {
    group('Firebase Connection Tests', firebase_connection_test.main);
    group('Simple Firebase Tests', simple_firebase_test.main);
    group('Timestamp Handling Tests', timestamp_handling_test.main);
    group('Firestore Integration Tests', firestore_integration_test.main);
  });
}
