import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';

import '../../../shared/constants/app_colors.dart';

class FilterSelectorBottomSheet extends StatelessWidget {
  final AppLocalizations l10n;
  final String label;
  final String? currentValue;
  final List<String> options;
  final Function(String?) onChanged;

  const FilterSelectorBottomSheet({
    super.key,
    required this.l10n,
    required this.label,
    required this.currentValue,
    required this.options,
    required this.onChanged,
  });

  static void show({
    required BuildContext context,
    required AppLocalizations l10n,
    required String label,
    required String? currentValue,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FilterSelectorBottomSheet(
        l10n: l10n,
        label: label,
        currentValue: currentValue,
        options: options,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary(context).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
          BoxShadow(
            color: AppColors.textPrimary(context).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.all(label),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onChanged(null);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delete,
                          size: 16,
                          color: AppColors.error,
                        ),
                        const Gap(4),
                        Text(
                          l10n.clear,
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Options list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = currentValue == option;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      option,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    trailing: isSelected
                        ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          )
                        : Icon(
                            Icons.radio_button_unchecked,
                            color: AppColors.textSecondary(context)
                                .withValues(alpha: 0.5),
                            size: 20,
                          ),
                    onTap: () {
                      Navigator.pop(context);
                      onChanged(option);
                    },
                  ),
                );
              },
            ),
          ),

          // Bottom padding for safe area
          Gap(MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}
