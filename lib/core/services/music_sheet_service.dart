import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';

import 'error_logging_service.dart';

/// Service responsible for handling hymn music sheet PDF operations
/// Follows Single Responsibility Principle
class MusicSheetService {
  static const String _baseUrl = AppConstants.musicSheetBaseUrl;
  static const int _maxVariations = 4;

  // Error logging service
  final ErrorLoggingService _errorLogger = ErrorLoggingService();

  /// Generate all possible PDF URLs for a hymn number
  /// Returns a list of URLs that need to be validated
  List<String> generatePdfUrls(String hymnNumber) {
    final List<String> urls = [];

    // Add the base URL (e.g., H001.pdf)
    final paddedNumber = hymnNumber.padLeft(3, '0');
    urls.add('${_baseUrl}H$paddedNumber.pdf');

    // Add variations with 's' suffix (e.g., H001s.pdf, H001ss.pdf, etc.)
    for (int i = 1; i <= _maxVariations; i++) {
      final suffix = 's' * i;
      urls.add('${_baseUrl}H$paddedNumber$suffix.pdf');
    }

    return urls;
  }

  /// Check if a PDF URL is accessible
  /// Returns true if the PDF exists and is accessible
  Future<bool> isPdfAccessible(String url) async {
    try {
      // Use iOS Safari user agent to match iOS behavior
      final response = await http.head(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
          'Accept': 'application/pdf,application/octet-stream,*/*',
          'Accept-Language': 'en-US,en;q=0.9',
        },
      ).timeout(const Duration(seconds: 10));

      final contentType = response.headers['content-type']?.toLowerCase();
      final isPdfContentType = contentType?.contains('pdf') == true ||
          contentType == 'application/octet-stream';

      final isAccessible = response.statusCode == 200 && isPdfContentType;

      if (!isAccessible) {
        await _errorLogger.logNetworkDebugforHymnPDF(
          'MusicSheetService',
          url,
          response.statusCode,
          'PDF not accessible - Status: ${response.statusCode}, ContentType: $contentType',
          requestContext: {
            'contentType': contentType,
            'allHeaders': response.headers,
            'statusCode': response.statusCode,
          },
        );
      }

      return isAccessible;
    } catch (e) {
      await _errorLogger.logNetworkDebugforHymnPDF(
        'MusicSheetService',
        url,
        null,
        'Network error while checking PDF accessibility',
        error: e,
        stackTrace: StackTrace.current,
      );
      return false;
    }
  }

  /// Get all available PDF URLs for a hymn
  /// Validates each URL and returns only accessible ones
  Future<List<String>> getAvailablePdfUrls(String hymnNumber) async {
    final allUrls = generatePdfUrls(hymnNumber);
    final List<String> availableUrls = [];

    for (final url in allUrls) {
      if (await isPdfAccessible(url)) {
        availableUrls.add(_getPlatformSpecificUrl(url));
      }
    }

    return availableUrls;
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
