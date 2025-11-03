import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Hymns'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'French Adventist Hymns'**
  String get appSubtitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @hymnHistory.
  ///
  /// In en, this message translates to:
  /// **'Hymn History'**
  String get hymnHistory;

  /// No description provided for @discoverStory.
  ///
  /// In en, this message translates to:
  /// **'Discover the story behind this hymn'**
  String get discoverStory;

  /// No description provided for @hymnInformation.
  ///
  /// In en, this message translates to:
  /// **'Hymn Information'**
  String get hymnInformation;

  /// No description provided for @hymnStory.
  ///
  /// In en, this message translates to:
  /// **'Hymn Story'**
  String get hymnStory;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get number;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @composer.
  ///
  /// In en, this message translates to:
  /// **'Composer'**
  String get composer;

  /// No description provided for @style.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get style;

  /// No description provided for @midiFile.
  ///
  /// In en, this message translates to:
  /// **'MIDI File'**
  String get midiFile;

  /// No description provided for @lyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get lyrics;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @hymnNotFound.
  ///
  /// In en, this message translates to:
  /// **'Hymn not found'**
  String get hymnNotFound;

  /// No description provided for @errorLoadingHymn.
  ///
  /// In en, this message translates to:
  /// **'Error loading hymn'**
  String get errorLoadingHymn;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @hymns.
  ///
  /// In en, this message translates to:
  /// **'hymns'**
  String get hymns;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @searchHymns.
  ///
  /// In en, this message translates to:
  /// **'Search hymns...'**
  String get searchHymns;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @hymnsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} hymns found'**
  String hymnsFound(int count);

  /// No description provided for @noHymnsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No hymns available'**
  String get noHymnsAvailable;

  /// No description provided for @noHymnsFound.
  ///
  /// In en, this message translates to:
  /// **'No hymns found'**
  String get noHymnsFound;

  /// No description provided for @noHymnsAvailableAtMoment.
  ///
  /// In en, this message translates to:
  /// **'No hymns available at the moment'**
  String get noHymnsAvailableAtMoment;

  /// No description provided for @tryModifyingSearchCriteria.
  ///
  /// In en, this message translates to:
  /// **'Try modifying your search criteria'**
  String get tryModifyingSearchCriteria;

  /// No description provided for @advancedSearchToBe.
  ///
  /// In en, this message translates to:
  /// **'Advanced search - to be implemented'**
  String get advancedSearchToBe;

  /// No description provided for @favoritesToBe.
  ///
  /// In en, this message translates to:
  /// **'Favorites screen - to be implemented'**
  String get favoritesToBe;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @addFavoritesDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on your favorite hymns to add them to your favorites.'**
  String get addFavoritesDescription;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @continue_.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @welcomeToHymnes.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Hymnes'**
  String get welcomeToHymnes;

  /// No description provided for @discoverSacredMusic.
  ///
  /// In en, this message translates to:
  /// **'Discover Sacred Music'**
  String get discoverSacredMusic;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore a vast collection of Adventist hymns and songs of praise. Experience worship through beautiful melodies and inspiring lyrics.'**
  String get welcomeDescription;

  /// No description provided for @searchAndDiscover.
  ///
  /// In en, this message translates to:
  /// **'Search & Discover'**
  String get searchAndDiscover;

  /// No description provided for @findYourFavorites.
  ///
  /// In en, this message translates to:
  /// **'Find Your Favorites'**
  String get findYourFavorites;

  /// No description provided for @searchDescription.
  ///
  /// In en, this message translates to:
  /// **'Easily find your favorite hymns by title, author, or lyrics. Our powerful search helps you discover new songs for worship.'**
  String get searchDescription;

  /// No description provided for @midiPlayback.
  ///
  /// In en, this message translates to:
  /// **'MIDI Playback'**
  String get midiPlayback;

  /// No description provided for @highQualityAudio.
  ///
  /// In en, this message translates to:
  /// **'High-Quality Audio'**
  String get highQualityAudio;

  /// No description provided for @midiDescription.
  ///
  /// In en, this message translates to:
  /// **'Listen to hymns with crystal-clear MIDI playback. Choose different voice tracks and enjoy the full musical arrangement.'**
  String get midiDescription;

  /// No description provided for @favoritesAndHistory.
  ///
  /// In en, this message translates to:
  /// **'Favorites & History'**
  String get favoritesAndHistory;

  /// No description provided for @personalCollection.
  ///
  /// In en, this message translates to:
  /// **'Personal Collection'**
  String get personalCollection;

  /// No description provided for @favoritesDescription.
  ///
  /// In en, this message translates to:
  /// **'Save your favorite hymns and explore their rich history. Learn about the authors and the stories behind each song.'**
  String get favoritesDescription;

  /// No description provided for @hymnStoryTemplate.
  ///
  /// In en, this message translates to:
  /// **'This beloved hymn \"{title}\" was written by {author}{composer}. The {style} style makes it perfect for worship and personal devotion. Its timeless message continues to inspire believers worldwide.'**
  String hymnStoryTemplate(
      String title, String author, String composer, String style);

  /// No description provided for @unknownAuthor.
  ///
  /// In en, this message translates to:
  /// **'an unknown author'**
  String get unknownAuthor;

  /// No description provided for @withMusicComposedBy.
  ///
  /// In en, this message translates to:
  /// **' with music composed by {composer}'**
  String withMusicComposedBy(String composer);

  /// No description provided for @hymnNumber.
  ///
  /// In en, this message translates to:
  /// **'Hymn {number}'**
  String hymnNumber(String number);

  /// No description provided for @hymnTitleWithNumber.
  ///
  /// In en, this message translates to:
  /// **'{number}. {title}'**
  String hymnTitleWithNumber(String number, String title);

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon!!!'**
  String get comingSoon;

  /// No description provided for @allVoices.
  ///
  /// In en, this message translates to:
  /// **'All Voices'**
  String get allVoices;

  /// No description provided for @soprano.
  ///
  /// In en, this message translates to:
  /// **'Soprano'**
  String get soprano;

  /// No description provided for @alto.
  ///
  /// In en, this message translates to:
  /// **'Alto'**
  String get alto;

  /// No description provided for @tenor.
  ///
  /// In en, this message translates to:
  /// **'Tenor'**
  String get tenor;

  /// No description provided for @bass.
  ///
  /// In en, this message translates to:
  /// **'Bass'**
  String get bass;

  /// No description provided for @countertenor.
  ///
  /// In en, this message translates to:
  /// **'Countertenor'**
  String get countertenor;

  /// No description provided for @baritone.
  ///
  /// In en, this message translates to:
  /// **'Baritone'**
  String get baritone;

  /// No description provided for @musicSheet.
  ///
  /// In en, this message translates to:
  /// **'Music Sheet'**
  String get musicSheet;

  /// No description provided for @viewMusicSheet.
  ///
  /// In en, this message translates to:
  /// **'View music sheet (PDF)'**
  String get viewMusicSheet;

  /// No description provided for @viewMusicSheets.
  ///
  /// In en, this message translates to:
  /// **'View {count} music sheets (PDF)'**
  String viewMusicSheets(int count);

  /// No description provided for @checkingAvailability.
  ///
  /// In en, this message translates to:
  /// **'Checking availability...'**
  String get checkingAvailability;

  /// No description provided for @errorCheckingMusicSheets.
  ///
  /// In en, this message translates to:
  /// **'Error checking music sheets'**
  String get errorCheckingMusicSheets;

  /// No description provided for @noMusicSheetsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No music sheets available'**
  String get noMusicSheetsAvailable;

  /// No description provided for @loadingMusicSheet.
  ///
  /// In en, this message translates to:
  /// **'Loading music sheet...'**
  String get loadingMusicSheet;

  /// No description provided for @unableToDisplayPdf.
  ///
  /// In en, this message translates to:
  /// **'Unable to display PDF'**
  String get unableToDisplayPdf;

  /// No description provided for @webViewFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'WebView failed to load'**
  String get webViewFailedToLoad;

  /// No description provided for @pdfLoadingTimeout.
  ///
  /// In en, this message translates to:
  /// **'PDF loading timeout'**
  String get pdfLoadingTimeout;

  /// No description provided for @failedToLoadPdf.
  ///
  /// In en, this message translates to:
  /// **'Failed to load PDF. Tap to open in browser.'**
  String get failedToLoadPdf;

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in Browser'**
  String get openInBrowser;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cannotOpenPdfInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Cannot open PDF in browser'**
  String get cannotOpenPdfInBrowser;

  /// No description provided for @errorOpeningPdf.
  ///
  /// In en, this message translates to:
  /// **'Error opening PDF: {error}'**
  String errorOpeningPdf(String error);

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// No description provided for @signInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Email'**
  String get signInWithEmail;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @welcomeBackDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save your favorite hymns and access your personal collection.'**
  String get welcomeBackDescription;

  /// No description provided for @createAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Create an account to save your favorite hymns and access your personal collection.'**
  String get createAccountDescription;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @enterConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get enterConfirmPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is not valid.'**
  String get invalidEmail;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @signInSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully signed in'**
  String get signInSuccess;

  /// No description provided for @signUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get signUpSuccess;

  /// No description provided for @signOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully signed out'**
  String get signOutSuccess;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent to {email}'**
  String passwordResetSent(String email);

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get resetPasswordDescription;

  /// No description provided for @sendResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Email'**
  String get sendResetEmail;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account Created'**
  String get accountCreated;

  /// No description provided for @accountCreatedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your account has been created successfully. You can now save your favorite hymns.'**
  String get accountCreatedDescription;

  /// No description provided for @continueToApp.
  ///
  /// In en, this message translates to:
  /// **'Continue to App'**
  String get continueToApp;

  /// No description provided for @authenticationRequired.
  ///
  /// In en, this message translates to:
  /// **'Authentication Required'**
  String get authenticationRequired;

  /// No description provided for @authenticationRequiredDescription.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to save hymns to your favorites.'**
  String get authenticationRequiredDescription;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign In to Continue'**
  String get signInToContinue;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @subtheme.
  ///
  /// In en, this message translates to:
  /// **'Subtheme'**
  String get subtheme;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @clearAllFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear all filters'**
  String get clearAllFilters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All {label}'**
  String all(String label);

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred theme appearance'**
  String get selectTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @systemThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow system setting'**
  String get systemThemeDescription;

  /// No description provided for @lightThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Always use light theme'**
  String get lightThemeDescription;

  /// No description provided for @darkThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Always use dark theme'**
  String get darkThemeDescription;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signOutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// No description provided for @signInToSaveFavorites.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save your favorites'**
  String get signInToSaveFavorites;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unexpectedError;

  /// No description provided for @appleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign In failed. Please try again.'**
  String get appleSignInFailed;

  /// No description provided for @invalidAppleResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid response from Apple. Please try again.'**
  String get invalidAppleResponse;

  /// No description provided for @appleSignInNotHandled.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign In not handled. Please try again.'**
  String get appleSignInNotHandled;

  /// No description provided for @unknownAppleError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred during Apple Sign In.'**
  String get unknownAppleError;

  /// No description provided for @signOutError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while signing out. Please try again.'**
  String get signOutError;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found for that email address.'**
  String get userNotFound;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password provided for that user.'**
  String get wrongPassword;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'The account already exists for that email.'**
  String get emailAlreadyInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'The password provided is too weak.'**
  String get weakPassword;

  /// No description provided for @userDisabled.
  ///
  /// In en, this message translates to:
  /// **'This user account has been disabled.'**
  String get userDisabled;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get tooManyRequests;

  /// No description provided for @operationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Signing in with this method is not allowed.'**
  String get operationNotAllowed;

  /// No description provided for @invalidCredential.
  ///
  /// In en, this message translates to:
  /// **'The credential is invalid or has expired.'**
  String get invalidCredential;

  /// No description provided for @accountExistsWithDifferentCredential.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with the same email address but different sign-in credentials.'**
  String get accountExistsWithDifferentCredential;

  /// No description provided for @networkRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get networkRequestFailed;

  /// No description provided for @authenticationError.
  ///
  /// In en, this message translates to:
  /// **'An authentication error occurred.'**
  String get authenticationError;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get appInfo;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @buildNumber.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get buildNumber;

  /// No description provided for @customizeExperience.
  ///
  /// In en, this message translates to:
  /// **'Customize your experience'**
  String get customizeExperience;

  /// No description provided for @choosePreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get choosePreferredLanguage;

  /// No description provided for @manageUserAccount.
  ///
  /// In en, this message translates to:
  /// **'Manage your user account'**
  String get manageUserAccount;

  /// No description provided for @appInformation.
  ///
  /// In en, this message translates to:
  /// **'Application information'**
  String get appInformation;

  /// No description provided for @hymnSaved.
  ///
  /// In en, this message translates to:
  /// **'hymn saved'**
  String get hymnSaved;

  /// No description provided for @hymnsSaved.
  ///
  /// In en, this message translates to:
  /// **'hymns saved'**
  String get hymnsSaved;

  /// No description provided for @yourFavoriteHymns.
  ///
  /// In en, this message translates to:
  /// **'Your favorite hymns'**
  String get yourFavoriteHymns;

  /// No description provided for @oopsErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Oops! An error occurred'**
  String get oopsErrorOccurred;

  /// No description provided for @discoverHymns.
  ///
  /// In en, this message translates to:
  /// **'Discover hymns'**
  String get discoverHymns;

  /// No description provided for @searchAmongHymns.
  ///
  /// In en, this message translates to:
  /// **'Search among {count} hymns'**
  String searchAmongHymns(int count);

  /// No description provided for @customizeAppAppearance.
  ///
  /// In en, this message translates to:
  /// **'Customize the app appearance'**
  String get customizeAppAppearance;

  /// No description provided for @hymn.
  ///
  /// In en, this message translates to:
  /// **'hymn'**
  String get hymn;

  /// No description provided for @hymnNotFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'The requested hymn could not be found'**
  String get hymnNotFoundDescription;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @favoriteAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get favoriteAdded;

  /// No description provided for @favoriteRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get favoriteRemoved;

  /// No description provided for @templateStory.
  ///
  /// In en, this message translates to:
  /// **'Template Story'**
  String get templateStory;

  /// No description provided for @fullHymnStoryComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Full hymn story coming soon!'**
  String get fullHymnStoryComingSoon;

  /// No description provided for @tapForMoreInfo.
  ///
  /// In en, this message translates to:
  /// **'Tap for more information'**
  String get tapForMoreInfo;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortByNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get sortByNumber;

  /// No description provided for @sortByDateAdded.
  ///
  /// In en, this message translates to:
  /// **'Date added'**
  String get sortByDateAdded;

  /// No description provided for @sortByTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sortByTitle;

  /// No description provided for @sortByAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get sortByAuthor;

  /// No description provided for @sortOldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get sortOldestFirst;

  /// No description provided for @sortNewestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sortNewestFirst;

  /// No description provided for @sortAscending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get sortDescending;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @couldNotProcessRequest.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t process your request. Please try again later.'**
  String get couldNotProcessRequest;

  /// No description provided for @actionRequired.
  ///
  /// In en, this message translates to:
  /// **'Action required'**
  String get actionRequired;

  /// No description provided for @checkSettingsBeforeProceeding.
  ///
  /// In en, this message translates to:
  /// **'Please check your settings before proceeding to avoid potential issues.'**
  String get checkSettingsBeforeProceeding;

  /// No description provided for @actionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Action completed'**
  String get actionCompleted;

  /// No description provided for @changesSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your changes have been saved successfully.'**
  String get changesSavedSuccessfully;

  /// No description provided for @justSoYouKnow.
  ///
  /// In en, this message translates to:
  /// **'Just so you know'**
  String get justSoYouKnow;

  /// No description provided for @loggedInOverHour.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been logged in for over an hour. Don\'t forget to save your progress.'**
  String get loggedInOverHour;

  /// No description provided for @lyricsCopied.
  ///
  /// In en, this message translates to:
  /// **'Lyrics copied'**
  String get lyricsCopied;

  /// No description provided for @storyCopied.
  ///
  /// In en, this message translates to:
  /// **'Story copied'**
  String get storyCopied;

  /// No description provided for @loadingAudio.
  ///
  /// In en, this message translates to:
  /// **'Loading audio...'**
  String get loadingAudio;

  /// No description provided for @retrying.
  ///
  /// In en, this message translates to:
  /// **'Retrying... ({count}/3)'**
  String retrying(int count);

  /// No description provided for @unableToPlayAudio.
  ///
  /// In en, this message translates to:
  /// **'Unable to play audio'**
  String get unableToPlayAudio;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @manageNotificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Manage notification preferences'**
  String get manageNotificationPreferences;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotification;

  /// No description provided for @sendTestNotificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Send a test notification to verify functionality'**
  String get sendTestNotificationDescription;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get dailyReminder;

  /// No description provided for @scheduleDailyReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Schedule a daily reminder to explore hymns'**
  String get scheduleDailyReminderDescription;

  /// No description provided for @hymnOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Hymn of the Day'**
  String get hymnOfTheDay;

  /// No description provided for @getNotifiedAboutFeaturedHymns.
  ///
  /// In en, this message translates to:
  /// **'Get notified about featured hymns'**
  String get getNotifiedAboutFeaturedHymns;

  /// No description provided for @weeklySabbathReminder.
  ///
  /// In en, this message translates to:
  /// **'Weekly Sabbath Reminder'**
  String get weeklySabbathReminder;

  /// No description provided for @weeklySabbathReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Get reminded every Friday at 6:00 PM to prepare for the Sabbath and sing praises to the Lord'**
  String get weeklySabbathReminderDescription;

  /// No description provided for @sabbathReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Sabbath Preparation'**
  String get sabbathReminderTitle;

  /// No description provided for @sabbathReminderBody.
  ///
  /// In en, this message translates to:
  /// **'It is the Sabbath! Take time to prepare your heart and sing praises to the Lord. Blessed Sabbath!'**
  String get sabbathReminderBody;

  /// No description provided for @checkEmailInstructions.
  ///
  /// In en, this message translates to:
  /// **'Please check your email and follow the instructions to reset your password.'**
  String get checkEmailInstructions;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
