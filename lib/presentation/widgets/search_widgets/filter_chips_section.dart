import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';

import '../../../core/models/hymn.dart';
import '../../../shared/constants/app_colors.dart';
import 'filter_selector_bottom_sheet.dart';

class FilterChipsSection extends StatelessWidget {
  final bool showFilters;
  final Animation<double> filterSlideAnimation;
  final String? selectedTheme;
  final String? selectedSubtheme;
  final List<String> themes;
  final List<Hymn> allHymns;
  final Function(String?) onThemeChanged;
  final Function(String?) onSubthemeChanged;

  const FilterChipsSection({
    super.key,
    required this.showFilters,
    required this.filterSlideAnimation,
    required this.selectedTheme,
    required this.selectedSubtheme,
    required this.themes,
    required this.allHymns,
    required this.onThemeChanged,
    required this.onSubthemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: filterSlideAnimation,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          height: showFilters ? null : 0,
          child: showFilters
              ? Transform.translate(
                  offset: Offset(
                    0,
                    (1 - filterSlideAnimation.value) * -50,
                  ),
                  child: Opacity(
                    opacity: filterSlideAnimation.value,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Gap(20),
                          // Theme Filter
                          _buildFilterChip(
                            context: context,
                            l10n: l10n,
                            label: l10n.theme,
                            value: selectedTheme,
                            options: themes,
                            onChanged: onThemeChanged,
                          ),
                          const Gap(8),
                          // Subtheme Filter
                          _buildFilterChip(
                            context: context,
                            l10n: l10n,
                            label: l10n.subtheme,
                            value: selectedSubtheme,
                            options: selectedTheme != null
                                ? () {
                                    final subthemes = allHymns
                                        .where((h) => h.theme == selectedTheme)
                                        .map((h) => h.subtheme)
                                        .toSet()
                                        .toList();
                                    subthemes.sort();
                                    return subthemes;
                                  }()
                                : allHymns
                                    .map((h) => h.subtheme)
                                    .toSet()
                                    .toList()
                              ..sort(),
                            onChanged: onSubthemeChanged,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required AppLocalizations l10n,
    required String label,
    required String? value,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value != null ? AppColors.primary : AppColors.border(context),
        ),
        color: value != null
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.cardBackground(context),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => FilterSelectorBottomSheet.show(
            context: context,
            l10n: l10n,
            label: label,
            currentValue: value,
            options: options,
            onChanged: onChanged,
          ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value ?? label,
                  style: TextStyle(
                    color: value != null
                        ? AppColors.primary
                        : AppColors.textPrimary(context),
                    fontWeight:
                        value != null ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const Gap(4),
                Icon(
                  Icons.arrow_drop_down,
                  color: value != null
                      ? AppColors.primary
                      : AppColors.textSecondary(context),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
