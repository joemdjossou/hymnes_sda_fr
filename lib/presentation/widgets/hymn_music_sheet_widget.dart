import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/models/hymn.dart';
import '../../core/services/music_sheet_service.dart';
import '../../shared/constants/app_colors.dart';
import 'music_sheet_bottom_sheet.dart';

/// Widget responsible for displaying hymn music sheet section
/// Follows Single Responsibility Principle
class HymnMusicSheetWidget extends StatefulWidget {
  final Hymn hymn;

  const HymnMusicSheetWidget({
    super.key,
    required this.hymn,
  });

  @override
  State<HymnMusicSheetWidget> createState() => _HymnMusicSheetWidgetState();
}

class _HymnMusicSheetWidgetState extends State<HymnMusicSheetWidget> {
  final MusicSheetService _musicSheetService = MusicSheetService();
  List<String>? _availablePdfs;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _checkAvailablePdfs();
  }

  Future<void> _checkAvailablePdfs() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final pdfs =
          await _musicSheetService.getAvailablePdfUrls(widget.hymn.number);
      if (mounted) {
        setState(() {
          _availablePdfs = pdfs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  void _showMusicSheets() {
    if (_availablePdfs != null && _availablePdfs!.isNotEmpty) {
      // Use in-app webview directly
      MusicSheetBottomSheet.show(
        context,
        pdfUrls: _availablePdfs!,
        hymnTitle: widget.hymn.title,
        hymnNumber: widget.hymn.number,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Don't show the widget if no PDFs are available and not loading
    if (!_isLoading && (_availablePdfs?.isEmpty ?? true) && !_hasError) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _availablePdfs?.isNotEmpty == true ? _showMusicSheets : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              AppColors.primary.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.music_note,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.musicSheet,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getSubtitleText(l10n),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            _buildTrailingWidget(),
          ],
        ),
      ),
    );
  }

  String _getSubtitleText(AppLocalizations l10n) {
    if (_isLoading) {
      return l10n.checkingAvailability;
    } else if (_hasError) {
      return l10n.errorCheckingMusicSheets;
    } else if (_availablePdfs?.isEmpty ?? true) {
      return l10n.noMusicSheetsAvailable;
    } else {
      final count = _availablePdfs!.length;
      return count == 1 ? l10n.viewMusicSheet : l10n.viewMusicSheets(count);
    }
  }

  Widget _buildTrailingWidget() {
    if (_isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      );
    } else if (_hasError) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.error_outline,
          color: AppColors.error,
          size: 16,
        ),
      );
    } else if (_availablePdfs?.isNotEmpty == true) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.primary,
          size: 16,
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.music_off,
          color: AppColors.textSecondary.withValues(alpha: 0.5),
          size: 16,
        ),
      );
    }
  }
}
