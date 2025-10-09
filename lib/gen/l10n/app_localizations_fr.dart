// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Hymnes';

  @override
  String get appSubtitle => 'Hymnes et Louanges Adventistes';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get hymnHistory => 'Histoire du Cantique';

  @override
  String get discoverStory => 'Découvrez l\'histoire derrière ce cantique';

  @override
  String get hymnInformation => 'Informations du Cantique';

  @override
  String get hymnStory => 'Histoire du Cantique';

  @override
  String get number => 'Numéro';

  @override
  String get title => 'Titre';

  @override
  String get author => 'Auteur';

  @override
  String get composer => 'Compositeur';

  @override
  String get style => 'Style';

  @override
  String get midiFile => 'Fichier MIDI';

  @override
  String get lyrics => 'Paroles';

  @override
  String get loading => 'Chargement...';

  @override
  String get hymnNotFound => 'Cantique introuvable';

  @override
  String get errorLoadingHymn => 'Erreur lors du chargement du cantique';

  @override
  String get close => 'Fermer';

  @override
  String get unknown => 'Inconnu';

  @override
  String get home => 'Accueil';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get hymns => 'hymnes';

  @override
  String get search => 'Recherche';

  @override
  String get favorites => 'Favoris';

  @override
  String get searchHymns => 'Rechercher des cantiques...';

  @override
  String get clear => 'Effacer';

  @override
  String hymnsFound(int count) {
    return '$count cantiques trouvés';
  }

  @override
  String get noHymnsAvailable => 'Aucun cantique disponible';

  @override
  String get noHymnsFound => 'Aucun cantique trouvé';

  @override
  String get noHymnsAvailableAtMoment => 'Aucun hymne disponible pour le moment';

  @override
  String get tryModifyingSearchCriteria => 'Essayez de modifier vos critères de recherche';

  @override
  String get advancedSearchToBe => 'Recherche avancée - à implémenter';

  @override
  String get favoritesToBe => 'Écran des favoris - à implémenter';

  @override
  String get noFavoritesYet => 'Aucun favori pour le moment';

  @override
  String get addFavoritesDescription => 'Appuyez sur l\'icône cœur sur vos cantiques préférés pour les ajouter à vos favoris.';

  @override
  String get skip => 'Passer';

  @override
  String get continue_ => 'Continuer';

  @override
  String get getStarted => 'Commencer';

  @override
  String get welcomeToHymnes => 'Bienvenue dans Hymnes et Louanges Adventiste';

  @override
  String get discoverSacredMusic => 'Découvrez la Musique Sacrée';

  @override
  String get welcomeDescription => 'Explorez une vaste collection de cantiques adventistes et de chants de louange. Vivez l\'adoration à travers de belles mélodies et des paroles inspirantes.';

  @override
  String get searchAndDiscover => 'Rechercher et Découvrir';

  @override
  String get findYourFavorites => 'Trouvez Vos Favoris';

  @override
  String get searchDescription => 'Trouvez facilement vos cantiques préférés par titre, auteur ou paroles. Notre recherche puissante vous aide à découvrir de nouveaux chants pour l\'adoration.';

  @override
  String get midiPlayback => 'Lecture MIDI';

  @override
  String get highQualityAudio => 'Audio Haute Qualité';

  @override
  String get midiDescription => 'Écoutez les cantiques avec une lecture MIDI cristalline. Choisissez différentes pistes vocales et profitez de l\'arrangement musical complet.';

  @override
  String get favoritesAndHistory => 'Favoris et Histoire';

  @override
  String get personalCollection => 'Collection Personnelle';

  @override
  String get favoritesDescription => 'Sauvegardez vos cantiques préférés et explorez leur riche histoire. Apprenez sur les auteurs et les histoires derrière chaque chant.';

  @override
  String hymnStoryTemplate(String title, String author, String composer, String style) {
    return 'Ce cantique bien-aimé \"$title\" a été écrit par $author$composer. Le style $style le rend parfait pour l\'adoration et la dévotion personnelle. Son message intemporel continue d\'inspirer les croyants du monde entier.';
  }

  @override
  String get unknownAuthor => 'un auteur inconnu';

  @override
  String withMusicComposedBy(String composer) {
    return ' avec la musique composée par $composer';
  }

  @override
  String hymnNumber(String number) {
    return 'Cantique $number';
  }

  @override
  String hymnTitleWithNumber(String number, String title) {
    return '$number. $title';
  }

  @override
  String get comingSoon => 'Bientôt disponible!!!';

  @override
  String get allVoices => 'Toutes les Voix';

  @override
  String get soprano => 'Soprano';

  @override
  String get alto => 'Alto';

  @override
  String get tenor => 'Ténor';

  @override
  String get bass => 'Basse';

  @override
  String get countertenor => 'Contre-ténor';

  @override
  String get baritone => 'Baryton';

  @override
  String get musicSheet => 'Partition Musicale';

  @override
  String get viewMusicSheet => 'Voir la partition (PDF)';

  @override
  String viewMusicSheets(int count) {
    return 'Voir $count partitions (PDF)';
  }

  @override
  String get checkingAvailability => 'Vérification de la disponibilité...';

  @override
  String get errorCheckingMusicSheets => 'Erreur lors de la vérification des partitions';

  @override
  String get noMusicSheetsAvailable => 'Aucune partition disponible';

  @override
  String get loadingMusicSheet => 'Chargement de la partition...';

  @override
  String get unableToDisplayPdf => 'Impossible d\'afficher le PDF';

  @override
  String get webViewFailedToLoad => 'Échec du chargement de la WebView';

  @override
  String get pdfLoadingTimeout => 'Délai d\'attente de chargement PDF';

  @override
  String get failedToLoadPdf => 'Échec du chargement du PDF. Appuyez pour ouvrir dans le navigateur.';

  @override
  String get openInBrowser => 'Ouvrir dans le Navigateur';

  @override
  String get retry => 'Réessayer';

  @override
  String get cannotOpenPdfInBrowser => 'Impossible d\'ouvrir le PDF dans le navigateur';

  @override
  String errorOpeningPdf(String error) {
    return 'Erreur lors de l\'ouverture du PDF : $error';
  }

  @override
  String get login => 'Connexion';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get signInWithApple => 'Se connecter avec Apple';

  @override
  String get signInWithEmail => 'Se connecter avec l\'email';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get welcomeBackDescription => 'Connectez-vous pour sauvegarder vos cantiques favoris et accéder à votre collection personnelle.';

  @override
  String get createAccountDescription => 'Créez un compte pour sauvegarder vos cantiques favoris et accéder à votre collection personnelle.';

  @override
  String get enterEmail => 'Entrez votre email';

  @override
  String get enterPassword => 'Entrez votre mot de passe';

  @override
  String get enterConfirmPassword => 'Confirmez votre mot de passe';

  @override
  String get passwordTooShort => 'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get invalidEmail => 'L\'adresse e-mail n\'est pas valide.';

  @override
  String get emailRequired => 'L\'email est requis';

  @override
  String get passwordRequired => 'Le mot de passe est requis';

  @override
  String get confirmPasswordRequired => 'Veuillez confirmer votre mot de passe';

  @override
  String get signInSuccess => 'Connexion réussie';

  @override
  String get signUpSuccess => 'Compte créé avec succès';

  @override
  String get signOutSuccess => 'Déconnexion réussie';

  @override
  String passwordResetSent(String email) {
    return 'Email de réinitialisation envoyé à $email';
  }

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get resetPasswordDescription => 'Entrez votre adresse email et nous vous enverrons un lien pour réinitialiser votre mot de passe.';

  @override
  String get sendResetEmail => 'Envoyer l\'email de réinitialisation';

  @override
  String get backToSignIn => 'Retour à la connexion';

  @override
  String get accountCreated => 'Compte créé';

  @override
  String get accountCreatedDescription => 'Votre compte a été créé avec succès. Vous pouvez maintenant sauvegarder vos cantiques favoris.';

  @override
  String get continueToApp => 'Continuer vers l\'application';

  @override
  String get authenticationRequired => 'Authentification requise';

  @override
  String get authenticationRequiredDescription => 'Veuillez vous connecter pour sauvegarder des cantiques dans vos favoris.';

  @override
  String get signInToContinue => 'Se connecter pour continuer';

  @override
  String get cancel => 'Annuler';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get theme => 'Thème';

  @override
  String get subtheme => 'Sous-thème';

  @override
  String get filters => 'Filtres';

  @override
  String get clearAllFilters => 'Effacer tous les filtres';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String all(String label) {
    return 'Tous les $label';
  }

  @override
  String get selectTheme => 'Choisissez l\'apparence de votre thème préféré';

  @override
  String get systemTheme => 'Système';

  @override
  String get lightTheme => 'Clair';

  @override
  String get darkTheme => 'Sombre';

  @override
  String get systemThemeDescription => 'Suivre le paramètre système';

  @override
  String get lightThemeDescription => 'Toujours utiliser le thème clair';

  @override
  String get darkThemeDescription => 'Toujours utiliser le thème sombre';

  @override
  String get account => 'Compte';

  @override
  String get signOutConfirmation => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get or => 'OU';

  @override
  String get unknownUser => 'Utilisateur Inconnu';

  @override
  String get signInToSaveFavorites => 'Connectez-vous pour sauvegarder vos favoris';

  @override
  String get unexpectedError => 'Une erreur inattendue s\'est produite. Veuillez réessayer.';

  @override
  String get appleSignInFailed => 'La connexion Apple a échoué. Veuillez réessayer.';

  @override
  String get invalidAppleResponse => 'Réponse invalide d\'Apple. Veuillez réessayer.';

  @override
  String get appleSignInNotHandled => 'La connexion Apple n\'a pas été gérée. Veuillez réessayer.';

  @override
  String get unknownAppleError => 'Une erreur inconnue s\'est produite lors de la connexion Apple.';

  @override
  String get signOutError => 'Une erreur s\'est produite lors de la déconnexion. Veuillez réessayer.';

  @override
  String get userNotFound => 'Aucun utilisateur trouvé pour cette adresse e-mail.';

  @override
  String get wrongPassword => 'Mot de passe incorrect fourni pour cet utilisateur.';

  @override
  String get emailAlreadyInUse => 'Un compte existe déjà pour cet e-mail.';

  @override
  String get weakPassword => 'Le mot de passe fourni est trop faible.';

  @override
  String get userDisabled => 'Ce compte utilisateur a été désactivé.';

  @override
  String get tooManyRequests => 'Trop de tentatives. Veuillez réessayer plus tard.';

  @override
  String get operationNotAllowed => 'La connexion avec cette méthode n\'est pas autorisée.';

  @override
  String get invalidCredential => 'Les identifiants sont invalides ou ont expiré.';

  @override
  String get accountExistsWithDifferentCredential => 'Un compte existe déjà avec la même adresse e-mail mais des identifiants de connexion différents.';

  @override
  String get networkRequestFailed => 'Erreur réseau. Veuillez vérifier votre connexion internet.';

  @override
  String get authenticationError => 'Une erreur d\'authentification s\'est produite.';

  @override
  String get appInfo => 'Informations de l\'application';

  @override
  String get version => 'Version';

  @override
  String get buildNumber => 'Build';

  @override
  String get customizeExperience => 'Personnalisez votre expérience';

  @override
  String get choosePreferredLanguage => 'Choisissez votre langue préférée';

  @override
  String get manageUserAccount => 'Gérez votre compte utilisateur';

  @override
  String get appInformation => 'Informations sur l\'application';

  @override
  String get hymnSaved => 'hymne sauvegardé';

  @override
  String get hymnsSaved => 'hymnes sauvegardés';

  @override
  String get yourFavoriteHymns => 'Vos hymnes préférés';

  @override
  String get oopsErrorOccurred => 'Oups! Une erreur s\'est produite';

  @override
  String get discoverHymns => 'Découvrir des hymnes';

  @override
  String searchAmongHymns(int count) {
    return 'Recherchez parmi $count hymnes';
  }

  @override
  String get customizeAppAppearance => 'Personnalisez l\'apparence de l\'application';

  @override
  String get hymn => 'hymne';

  @override
  String get hymnNotFoundDescription => 'La description de l\'hymne que vous recherchez n\'a pas été trouvée';

  @override
  String get back => 'Retour';

  @override
  String get favorite => 'Favori';

  @override
  String get favoriteAdded => 'Ajouté aux favoris';

  @override
  String get favoriteRemoved => 'Retiré des favoris';

  @override
  String get templateStory => 'Histoire Modèle';

  @override
  String get fullHymnStoryComingSoon => 'L\'histoire complète du cantique arrive bientôt !';

  @override
  String get tapForMoreInfo => 'Appuyez pour plus d\'informations';

  @override
  String get sortBy => 'Trier par';

  @override
  String get sortByNumber => 'Numéro';

  @override
  String get sortByDateAdded => 'Date d\'ajout';

  @override
  String get sortByTitle => 'Titre';

  @override
  String get sortByAuthor => 'Auteur';

  @override
  String get sortOldestFirst => 'Plus ancien en premier';

  @override
  String get sortNewestFirst => 'Plus récent en premier';

  @override
  String get sortAscending => 'Croissant';

  @override
  String get sortDescending => 'Décroissant';

  @override
  String get somethingWentWrong => 'Quelque chose s\'est mal passé';

  @override
  String get couldNotProcessRequest => 'Nous n\'avons pas pu traiter votre demande. Veuillez réessayer plus tard.';

  @override
  String get actionRequired => 'Action requise';

  @override
  String get checkSettingsBeforeProceeding => 'Veuillez vérifier vos paramètres avant de continuer pour éviter les problèmes potentiels.';

  @override
  String get actionCompleted => 'Action terminée';

  @override
  String get changesSavedSuccessfully => 'Vos modifications ont été sauvegardées avec succès.';

  @override
  String get justSoYouKnow => 'Juste pour votre information';

  @override
  String get loggedInOverHour => 'Vous êtes connecté depuis plus d\'une heure. N\'oubliez pas de sauvegarder vos progrès.';

  @override
  String get lyricsCopied => 'Paroles copiées';

  @override
  String get storyCopied => 'Histoire copiée';

  @override
  String get loadingAudio => 'Chargement de l\'audio...';

  @override
  String retrying(int count) {
    return 'Nouvelle tentative... ($count/3)';
  }

  @override
  String get unableToPlayAudio => 'Impossible de lire l\'audio';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageNotificationPreferences => 'Gérer les préférences de notification';

  @override
  String get testNotification => 'Notification de Test';

  @override
  String get sendTestNotificationDescription => 'Envoyer une notification de test pour vérifier le fonctionnement';

  @override
  String get dailyReminder => 'Rappel Quotidien';

  @override
  String get scheduleDailyReminderDescription => 'Programmer un rappel quotidien pour explorer les cantiques';

  @override
  String get hymnOfTheDay => 'Cantique du Jour';

  @override
  String get getNotifiedAboutFeaturedHymns => 'Être notifié des cantiques en vedette';

  @override
  String get weeklySabbathReminder => 'Rappel Hebdomadaire du Sabbat';

  @override
  String get weeklySabbathReminderDescription => 'Recevez un rappel chaque vendredi à 18h00 pour préparer le Sabbat et chanter des louanges au Seigneur';

  @override
  String get sabbathReminderTitle => 'Préparation du Sabbat';

  @override
  String get sabbathReminderBody => 'Demain c\'est le Sabbat ! Prenez le temps de préparer votre cœur et de chanter des louanges au Seigneur. Sabbat béni !';
}
