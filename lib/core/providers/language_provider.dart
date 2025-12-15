import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object> get props => [];
}

class ChangeLanguage extends LanguageEvent {
  final Locale locale;

  const ChangeLanguage(this.locale);

  @override
  List<Object> get props => [locale];
}

class LoadLanguage extends LanguageEvent {}

// States
abstract class LanguageState extends Equatable {
  const LanguageState();

  @override
  List<Object> get props => [];
}

class LanguageInitial extends LanguageState {}

class LanguageLoaded extends LanguageState {
  final Locale locale;

  const LanguageLoaded(this.locale);

  @override
  List<Object> get props => [locale];
}

// Bloc
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  static const String _languageKey = 'selected_language';

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('fr', 'FR'),
  ];

  LanguageBloc() : super(LanguageInitial()) {
    on<LoadLanguage>(_onLoadLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
  }

  Future<void> _onLoadLanguage(
    LoadLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(_languageKey);

      // If language is not saved, detect system language on first launch
      if (savedLanguageCode == null) {
        final systemLocale = _getSystemLocale();
        final detectedLocale = _detectSupportedLocale(systemLocale);

        // Save the detected language for future launches
        await prefs.setString(_languageKey, detectedLocale.languageCode);
        emit(LanguageLoaded(detectedLocale));
        return;
      }

      // Use saved language preference
      final locale = supportedLocales.firstWhere(
        (locale) => locale.languageCode == savedLanguageCode,
        orElse: () => const Locale('en', 'US'),
      );

      emit(LanguageLoaded(locale));
    } catch (e) {
      emit(const LanguageLoaded(Locale('en', 'US')));
    }
  }

  /// Get the system locale from the device
  Locale _getSystemLocale() {
    try {
      // Get the system locale from WidgetsBinding
      final systemLocales = WidgetsBinding.instance.platformDispatcher.locales;
      if (systemLocales.isNotEmpty) {
        return systemLocales.first;
      }
    } catch (e) {
      // If error, return English as fallback
    }
    return const Locale('en', 'US');
  }

  /// Detect if the system locale is supported, otherwise fallback to English
  Locale _detectSupportedLocale(Locale systemLocale) {
    final languageCode = systemLocale.languageCode.toLowerCase();

    // Check if the system language is French
    if (languageCode == 'fr') {
      return const Locale('fr', 'FR');
    }

    // Check if the system language is English
    if (languageCode == 'en') {
      return const Locale('en', 'US');
    }

    // For any other language, fallback to English
    return const Locale('en', 'US');
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, event.locale.languageCode);
      emit(LanguageLoaded(event.locale));
    } catch (e) {
      // If saving fails, still emit the new locale
      emit(LanguageLoaded(event.locale));
    }
  }

  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      default:
        return 'English';
    }
  }

  static String getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'fr':
        return '🇫🇷';
      default:
        return '🇺🇸';
    }
  }
}
