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

  // Background colors - Light cream with subtle gold tint
  static const Color background =
      Color(0xFFFDF6E3); // Very light cream with gold tint
  static const Color cardBackground = Color(0xFFFFFFFF); // Pure White for cards
  static const Color surface = Color(0xFFF9F5E7); // Light cream surface

  // Text colors - Black and White for better readability
  static const Color textPrimary = Color(0xFF000000); // Black for primary text
  static const Color textSecondary =
      Color(0xFF333333); // Dark Gray for secondary text
  static const Color textHint = Color(0xFF666666); // Medium Gray for hints

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Audio player colors - Light cream with subtle accents
  static const Color audioPlayerBackground =
      Color(0xFFF9F5E7); // Light cream background
  static const Color audioPlayerProgress =
      Color(0xFF000000); // Black for progress
  static const Color audioPlayerControl =
      Color(0xFF333333); // Dark Gray for controls

  // Favorite colors - Gold and Yellow
  static const Color favorite = Color(0xFFFFD700); // Gold
  static const Color favoriteLight = Color(0xFFFFFF00); // Yellow

  // Border colors - Subtle tones for light background
  static const Color border = Color(0xFFE8E0C7); // Light goldenrod border
  static const Color divider = Color(0xFFD4C4A8); // Light goldenrod divider

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
