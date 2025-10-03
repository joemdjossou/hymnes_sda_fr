import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/models/hymn.dart';
import '../../shared/constants/app_colors.dart';

/// Widget responsible only for displaying hymn history bottom sheet
/// Follows Single Responsibility Principle and Open/Closed Principle
class HymnHistoryBottomSheet extends StatelessWidget {
  final Hymn hymn;

  const HymnHistoryBottomSheet({
    super.key,
    required this.hymn,
  });

  /// Static method to show the bottom sheet
  /// Follows Open/Closed Principle - can be extended without modification
  static void show(BuildContext context, Hymn hymn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HymnHistoryBottomSheet(hymn: hymn),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary(context).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          _buildHeader(context, l10n),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hymn Details Section
                  _buildHistorySection(
                    context,
                    l10n.hymnInformation,
                    Icons.info_outline,
                    [_buildInformationCard(context, l10n)],
                  ),
                  const SizedBox(height: 24),
                  // Story Section
                  _buildHistorySection(
                    context,
                    l10n.hymnStory,
                    Icons.auto_stories,
                    [_buildStoryCard(context, l10n)],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.history_edu,
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
                  l10n.hymnNumber(hymn.number),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  hymn.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context, String title, IconData icon,
      List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInformationCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(context, l10n.number, hymn.number),
          _buildDetailRow(context, l10n.title, hymn.title),
          if (hymn.author.isNotEmpty)
            _buildDetailRow(context, l10n.author, hymn.author),
          if (hymn.composer.isNotEmpty)
            _buildDetailRow(context, l10n.composer, hymn.composer),
          _buildDetailRow(context, l10n.style, hymn.style),
          _buildDetailRow(context, l10n.midiFile, hymn.midiFile),
        ],
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        _getHymnStory(l10n),
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontSize: 16,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(context),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getHymnStory(AppLocalizations l10n) {
    final author = hymn.author.isNotEmpty ? hymn.author : l10n.unknownAuthor;
    final composer =
        hymn.composer.isNotEmpty ? l10n.withMusicComposedBy(hymn.composer) : '';

    return l10n.hymnStoryTemplate(
      hymn.title,
      author,
      composer,
      hymn.style,
    );
  }
}
