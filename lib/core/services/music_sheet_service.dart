import 'dart:io';

import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';

/// Service responsible for handling hymn music sheet PDF operations
/// Follows Single Responsibility Principle
class MusicSheetService {
  static const String _baseUrl = AppConstants.musicSheetBaseUrl;

  /// Generate PDF URLs for a hymn based on the musicsheets count
  /// Returns a list of URLs for available music sheets
  /// musicsheets: number of music sheets available (0, 1, 2, etc.)
  List<String> generatePdfUrls(String hymnNumber, int musicsheets) {
    if (musicsheets <= 0) {
      return [];
    }

    final List<String> urls = [];
    final paddedNumber = hymnNumber.padLeft(3, '0');

    // Base URL (e.g., H001.pdf)
    urls.add('${_baseUrl}H$paddedNumber.pdf');

    // If there are multiple sheets, add variations with 's' suffix
    // For 2 sheets: H001.pdf, H001s.pdf
    // For 3 sheets: H001.pdf, H001s.pdf, H001ss.pdf
    // etc.
    for (int i = 1; i < musicsheets; i++) {
      final suffix = 's' * i;
      urls.add('${_baseUrl}H$paddedNumber$suffix.pdf');
    }

    // Apply platform-specific URL transformation
    return urls.map((url) => _getPlatformSpecificUrl(url)).toList();
  }

  /// Get Platform Specific URL
  /// Returns the URL for the platform specific PDF
  String _getPlatformSpecificUrl(String pdfUrl) {
    if (Platform.isAndroid) {
      return 'https://docs.google.com/viewer?url=${Uri.encodeComponent(pdfUrl)}&embedded=true';
    }
    return pdfUrl;
  }

  /// Get the display name for a PDF URL
  /// Extracts a user-friendly name from the URL
  String getPdfDisplayName(String url, int index) {
    final uri = Uri.parse(url);
    final fileName = uri.pathSegments.last;

    if (fileName.contains('s.pdf')) {
      final sCount = fileName
          .split('.pdf')[0]
          .split('H')[1]
          .replaceAll(RegExp(r'[0-9]'), '')
          .length;
      return 'Music Sheet ${index + 1} (Variation ${sCount})';
    }

    return 'Music Sheet ${index + 1}';
  }
}
