import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/core/models/hymn.dart';
import 'package:hymnes_sda_fr/core/repositories/hymn_repository.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';

import '../../../shared/constants/app_colors.dart';

/// Bottom navigation bar widget for navigating between hymns
/// Shows previous and next hymn with their numbers and titles
class HymnNavigationBar extends StatefulWidget {
  final String currentHymnId;
  final Function(String hymnNumber) onHymnTap;

  const HymnNavigationBar({
    super.key,
    required this.currentHymnId,
    required this.onHymnTap,
  });

  @override
  State<HymnNavigationBar> createState() => _HymnNavigationBarState();
}

class _HymnNavigationBarState extends State<HymnNavigationBar> {
  final HymnRepository _hymnRepository = HymnRepository();
  Hymn? _previousHymn;
  Hymn? _nextHymn;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdjacentHymns();
  }

  @override
  void didUpdateWidget(HymnNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentHymnId != widget.currentHymnId) {
      _loadAdjacentHymns();
    }
  }

  Future<void> _loadAdjacentHymns() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allHymns = await _hymnRepository.getAllHymns();
      if (allHymns.isEmpty) {
        setState(() {
          _previousHymn = null;
          _nextHymn = null;
          _isLoading = false;
        });
        return;
      }

      // Sort hymns by number (convert to int for proper numeric sorting)
      final sortedHymns = List<Hymn>.from(allHymns)
        ..sort((a, b) {
          final aNum = int.tryParse(a.number) ?? 0;
          final bNum = int.tryParse(b.number) ?? 0;
          return aNum.compareTo(bNum);
        });

      final currentIndex = sortedHymns.indexWhere(
        (hymn) => hymn.number == widget.currentHymnId,
      );

      setState(() {
        _previousHymn = currentIndex > 0 ? sortedHymns[currentIndex - 1] : null;
        _nextHymn = currentIndex >= 0 && currentIndex < sortedHymns.length - 1
            ? sortedHymns[currentIndex + 1]
            : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _previousHymn = null;
        _nextHymn = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bottomNavigationBarBackground(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.largeBorderRadius),
          topRight: Radius.circular(AppConstants.largeBorderRadius),
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.border(context),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary(context).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Previous Hymn
            Expanded(
              child: _previousHymn != null
                  ? _buildHymnButton(
                      context,
                      hymn: _previousHymn!,
                      isPrevious: true,
                      onTap: () => widget.onHymnTap(_previousHymn!.number),
                    )
                  : _buildEmptyButton(context, isPrevious: true),
            ),
            const Gap(AppConstants.defaultPadding),
            // Next Hymn
            Expanded(
              child: _nextHymn != null
                  ? _buildHymnButton(
                      context,
                      hymn: _nextHymn!,
                      isPrevious: false,
                      onTap: () => widget.onHymnTap(_nextHymn!.number),
                    )
                  : _buildEmptyButton(context, isPrevious: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHymnButton(
    BuildContext context, {
    required Hymn hymn,
    required bool isPrevious,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.smallPadding),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment:
                isPrevious ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (isPrevious) ...[
                Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const Gap(8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: isPrevious
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hymn.number,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      hymn.title,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: isPrevious ? TextAlign.left : TextAlign.right,
                    ),
                  ],
                ),
              ),
              if (!isPrevious) ...[
                const Gap(8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyButton(BuildContext context, {required bool isPrevious}) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: AppColors.textSecondary(context).withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPrevious
                ? Icons.chevron_left_rounded
                : Icons.chevron_right_rounded,
            color: AppColors.textSecondary(context).withValues(alpha: 0.2),
            size: 20,
          ),
        ],
      ),
    );
  }
}
