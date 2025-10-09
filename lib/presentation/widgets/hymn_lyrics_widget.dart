import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';

import '../../core/models/hymn.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/custom_toast.dart';

/// Widget responsible only for displaying hymn lyrics
/// Follows Single Responsibility Principle
class HymnLyricsWidget extends StatelessWidget {
  final Hymn hymn;

  const HymnLyricsWidget({
    super.key,
    required this.hymn,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lyrics,
                color: AppColors.primary,
                size: 20,
              ),
              const Gap(8),
              Text(
                l10n.lyrics,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _copyLyrics(context),
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
          ),
          const Gap(16),
          Center(
            child: SelectableText(
              hymn.lyrics,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 16,
                height: 1.6,
              ),
              showCursor: true,
              cursorColor: AppColors.primary,
              cursorWidth: 2.0,
              cursorRadius: const Radius.circular(1.0),
            ),
          ),
        ],
      ),
    );
  }

  void _copyLyrics(BuildContext context) {
    Clipboard.setData(ClipboardData(text: hymn.lyrics));
    ToastService.showSuccess(
      context,
      title: AppLocalizations.of(context)!.success,
      message: AppLocalizations.of(context)!.lyricsCopied,
    );
  }
}
