import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/models/hymn.dart';
import '../../shared/constants/app_colors.dart';

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
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
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
              const SizedBox(width: 8),
              Text(
                l10n.lyrics,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              hymn.lyrics,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
