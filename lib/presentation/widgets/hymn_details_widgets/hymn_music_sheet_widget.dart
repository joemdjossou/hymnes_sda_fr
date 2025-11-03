import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';

import '../../../core/models/hymn.dart';
import '../../../core/services/music_sheet_service.dart';
import '../../../shared/constants/app_colors.dart';
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
  late final List<String> _availablePdfs;

  @override
  void initState() {
    super.initState();
    // Generate PDF URLs synchronously based on musicsheets count from hymn data
    _availablePdfs = _musicSheetService.generatePdfUrls(
      widget.hymn.number,
      widget.hymn.musicsheets,
    );
  }

  void _showMusicSheets() {
    if (_availablePdfs.isNotEmpty) {
      // Use in-app webview directly
      MusicSheetBottomSheet.show(
        context,
        pdfUrls: _availablePdfs,
        hymnTitle: widget.hymn.title,
        hymnNumber: widget.hymn.number,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Don't show the widget if no PDFs are available
    if (_availablePdfs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary(context).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _availablePdfs.isNotEmpty ? _showMusicSheets : null,
          borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.all(AppConstants.defaultPadding - 4),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient(context),
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.music_note_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.musicSheet,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        _getSubtitleText(l10n),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary(context),
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
        ),
      ),
    );
  }

  String _getSubtitleText(AppLocalizations l10n) {
    if (_availablePdfs.isEmpty) {
      return l10n.noMusicSheetsAvailable;
    } else {
      final count = _availablePdfs.length;
      return count == 1 ? l10n.viewMusicSheet : l10n.viewMusicSheets(count);
    }
  }

  Widget _buildTrailingWidget() {
    if (_availablePdfs.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.smallPadding),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppColors.primary,
          size: 16,
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(AppConstants.smallPadding),
        decoration: BoxDecoration(
          color: AppColors.textSecondary(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Icon(
          Icons.music_off_rounded,
          color: AppColors.textSecondary(context).withValues(alpha: 0.5),
          size: 16,
        ),
      );
    }
  }
}
