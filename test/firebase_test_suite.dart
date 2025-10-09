import 'package:flutter_test/flutter_test.dart';

import 'unit/models/timestamp_handling_test.dart' as timestamp_handling_test;

void main() {
  group('Firebase Test Suite', () {
    group('Timestamp Handling Tests', timestamp_handling_test.main);
  });
}
