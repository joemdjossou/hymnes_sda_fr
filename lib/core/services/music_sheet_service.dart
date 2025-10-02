import 'package:http/http.dart' as http;

/// Service responsible for handling hymn music sheet PDF operations
/// Follows Single Responsibility Principle
class MusicSheetService {
  static const String _baseUrl =
      'https://troisanges.org/Musique/HymnesEtLouanges/PDF/';
  static const int _maxVariations = 4;

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
      final response = await http.head(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; HymnesApp/1.0)',
        },
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200 &&
          response.headers['content-type']?.contains('pdf') == true;
    } catch (e) {
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
        availableUrls.add(url);
      }
    }

    return availableUrls;
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
