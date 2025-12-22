import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage lyrics font size preference across the app
class LyricsFontSizeService {
  static final LyricsFontSizeService _instance =
      LyricsFontSizeService._internal();
  factory LyricsFontSizeService() => _instance;
  LyricsFontSizeService._internal();

  static const String _fontSizeKey = 'lyrics_font_size';
  static const double _defaultFontSize = 16.0;

  /// Get the saved font size, or return default if not set
  Future<double> getFontSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_fontSizeKey) ?? _defaultFontSize;
    } catch (e) {
      return _defaultFontSize;
    }
  }

  /// Save the font size preference
  Future<void> setFontSize(double fontSize) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_fontSizeKey, fontSize);
    } catch (e) {
      // Silently fail if saving doesn't work
    }
  }

  /// Get the default font size
  static double get defaultFontSize => _defaultFontSize;
}
