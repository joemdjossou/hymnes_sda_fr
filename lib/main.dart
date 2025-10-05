import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hymnes_sda_fr/firebase_options.dart';

import 'core/providers/language_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/repositories/hymn_repository.dart';
import 'core/services/auth_service.dart';
import 'core/services/storage_service.dart';
import 'features/audio/bloc/audio_bloc.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/favorites/bloc/favorites_bloc.dart';
import 'presentation/screens/splash_screen.dart';
import 'shared/constants/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize services
  await StorageService().initialize();
  // Uncomment the line below to clear all data if you encounter type errors
  // await StorageService().clearAllData();

  runApp(const HymnesApp());
}

class HymnesApp extends StatelessWidget {
  const HymnesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LanguageBloc()..add(LoadLanguage()),
        ),
        BlocProvider(
          create: (context) => ThemeBloc()..add(LoadTheme()),
        ),
        BlocProvider(
          create: (context) => AudioBloc()..add(InitializeAudio()),
        ),
        BlocProvider(
          create: (context) =>
              AuthBloc(authService: AuthService())..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => FavoritesBloc(
            favoriteRepository: HymnRepository(),
          )..add(LoadFavorites()),
        ),
      ],
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, languageState) {
          final locale = languageState is LanguageLoaded
              ? languageState.locale
              : const Locale('fr', 'FR');

          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              final themeMode = themeState is ThemeLoaded
                  ? themeState.themeMode
                  : ThemeMode.system;

              return MaterialApp(
                title: 'Hymnes & Louanges Adventiste',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                locale: locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: LanguageBloc.supportedLocales,
                home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
