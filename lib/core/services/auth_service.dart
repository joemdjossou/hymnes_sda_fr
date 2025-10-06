import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'error_logging_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Error logging service
  final ErrorLoggingService _errorLogger = ErrorLoggingService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _errorLogger.logInfo(
        'AuthService',
        'User signed in successfully with email',
        context: {
          'email': email,
          'userId': credential.user?.uid,
        },
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      await _errorLogger.logAuthError(
        'AuthService',
        'email_password',
        'Email/password sign in failed',
        error: e,
        stackTrace: StackTrace.current,
        authContext: {
          'email': email,
          'errorCode': e.code,
          'errorMessage': e.message,
        },
      );
      throw _handleAuthException(e);
    } catch (e) {
      await _errorLogger.logAuthError(
        'AuthService',
        'email_password',
        'Unexpected error during email/password sign in',
        error: e,
        stackTrace: StackTrace.current,
        authContext: {
          'email': email,
        },
      );
      throw 'UNEXPECTED_ERROR';
    }
  }

  // Create account with email and password
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile with additional information
      if (credential.user != null) {
        await _updateUserProfile(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      await _errorLogger.logAuthError(
        'AuthService',
        'email_password',
        'Email/password sign up failed',
        error: e,
        stackTrace: StackTrace.current,
        authContext: {
          'email': email,
          'errorCode': e.code,
          'errorMessage': e.message,
        },
      );
      throw _handleAuthException(e);
    } catch (e) {
      await _errorLogger.logAuthError(
        'AuthService',
        'email_password',
        'Unexpected error during email/password sign up',
        error: e,
        stackTrace: StackTrace.current,
        authContext: {
          'email': email,
        },
      );
      throw 'UNEXPECTED_ERROR';
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User cancelled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      await _errorLogger.logAuthError(
        'AuthService',
        'google_sign_in',
        'Google sign in failed',
        error: e,
        stackTrace: StackTrace.current,
        authContext: {
          'errorCode': e.code,
          'errorMessage': e.message,
        },
      );
      throw _handleAuthException(e);
    } catch (e) {
      await _errorLogger.logAuthError(
        'AuthService',
        'google_sign_in',
        'Unexpected error during Google sign in',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw 'UNEXPECTED_ERROR';
    }
  }

  // Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential from Apple ID credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      return await _auth.signInWithCredential(oauthCredential);
    } on SignInWithAppleAuthorizationException catch (e) {
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          return null; // User cancelled the sign-in
        case AuthorizationErrorCode.failed:
          throw 'APPLE_SIGN_IN_FAILED';
        case AuthorizationErrorCode.invalidResponse:
          throw 'INVALID_APPLE_RESPONSE';
        case AuthorizationErrorCode.notHandled:
          throw 'APPLE_SIGN_IN_NOT_HANDLED';
        case AuthorizationErrorCode.unknown:
          throw 'UNKNOWN_APPLE_ERROR';
        default:
          throw 'APPLE_SIGN_IN_FAILED';
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'UNEXPECTED_ERROR';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'UNEXPECTED_ERROR';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw 'SIGN_OUT_ERROR';
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'UNEXPECTED_ERROR';
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? photoURL,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw 'USER_NOT_LOGGED_IN';
      }

      await _updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        photoURL: photoURL,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'UNEXPECTED_ERROR';
    }
  }

  // Link phone number to current user
  Future<void> linkPhoneNumber(String phoneNumber) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw 'USER_NOT_LOGGED_IN';
      }

      // Note: Phone authentication requires additional setup
      // This is a placeholder for phone number linking
      // Phone number linking requires PhoneAuthCredential which needs SMS verification
      // For now, we'll just store the phone number in user metadata
      // await user.updatePhoneNumber(phoneAuthCredential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'UNEXPECTED_ERROR';
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw 'USER_NOT_LOGGED_IN';
      }

      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'UNEXPECTED_ERROR';
    }
  }

  // Reload user data
  Future<void> reloadUser() async {
    try {
      final user = currentUser;
      if (user != null) {
        await user.reload();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'UNEXPECTED_ERROR';
    }
  }

  // Private helper method to update user profile
  Future<void> _updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? photoURL,
  }) async {
    final user = currentUser;
    if (user == null) return;

    // Build display name from first and last name
    String? displayName;
    if (firstName != null && lastName != null) {
      displayName = '$firstName $lastName';
    } else if (firstName != null) {
      displayName = firstName;
    }

    // Update user profile
    await user.updateDisplayName(displayName);
    if (photoURL != null) {
      await user.updatePhotoURL(photoURL);
    }

    // Reload user to get updated data
    await user.reload();
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'USER_NOT_FOUND';
      case 'wrong-password':
        return 'WRONG_PASSWORD';
      case 'email-already-in-use':
        return 'EMAIL_ALREADY_IN_USE';
      case 'weak-password':
        return 'WEAK_PASSWORD';
      case 'invalid-email':
        return 'INVALID_EMAIL';
      case 'user-disabled':
        return 'USER_DISABLED';
      case 'too-many-requests':
        return 'TOO_MANY_REQUESTS';
      case 'operation-not-allowed':
        return 'OPERATION_NOT_ALLOWED';
      case 'invalid-credential':
        return 'INVALID_CREDENTIAL';
      case 'account-exists-with-different-credential':
        return 'ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL';
      case 'network-request-failed':
        return 'NETWORK_REQUEST_FAILED';
      default:
        return e.message ?? 'AUTHENTICATION_ERROR';
    }
  }
}
