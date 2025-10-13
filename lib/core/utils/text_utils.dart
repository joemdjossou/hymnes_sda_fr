/// Utility functions for text processing and normalization
class TextUtils {
  /// Normalizes text by removing accents and standardizing apostrophes
  /// This helps with better search matching across different text formats
  static String normalizeText(String text) {
    // Remove accents
    String normalized = text
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ýÿ]'), 'y')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[ÀÁÂÃÄÅ]'), 'A')
        .replaceAll(RegExp(r'[ÈÉÊË]'), 'E')
        .replaceAll(RegExp(r'[ÌÍÎÏ]'), 'I')
        .replaceAll(RegExp(r'[ÒÓÔÕÖ]'), 'O')
        .replaceAll(RegExp(r'[ÙÚÛÜ]'), 'U')
        .replaceAll(RegExp(r'[Ý]'), 'Y')
        .replaceAll(RegExp(r'[Ñ]'), 'N')
        .replaceAll(RegExp(r'[Ç]'), 'C');

    // Normalize apostrophes - replace all types with a standard one
    normalized = normalized
        .replaceAll('\u0060', "'") // backtick
        .replaceAll('\u201C', "'") // left double quotation mark
        .replaceAll('\u201D', "'") // right double quotation mark
        .replaceAll('\u2018', "'") // left single quotation mark
        .replaceAll('\u2019', "'"); // right single quotation mark

    return normalized.toLowerCase();
  }
}
