import 'package:flutter_test/flutter_test.dart';
import 'package:hymnes_sda_fr/core/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    late UserModel user;

    setUp(() {
      user = UserModel(
        uid: 'test-uid-123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
        isEmailVerified: true,
        createdAt: DateTime(2023, 1, 1),
        lastSignInAt: DateTime(2023, 12, 1),
      );
    });

    test('should create user with all properties', () {
      expect(user.uid, 'test-uid-123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.photoURL, 'https://example.com/photo.jpg');
      expect(user.isEmailVerified, true);
      expect(user.createdAt, DateTime(2023, 1, 1));
      expect(user.lastSignInAt, DateTime(2023, 12, 1));
    });

    test('should convert user to Map', () {
      final json = user.toMap();

      expect(json['uid'], 'test-uid-123');
      expect(json['email'], 'test@example.com');
      expect(json['displayName'], 'Test User');
      expect(json['photoURL'], 'https://example.com/photo.jpg');
      expect(json['isEmailVerified'], true);
      expect(json['createdAt'], DateTime(2023, 1, 1).millisecondsSinceEpoch);
      expect(
          json['lastSignInAt'], DateTime(2023, 12, 1).millisecondsSinceEpoch);
    });

    test('should create user from Map', () {
      final json = {
        'uid': 'another-uid-456',
        'email': 'another@example.com',
        'displayName': 'Another User',
        'photoURL': 'https://example.com/another-photo.jpg',
        'isEmailVerified': false,
        'createdAt': DateTime(2023, 2, 1).millisecondsSinceEpoch,
        'lastSignInAt': DateTime(2023, 11, 1).millisecondsSinceEpoch,
      };

      final createdUser = UserModel.fromMap(json);

      expect(createdUser.uid, 'another-uid-456');
      expect(createdUser.email, 'another@example.com');
      expect(createdUser.displayName, 'Another User');
      expect(createdUser.photoURL, 'https://example.com/another-photo.jpg');
      expect(createdUser.isEmailVerified, false);
      expect(createdUser.createdAt, DateTime(2023, 2, 1));
      expect(createdUser.lastSignInAt, DateTime(2023, 11, 1));
    });

    test('should handle null optional properties', () {
      final userWithNulls = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: null,
        photoURL: null,
        isEmailVerified: false,
        createdAt: DateTime.now(),
        lastSignInAt: null,
      );

      expect(userWithNulls.displayName, isNull);
      expect(userWithNulls.photoURL, isNull);
      expect(userWithNulls.lastSignInAt, isNull);
    });

    test('should be equal when properties are the same', () {
      final user1 = UserModel(
        uid: 'test-uid-123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
        isEmailVerified: true,
        createdAt: DateTime(2023, 1, 1),
        lastSignInAt: DateTime(2023, 12, 1),
      );

      final user2 = UserModel(
        uid: 'test-uid-123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
        isEmailVerified: true,
        createdAt: DateTime(2023, 1, 1),
        lastSignInAt: DateTime(2023, 12, 1),
      );

      expect(user1, equals(user2));
    });

    test('should copy with new values', () {
      final updatedUser = user.copyWith(
        displayName: 'Updated Name',
        isEmailVerified: false,
      );

      expect(updatedUser.uid, user.uid);
      expect(updatedUser.email, user.email);
      expect(updatedUser.displayName, 'Updated Name');
      expect(updatedUser.isEmailVerified, false);
      expect(updatedUser.photoURL, user.photoURL);
      expect(updatedUser.createdAt, user.createdAt);
      expect(updatedUser.lastSignInAt, user.lastSignInAt);
    });
  });
}
