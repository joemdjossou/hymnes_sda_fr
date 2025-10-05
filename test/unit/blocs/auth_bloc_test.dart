import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hymnes_sda_fr/core/services/auth_service.dart';
import 'package:hymnes_sda_fr/features/auth/bloc/auth_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([AuthService, User, UserCredential])
void main() {
  group('AuthBloc Tests', () {
    late AuthBloc authBloc;
    late MockAuthService mockAuthService;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    setUp(() {
      mockAuthService = MockAuthService();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      authBloc = AuthBloc(authService: mockAuthService);
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state should be AuthInitial', () {
      expect(authBloc.state, equals(AuthInitial()));
    });

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when user is authenticated',
        build: () {
          when(mockAuthService.currentUser).thenReturn(mockUser);
          when(mockUser.uid).thenReturn('test-uid');
          when(mockUser.email).thenReturn('test@example.com');
          when(mockUser.displayName).thenReturn('Test User');
          when(mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
          when(mockUser.emailVerified).thenReturn(true);
          when(mockUser.metadata).thenReturn(UserMetadata(
            DateTime(2023, 1, 1).millisecondsSinceEpoch,
            DateTime(2023, 12, 1).millisecondsSinceEpoch,
          ));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<Authenticated>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when user is not authenticated',
        build: () {
          when(mockAuthService.currentUser).thenReturn(null);
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<Unauthenticated>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when auth check fails',
        build: () {
          when(mockAuthService.currentUser).thenThrow(Exception('Auth error'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });

    group('SignInRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] when sign in succeeds',
        build: () {
          when(mockAuthService.signInWithEmailAndPassword(
                  email: 'test@example.com', password: 'password'))
              .thenAnswer((_) async => mockUserCredential);
          when(mockUser.uid).thenReturn('test-uid');
          when(mockUser.email).thenReturn('test@example.com');
          when(mockUser.displayName).thenReturn('Test User');
          when(mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
          when(mockUser.emailVerified).thenReturn(true);
          when(mockUser.metadata).thenReturn(UserMetadata(
            DateTime(2023, 1, 1).millisecondsSinceEpoch,
            DateTime(2023, 12, 1).millisecondsSinceEpoch,
          ));
          return authBloc;
        },
        act: (bloc) => bloc.add(SignInRequested(
          email: 'test@example.com',
          password: 'password',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<Authenticated>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign in fails',
        build: () {
          when(mockAuthService.signInWithEmailAndPassword(
                  email: 'test@example.com', password: 'password'))
              .thenThrow(FirebaseAuthException(code: 'user-not-found'));
          return authBloc;
        },
        act: (bloc) => bloc.add(SignInRequested(
          email: 'test@example.com',
          password: 'password',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });

    group('SignUpRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when sign up succeeds',
        build: () {
          when(mockAuthService.createUserWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password',
            firstName: 'John',
            lastName: 'Doe',
            phoneNumber: '+1234567890',
          )).thenAnswer((_) async => mockUserCredential);
          when(mockUser.uid).thenReturn('test-uid');
          when(mockUser.email).thenReturn('test@example.com');
          when(mockUser.displayName).thenReturn('John Doe');
          when(mockUser.photoURL).thenReturn(null);
          when(mockUser.emailVerified).thenReturn(false);
          when(mockUser.metadata).thenReturn(UserMetadata(
            DateTime(2023, 1, 1).millisecond,
            DateTime(2023, 1, 1).millisecond,
          ));
          return authBloc;
        },
        act: (bloc) => bloc.add(SignUpRequested(
          email: 'test@example.com',
          password: 'password',
          firstName: 'John',
          lastName: 'Doe',
          phoneNumber: '+1234567890',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<Authenticated>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign up fails',
        build: () {
          when(mockAuthService.createUserWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password',
            firstName: 'John',
            lastName: 'Doe',
            phoneNumber: '+1234567890',
          )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
          return authBloc;
        },
        act: (bloc) => bloc.add(SignUpRequested(
          email: 'test@example.com',
          password: 'password',
          firstName: 'John',
          lastName: 'Doe',
          phoneNumber: '+1234567890',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });

    group('SignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when sign out succeeds',
        build: () {
          when(mockAuthService.signOut()).thenAnswer((_) async {});
          return authBloc;
        },
        act: (bloc) => bloc.add(SignOutRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<Unauthenticated>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign out fails',
        build: () {
          when(mockAuthService.signOut())
              .thenThrow(Exception('Sign out error'));
          return authBloc;
        },
        act: (bloc) => bloc.add(SignOutRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });

    group('PasswordResetRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthPasswordResetSent] when password reset succeeds',
        build: () {
          when(mockAuthService.sendPasswordResetEmail('test@example.com'))
              .thenAnswer((_) async {});
          return authBloc;
        },
        act: (bloc) => bloc.add(PasswordResetRequested('test@example.com')),
        expect: () => [
          isA<AuthLoading>(),
          isA<PasswordResetSent>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when password reset fails',
        build: () {
          when(mockAuthService.sendPasswordResetEmail('test@example.com'))
              .thenThrow(FirebaseAuthException(code: 'user-not-found'));
          return authBloc;
        },
        act: (bloc) => bloc.add(PasswordResetRequested('test@example.com')),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });
  });
}
