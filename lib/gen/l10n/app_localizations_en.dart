// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Hymns';

  @override
  String get appSubtitle => 'French Adventist Hymns';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get hymnHistory => 'Hymn History';

  @override
  String get discoverStory => 'Discover the story behind this hymn';

  @override
  String get hymnInformation => 'Hymn Information';

  @override
  String get hymnStory => 'Hymn Story';

  @override
  String get number => 'Number';

  @override
  String get title => 'Title';

  @override
  String get author => 'Author';

  @override
  String get composer => 'Composer';

  @override
  String get style => 'Style';

  @override
  String get midiFile => 'MIDI File';

  @override
  String get lyrics => 'Lyrics';

  @override
  String get loading => 'Loading...';

  @override
  String get hymnNotFound => 'Hymn not found';

  @override
  String get errorLoadingHymn => 'Error loading hymn';

  @override
  String get close => 'Close';

  @override
  String get unknown => 'Unknown';

  @override
  String get home => 'Home';

  @override
  String get welcome => 'Welcome';

  @override
  String get hymns => 'hymns';

  @override
  String get search => 'Search';

  @override
  String get favorites => 'Favorites';

  @override
  String get searchHymns => 'Search hymns...';

  @override
  String get clear => 'Clear';

  @override
  String hymnsFound(int count) {
    return '$count hymns found';
  }

  @override
  String get noHymnsAvailable => 'No hymns available';

  @override
  String get noHymnsFound => 'No hymns found';

  @override
  String get noHymnsAvailableAtMoment => 'No hymns available at the moment';

  @override
  String get tryModifyingSearchCriteria => 'Try modifying your search criteria';

  @override
  String get advancedSearchToBe => 'Advanced search - to be implemented';

  @override
  String get favoritesToBe => 'Favorites screen - to be implemented';

  @override
  String get noFavoritesYet => 'No favorites yet';

  @override
  String get addFavoritesDescription => 'Tap the heart icon on your favorite hymns to add them to your favorites.';

  @override
  String get skip => 'Skip';

  @override
  String get continue_ => 'Continue';

  @override
  String get getStarted => 'Get Started';

  @override
  String get welcomeToHymnes => 'Welcome to Hymnes';

  @override
  String get discoverSacredMusic => 'Discover Sacred Music';

  @override
  String get welcomeDescription => 'Explore a vast collection of Adventist hymns and songs of praise. Experience worship through beautiful melodies and inspiring lyrics.';

  @override
  String get searchAndDiscover => 'Search & Discover';

  @override
  String get findYourFavorites => 'Find Your Favorites';

  @override
  String get searchDescription => 'Easily find your favorite hymns by title, author, or lyrics. Our powerful search helps you discover new songs for worship.';

  @override
  String get midiPlayback => 'MIDI Playback';

  @override
  String get highQualityAudio => 'High-Quality Audio';

  @override
  String get midiDescription => 'Listen to hymns with crystal-clear MIDI playback. Choose different voice tracks and enjoy the full musical arrangement.';

  @override
  String get favoritesAndHistory => 'Favorites & History';

  @override
  String get personalCollection => 'Personal Collection';

  @override
  String get favoritesDescription => 'Save your favorite hymns and explore their rich history. Learn about the authors and the stories behind each song.';

  @override
  String hymnStoryTemplate(String title, String author, String composer, String style) {
    return 'This beloved hymn \"$title\" was written by $author$composer. The $style style makes it perfect for worship and personal devotion. Its timeless message continues to inspire believers worldwide.';
  }

  @override
  String get unknownAuthor => 'an unknown author';

  @override
  String withMusicComposedBy(String composer) {
    return ' with music composed by $composer';
  }

  @override
  String hymnNumber(String number) {
    return 'Hymn $number';
  }

  @override
  String hymnTitleWithNumber(String number, String title) {
    return '$number. $title';
  }

  @override
  String get comingSoon => 'Coming Soon!!!';

  @override
  String get allVoices => 'All Voices';

  @override
  String get soprano => 'Soprano';

  @override
  String get alto => 'Alto';

  @override
  String get tenor => 'Tenor';

  @override
  String get bass => 'Bass';

  @override
  String get countertenor => 'Countertenor';

  @override
  String get baritone => 'Baritone';

  @override
  String get musicSheet => 'Music Sheet';

  @override
  String get viewMusicSheet => 'View music sheet (PDF)';

  @override
  String viewMusicSheets(int count) {
    return 'View $count music sheets (PDF)';
  }

  @override
  String get checkingAvailability => 'Checking availability...';

  @override
  String get errorCheckingMusicSheets => 'Error checking music sheets';

  @override
  String get noMusicSheetsAvailable => 'No music sheets available';

  @override
  String get loadingMusicSheet => 'Loading music sheet...';

  @override
  String get unableToDisplayPdf => 'Unable to display PDF';

  @override
  String get webViewFailedToLoad => 'WebView failed to load';

  @override
  String get pdfLoadingTimeout => 'PDF loading timeout';

  @override
  String get failedToLoadPdf => 'Failed to load PDF. Tap to open in browser.';

  @override
  String get openInBrowser => 'Open in Browser';

  @override
  String get retry => 'Retry';

  @override
  String get cannotOpenPdfInBrowser => 'Cannot open PDF in browser';

  @override
  String errorOpeningPdf(String error) {
    return 'Error opening PDF: $error';
  }

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get signInWithEmail => 'Sign in with Email';

  @override
  String get createAccount => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get welcomeBackDescription => 'Sign in to save your favorite hymns and access your personal collection.';

  @override
  String get createAccountDescription => 'Create an account to save your favorite hymns and access your personal collection.';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get enterConfirmPassword => 'Confirm your password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get invalidEmail => 'The email address is not valid.';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get signInSuccess => 'Successfully signed in';

  @override
  String get signUpSuccess => 'Account created successfully';

  @override
  String get signOutSuccess => 'Successfully signed out';

  @override
  String passwordResetSent(String email) {
    return 'Password reset email sent to $email';
  }

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordDescription => 'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get sendResetEmail => 'Send Reset Email';

  @override
  String get backToSignIn => 'Back to Sign In';

  @override
  String get accountCreated => 'Account Created';

  @override
  String get accountCreatedDescription => 'Your account has been created successfully. You can now save your favorite hymns.';

  @override
  String get continueToApp => 'Continue to App';

  @override
  String get authenticationRequired => 'Authentication Required';

  @override
  String get authenticationRequiredDescription => 'Please sign in to save hymns to your favorites.';

  @override
  String get signInToContinue => 'Sign In to Continue';

  @override
  String get cancel => 'Cancel';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get theme => 'Theme';

  @override
  String get subtheme => 'Subtheme';

  @override
  String get filters => 'Filters';

  @override
  String get clearAllFilters => 'Clear all filters';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String all(String label) {
    return 'All $label';
  }

  @override
  String get selectTheme => 'Choose your preferred theme appearance';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemThemeDescription => 'Follow system setting';

  @override
  String get lightThemeDescription => 'Always use light theme';

  @override
  String get darkThemeDescription => 'Always use dark theme';

  @override
  String get account => 'Account';

  @override
  String get signOutConfirmation => 'Are you sure you want to sign out?';

  @override
  String get or => 'OR';

  @override
  String get unknownUser => 'Unknown User';

  @override
  String get signInToSaveFavorites => 'Sign in to save your favorites';

  @override
  String get unexpectedError => 'An unexpected error occurred. Please try again.';

  @override
  String get appleSignInFailed => 'Apple Sign In failed. Please try again.';

  @override
  String get invalidAppleResponse => 'Invalid response from Apple. Please try again.';

  @override
  String get appleSignInNotHandled => 'Apple Sign In not handled. Please try again.';

  @override
  String get unknownAppleError => 'Unknown error occurred during Apple Sign In.';

  @override
  String get signOutError => 'An error occurred while signing out. Please try again.';

  @override
  String get userNotFound => 'No user found for that email address.';

  @override
  String get wrongPassword => 'Wrong password provided for that user.';

  @override
  String get emailAlreadyInUse => 'The account already exists for that email.';

  @override
  String get weakPassword => 'The password provided is too weak.';

  @override
  String get userDisabled => 'This user account has been disabled.';

  @override
  String get tooManyRequests => 'Too many attempts. Please try again later.';

  @override
  String get operationNotAllowed => 'Signing in with this method is not allowed.';

  @override
  String get invalidCredential => 'The credential is invalid or has expired.';

  @override
  String get accountExistsWithDifferentCredential => 'An account already exists with the same email address but different sign-in credentials.';

  @override
  String get networkRequestFailed => 'Network error. Please check your internet connection.';

  @override
  String get authenticationError => 'An authentication error occurred.';

  @override
  String get appInfo => 'App Info';

  @override
  String get version => 'Version';

  @override
  String get buildNumber => 'Build';

  @override
  String get customizeExperience => 'Customize your experience';

  @override
  String get choosePreferredLanguage => 'Choose your preferred language';

  @override
  String get manageUserAccount => 'Manage your user account';

  @override
  String get appInformation => 'Application information';

  @override
  String get hymnSaved => 'hymn saved';

  @override
  String get hymnsSaved => 'hymns saved';

  @override
  String get yourFavoriteHymns => 'Your favorite hymns';

  @override
  String get oopsErrorOccurred => 'Oops! An error occurred';

  @override
  String get discoverHymns => 'Discover hymns';

  @override
  String searchAmongHymns(int count) {
    return 'Search among $count hymns';
  }

  @override
  String get customizeAppAppearance => 'Customize the app appearance';

  @override
  String get hymn => 'hymn';

  @override
  String get hymnNotFoundDescription => 'The requested hymn could not be found';

  @override
  String get back => 'Back';

  @override
  String get favorite => 'Favorite';

  @override
  String get favoriteAdded => 'Added to favorites';

  @override
  String get favoriteRemoved => 'Removed from favorites';

  @override
  String get templateStory => 'Template Story';

  @override
  String get fullHymnStoryComingSoon => 'Full hymn story coming soon!';

  @override
  String get tapForMoreInfo => 'Tap for more information';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortByNumber => 'Number';

  @override
  String get sortByDateAdded => 'Date added';

  @override
  String get sortByTitle => 'Title';

  @override
  String get sortByAuthor => 'Author';

  @override
  String get sortOldestFirst => 'Oldest first';

  @override
  String get sortNewestFirst => 'Newest first';

  @override
  String get sortAscending => 'Ascending';

  @override
  String get sortDescending => 'Descending';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get couldNotProcessRequest => 'We couldn\'t process your request. Please try again later.';

  @override
  String get actionRequired => 'Action required';

  @override
  String get checkSettingsBeforeProceeding => 'Please check your settings before proceeding to avoid potential issues.';

  @override
  String get actionCompleted => 'Action completed';

  @override
  String get changesSavedSuccessfully => 'Your changes have been saved successfully.';

  @override
  String get justSoYouKnow => 'Just so you know';

  @override
  String get loggedInOverHour => 'You\'ve been logged in for over an hour. Don\'t forget to save your progress.';

  @override
  String get lyricsCopied => 'Lyrics copied';

  @override
  String get storyCopied => 'Story copied';

  @override
  String get loadingAudio => 'Loading audio...';

  @override
  String retrying(int count) {
    return 'Retrying... ($count/3)';
  }

  @override
  String get unableToPlayAudio => 'Unable to play audio';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageNotificationPreferences => 'Manage notification preferences';

  @override
  String get testNotification => 'Test Notification';

  @override
  String get sendTestNotificationDescription => 'Send a test notification to verify functionality';

  @override
  String get dailyReminder => 'Daily Reminder';

  @override
  String get scheduleDailyReminderDescription => 'Schedule a daily reminder to explore hymns';

  @override
  String get hymnOfTheDay => 'Hymn of the Day';

  @override
  String get getNotifiedAboutFeaturedHymns => 'Get notified about featured hymns';

  @override
  String get weeklySabbathReminder => 'Weekly Sabbath Reminder';

  @override
  String get weeklySabbathReminderDescription => 'Get reminded every Friday at 6:00 PM to prepare for the Sabbath and sing praises to the Lord';

  @override
  String get sabbathReminderTitle => 'Sabbath Preparation';

  @override
  String get sabbathReminderBody => 'It is the Sabbath! Take time to prepare your heart and sing praises to the Lord. Blessed Sabbath!';

  @override
  String get checkEmailInstructions => 'Please check your email and follow the instructions to reset your password.';
}
