import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';

import '../../../core/models/hymn.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/custom_toast.dart';

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
                    Icons.info_outline_rounded,
                    [_buildInformationCard(context, l10n)],
                  ),
                  const Gap(24),
                  // Story Section
                  _buildHistorySection(
                    context,
                    l10n.hymnStory,
                    Icons.auto_stories_rounded,
                    [_buildStoryCard(context, l10n)],
                    showCopyButton: true,
                    copyText: hymn.story.isNotEmpty
                        ? hymn.story
                        : _getHymnStory(l10n),
                  ),
                  const Gap(20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient(context),
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
              Icons.history_edu_rounded,
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
                  l10n.hymnNumber(hymn.number),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  hymn.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.textSecondary(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(
      BuildContext context, String title, IconData icon, List<Widget> children,
      {bool showCopyButton = false, String? copyText}) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const Gap(12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            if (showCopyButton && copyText != null) ...[
              const Spacer(),
              GestureDetector(
                onTap: () => _copyText(context, copyText),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.copy,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ],
        ),
        const Gap(16),
        ...children,
      ],
    );
  }

  Widget _buildInformationCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          if (hymn.author.isNotEmpty)
            _buildInfoChip(
                context, l10n.author, hymn.author, Icons.person_rounded),
          if (hymn.composer.isNotEmpty)
            _buildInfoChip(context, l10n.composer, hymn.composer,
                Icons.music_note_rounded),
          _buildInfoChip(context, l10n.style, hymn.style, Icons.style_rounded),
          _buildInfoChip(
              context, l10n.midiFile, hymn.midiFile, Icons.audio_file_rounded),
        ],
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final hasCustomStory = hymn.story.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (!hasCustomStory) {
          ToastService.showInfo(
            context,
            title: l10n.comingSoon,
            message: l10n.fullHymnStoryComingSoon,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Text(
          hasCustomStory ? hymn.story : _getHymnStory(l10n),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary(context),
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
      BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const Gap(8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(2),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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

  void _copyText(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ToastService.showSuccess(
      context,
      title: AppLocalizations.of(context)!.success,
      message: AppLocalizations.of(context)!.storyCopied,
    );
  }
}
