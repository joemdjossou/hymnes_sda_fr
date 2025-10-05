import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'core/providers/language_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/repositories/hybrid_favorites_repository.dart';
import 'core/repositories/hymn_repository.dart';
import 'core/services/auth_service.dart';
import 'features/audio/bloc/audio_bloc.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/favorites/bloc/favorites_bloc.dart';
import 'presentation/screens/splash_screen.dart';
import 'shared/constants/app_theme.dart';

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
            hybridRepository: HybridFavoritesRepository(),
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

              return PostHogWidget(
                // Wrapped the app with PostHogWidget
                child: MaterialApp(
                  // Added PosthogObserver to navigatorObservers
                  navigatorObservers: [PosthogObserver()],
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
