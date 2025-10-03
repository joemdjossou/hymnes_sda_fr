import 'package:flutter/material.dart';

import '../../core/models/hymn.dart';
import '../../shared/constants/app_colors.dart';

/// Widget responsible only for displaying hymn header information
/// Follows Single Responsibility Principle
class HymnHeaderWidget extends StatelessWidget {
  final Hymn hymn;

  const HymnHeaderWidget({
    super.key,
    required this.hymn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Hymn ${hymn.number}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hymn.style,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hymn.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (hymn.author.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'by ${hymn.author}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (hymn.composer.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Music: ${hymn.composer}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
