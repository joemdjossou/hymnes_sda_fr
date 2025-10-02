import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorHandler {
  static String getLocalizedErrorMessage(
      String errorCode, AppLocalizations l10n) {
    switch (errorCode) {
      case 'UNEXPECTED_ERROR':
        return l10n.unexpectedError;
      case 'APPLE_SIGN_IN_FAILED':
        return l10n.appleSignInFailed;
      case 'INVALID_APPLE_RESPONSE':
        return l10n.invalidAppleResponse;
      case 'APPLE_SIGN_IN_NOT_HANDLED':
        return l10n.appleSignInNotHandled;
      case 'UNKNOWN_APPLE_ERROR':
        return l10n.unknownAppleError;
      case 'SIGN_OUT_ERROR':
        return l10n.signOutError;
      case 'USER_NOT_FOUND':
        return l10n.userNotFound;
      case 'WRONG_PASSWORD':
        return l10n.wrongPassword;
      case 'EMAIL_ALREADY_IN_USE':
        return l10n.emailAlreadyInUse;
      case 'WEAK_PASSWORD':
        return l10n.weakPassword;
      case 'INVALID_EMAIL':
        return l10n.invalidEmail;
      case 'USER_DISABLED':
        return l10n.userDisabled;
      case 'TOO_MANY_REQUESTS':
        return l10n.tooManyRequests;
      case 'OPERATION_NOT_ALLOWED':
        return l10n.operationNotAllowed;
      case 'INVALID_CREDENTIAL':
        return l10n.invalidCredential;
      case 'ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL':
        return l10n.accountExistsWithDifferentCredential;
      case 'NETWORK_REQUEST_FAILED':
        return l10n.networkRequestFailed;
      case 'AUTHENTICATION_ERROR':
        return l10n.authenticationError;
      default:
        return l10n.unexpectedError;
    }
  }
}
