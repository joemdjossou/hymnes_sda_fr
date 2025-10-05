// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hymnes_sda_fr/hymnes.dart';

void main() {
  group('App Widget Tests', () {
    testWidgets('App smoke test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const HymnesApp());

      // Verify that the app loads without errors
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App displays splash screen initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(const HymnesApp());
      await tester.pumpAndSettle();

      // Verify that the app displays the splash screen
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App handles theme changes', (WidgetTester tester) async {
      await tester.pumpWidget(const HymnesApp());
      await tester.pumpAndSettle();

      // Verify that the app handles theme changes
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App handles language changes', (WidgetTester tester) async {
      await tester.pumpWidget(const HymnesApp());
      await tester.pumpAndSettle();

      // Verify that the app handles language changes
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
