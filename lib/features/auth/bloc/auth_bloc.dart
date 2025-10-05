import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;

  const SignUpRequested({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.phoneNumber,
  });

  @override
  List<Object?> get props =>
      [email, password, firstName, lastName, phoneNumber];
}

class GoogleSignInRequested extends AuthEvent {}

class AppleSignInRequested extends AuthEvent {}

class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested(this.email);

  @override
  List<Object> get props => [email];
}

class SignOutRequested extends AuthEvent {}

class DeleteAccountRequested extends AuthEvent {}

class UpdateProfileRequested extends AuthEvent {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? photoURL;

  const UpdateProfileRequested({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.photoURL,
  });

  @override
  List<Object?> get props => [firstName, lastName, phoneNumber, photoURL];
}

class SendEmailVerificationRequested extends AuthEvent {}

class LinkPhoneNumberRequested extends AuthEvent {
  final String phoneNumber;

  const LinkPhoneNumberRequested(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class ReloadUserRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated(this.user);

  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class PasswordResetSent extends AuthState {
  final String email;

  const PasswordResetSent(this.email);

  @override
  List<Object> get props => [email];
}

class ProfileUpdated extends AuthState {
  final UserModel user;

  const ProfileUpdated(this.user);

  @override
  List<Object> get props => [user];
}

class EmailVerificationSent extends AuthState {}

class PhoneNumberLinked extends AuthState {
  final String phoneNumber;

  const PhoneNumberLinked(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class UserReloaded extends AuthState {
  final UserModel user;

  const UserReloaded(this.user);

  @override
  List<Object> get props => [user];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<AppleSignInRequested>(_onAppleSignInRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<SendEmailVerificationRequested>(_onSendEmailVerificationRequested);
    on<LinkPhoneNumberRequested>(_onLinkPhoneNumberRequested);
    on<ReloadUserRequested>(_onReloadUserRequested);

    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        add(AuthCheckRequested());
      } else {
        // Don't emit directly here, let the bloc handle it
        add(AuthCheckRequested());
      }
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        emit(Authenticated(UserModel.fromFirebaseUser(user)));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError('Failed to check authentication status'));
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = await _authService.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (credential?.user != null) {
        emit(Authenticated(UserModel.fromFirebaseUser(credential!.user!)));
      } else {
        emit(const AuthError('Sign in failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = await _authService.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        phoneNumber: event.phoneNumber,
      );

      if (credential?.user != null) {
        emit(Authenticated(UserModel.fromFirebaseUser(credential!.user!)));
      } else {
        emit(const AuthError('Sign up failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = await _authService.signInWithGoogle();

      if (credential?.user != null) {
        emit(Authenticated(UserModel.fromFirebaseUser(credential!.user!)));
      } else {
        emit(Unauthenticated()); // User cancelled
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAppleSignInRequested(
    AppleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = await _authService.signInWithApple();

      if (credential?.user != null) {
        emit(Authenticated(UserModel.fromFirebaseUser(credential!.user!)));
      } else {
        emit(Unauthenticated()); // User cancelled
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.sendPasswordResetEmail(event.email);
      emit(PasswordResetSent(event.email));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onDeleteAccountRequested(
    DeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.deleteAccount();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.updateUserProfile(
        firstName: event.firstName,
        lastName: event.lastName,
        phoneNumber: event.phoneNumber,
        photoURL: event.photoURL,
      );

      // Reload user data to get updated information
      await _authService.reloadUser();
      final user = _authService.currentUser;
      if (user != null) {
        emit(ProfileUpdated(UserModel.fromFirebaseUser(user)));
      } else {
        emit(const AuthError('Failed to update profile'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSendEmailVerificationRequested(
    SendEmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.sendEmailVerification();
      emit(EmailVerificationSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLinkPhoneNumberRequested(
    LinkPhoneNumberRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.linkPhoneNumber(event.phoneNumber);
      emit(PhoneNumberLinked(event.phoneNumber));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onReloadUserRequested(
    ReloadUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.reloadUser();
      final user = _authService.currentUser;
      if (user != null) {
        emit(UserReloaded(UserModel.fromFirebaseUser(user)));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
