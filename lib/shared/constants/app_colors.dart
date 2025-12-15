import 'package:flutter/material.dart';

class AppColors {
  // Primary colors - Forest Green
  static const Color primary = Color(0xFF228B22); // Forest Green
  static const Color primaryDark = Color(0xFF006400); // Dark Forest Green
  static const Color primaryLight = Color(0xFF32CD32); // Lime Green

  // Secondary colors - Gold and Yellow
  static const Color secondary = Color(0xFFFFD700); // Gold
  static const Color secondaryDark = Color(0xFFB8860B); // Dark Goldenrod
  static const Color secondaryLight = Color(0xFFFFFF00); // Yellow

  // Light Theme Colors
  static const Color lightBackground =
      Color(0xFFFDF6E3); // Very light cream with gold tint
  static const Color lightCardBackground =
      Color(0xFFFFFFFF); // Pure White for cards
  static const Color lightSurface = Color(0xFFF9F5E7); // Light cream surface
  static const Color lightTextPrimary =
      Color(0xFF000000); // Black for primary text
  static const Color lightTextSecondary =
      Color(0xFF333333); // Dark Gray for secondary text
  static const Color lightTextHint = Color(0xFF666666); // Medium Gray for hints
  static const Color lightBorder = Color(0xFFE8E0C7); // Light goldenrod border
  static const Color lightDivider =
      Color(0xFFD4C4A8); // Light goldenrod divider
  static const Color lightAudioPlayerBackground =
      Color(0xFFF9F5E7); // Light cream background
  static const Color lightAudioPlayerProgress =
      Color(0xFF000000); // Black for progress
  static const Color lightAudioPlayerControl =
      Color(0xFF333333); // Dark Gray for controls

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212); // Dark background
  static const Color darkCardBackground =
      Color(0xFF1E1E1E); // Dark card background
  static const Color darkSurface = Color(0xFF2C2C2C); // Dark surface
  static const Color darkTextPrimary =
      Color(0xFFFFFFFF); // White for primary text
  static const Color darkTextSecondary =
      Color(0xFFB3B3B3); // Light Gray for secondary text
  static const Color darkTextHint = Color(0xFF808080); // Medium Gray for hints
  static const Color darkBorder = Color(0xFF404040); // Dark border
  static const Color darkDivider = Color(0xFF333333); // Dark divider
  static const Color darkAudioPlayerBackground =
      Color(0xFF2C2C2C); // Dark background
  static const Color darkAudioPlayerProgress =
      Color(0xFFFFFFFF); // White for progress
  static const Color darkAudioPlayerControl =
      Color(0xFFB3B3B3); // Light Gray for controls

  // Status colors (same for both themes)
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Favorite colors (same for both themes)
  static const Color favorite = Color(0xFF228B22); // Gold
  static const Color favoriteLight = Color.fromARGB(255, 82, 134, 82); // Yellow

  // Theme-aware color getters
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }

  static Color cardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCardBackground
        : lightCardBackground;
  }

  static Color bottomNavigationBarBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCardBackground
        : lightSurface;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : lightSurface;
  }

  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : lightTextPrimary;
  }

  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }

  static Color textHint(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextHint
        : lightTextHint;
  }

  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorder
        : lightBorder;
  }

  static Color divider(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkDivider
        : lightDivider;
  }

  static Color audioPlayerBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkAudioPlayerBackground
        : lightAudioPlayerBackground;
  }

  static Color audioPlayerProgress(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkAudioPlayerProgress
        : lightAudioPlayerProgress;
  }

  static Color audioPlayerControl(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkAudioPlayerControl
        : lightAudioPlayerControl;
  }

  // Gradient colors (theme-aware)
  static LinearGradient primaryGradient(BuildContext context) {
    return LinearGradient(
      colors: [primary, primaryDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient secondaryGradient(BuildContext context) {
    return LinearGradient(
      colors: [secondary, secondaryDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Legacy static colors for backward compatibility (deprecated)
  @Deprecated('Use AppColors.background(context) instead')
  static const Color backgroundLegacy = lightBackground;

  @Deprecated('Use AppColors.cardBackground(context) instead')
  static const Color cardBackgroundLegacy = lightCardBackground;

  @Deprecated('Use AppColors.surface(context) instead')
  static const Color surfaceLegacy = lightSurface;

  @Deprecated('Use AppColors.textPrimary(context) instead')
  static const Color textPrimaryLegacy = lightTextPrimary;

  @Deprecated('Use AppColors.textSecondary(context) instead')
  static const Color textSecondaryLegacy = lightTextSecondary;

  @Deprecated('Use AppColors.textHint(context) instead')
  static const Color textHintLegacy = lightTextHint;

  @Deprecated('Use AppColors.border(context) instead')
  static const Color borderLegacy = lightBorder;

  @Deprecated('Use AppColors.divider(context) instead')
  static const Color dividerLegacy = lightDivider;

  @Deprecated('Use AppColors.audioPlayerBackground(context) instead')
  static const Color audioPlayerBackgroundLegacy = lightAudioPlayerBackground;

  @Deprecated('Use AppColors.audioPlayerProgress(context) instead')
  static const Color audioPlayerProgressLegacy = lightAudioPlayerProgress;

  @Deprecated('Use AppColors.audioPlayerControl(context) instead')
  static const Color audioPlayerControlLegacy = lightAudioPlayerControl;
}
