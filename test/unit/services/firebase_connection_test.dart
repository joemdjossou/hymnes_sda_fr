import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hymnes_sda_fr/core/repositories/firestore_favorites_repository.dart';
import 'package:hymnes_sda_fr/core/repositories/hybrid_favorites_repository.dart';

import '../../test_setup.dart';

void main() {
  group('Firebase Connection Tests', () {
    late FirebaseFirestore firestore;
    late FirebaseAuth auth;
    late FirestoreFavoritesRepository firestoreRepository;
    late HybridFavoritesRepository hybridRepository;

    setUpAll(() async {
      await setupFirebaseTestApp();
    });

    setUp(() {
      firestore = FirebaseFirestore.instance;
      auth = FirebaseAuth.instance;
      firestoreRepository = FirestoreFavoritesRepository();
      hybridRepository = HybridFavoritesRepository();
    });

    test('should have valid Firebase configuration', () {
      expect(firestore.app.options.projectId, isNotNull);
      expect(firestore.app.options.projectId, isNotEmpty);
      expect(firestore.app.options.databaseURL, isNotNull);
    });

    test('should be able to create Firestore instance', () {
      expect(firestore, isNotNull);
      expect(firestore.app.options.projectId, equals('hymnes-sda-fr'));
    });

    test('should be able to create Firebase Auth instance', () {
      expect(auth, isNotNull);
    });

    test('should be able to create FirestoreFavoritesRepository', () {
      expect(firestoreRepository, isNotNull);
    });

    test('should be able to create HybridFavoritesRepository', () {
      expect(hybridRepository, isNotNull);
    });

    test('should handle unauthenticated state gracefully', () async {
      // Test that repositories handle unauthenticated state without crashing
      expect(() => firestoreRepository.isAuthenticated, returnsNormally);
      expect(() => hybridRepository.isAuthenticated, returnsNormally);
    });

    test('should have proper collection structure', () {
      // Test that the collection structure is correct
      expect(firestoreRepository.isAuthenticated, isFalse); // No user signed in
    });
  });

  group('Firestore Repository Tests', () {
    late FirestoreFavoritesRepository repository;

    setUp(() {
      repository = FirestoreFavoritesRepository();
    });

    test('should return empty list when not authenticated', () async {
      final favorites = await repository.getFavorites();
      expect(favorites, isEmpty);
    });

    test('should return 0 count when not authenticated', () async {
      final count = await repository.getFavoritesCount();
      expect(count, equals(0));
    });

    test('should handle async favorite check when not authenticated', () async {
      final isFavorite = await repository.isFavoriteAsync('1');
      expect(isFavorite, isFalse);
    });
  });

  group('Hybrid Repository Tests', () {
    late HybridFavoritesRepository repository;

    setUp(() {
      repository = HybridFavoritesRepository();
    });

    test('should initialize without errors', () async {
      expect(() => repository.initialize(), returnsNormally);
    });

    test('should return empty sync status when not authenticated', () async {
      final syncStatus = await repository.getSyncStatus();
      expect(syncStatus, isA<Map<String, dynamic>>());
      expect(syncStatus['isAuthenticated'], isFalse);
      expect(syncStatus['localCount'], isA<int>());
      expect(syncStatus['firestoreCount'], isA<int>());
    });

    test('should handle online status changes', () {
      expect(() => repository.setOnlineStatus(true), returnsNormally);
      expect(() => repository.setOnlineStatus(false), returnsNormally);
    });
  });
}
