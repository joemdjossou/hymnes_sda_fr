import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';

import '../../../core/providers/language_provider.dart';
import '../../../shared/constants/app_colors.dart';

class LanguageSectionWidget extends StatelessWidget {
  const LanguageSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground(context),
            AppColors.cardBackground(context).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.textPrimary(context).withValues(alpha: 0.05),
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
                padding: const EdgeInsets.all(AppConstants.defaultPadding - 4),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient(context),
                  borderRadius:
                      BorderRadius.circular(AppConstants.mediumBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.language_rounded,
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
                      l10n.language,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const Gap(4),
                    Text(
                      l10n.choosePreferredLanguage,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary(context)
                            .withValues(alpha: 0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(20),
          BlocBuilder<LanguageBloc, LanguageState>(
            builder: (context, state) {
              final currentLocale = state is LanguageLoaded
                  ? state.locale
                  : const Locale('en', 'US');

              return Column(
                children: LanguageBloc.supportedLocales.map((locale) {
                  final isSelected =
                      currentLocale.languageCode == locale.languageCode;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          context
                              .read<LanguageBloc>()
                              .add(ChangeLanguage(locale));
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.all(AppConstants.mediumPadding),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : AppColors.surface(context)
                                    .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.4)
                                  : AppColors.border(context)
                                      .withValues(alpha: 0.2),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Text(
                                LanguageBloc.getLanguageFlag(locale),
                                style: const TextStyle(fontSize: 24),
                              ),
                              const Gap(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      LanguageBloc.getLanguageName(locale),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textPrimary(context),
                                      ),
                                    ),
                                    Text(
                                      locale.languageCode == 'en'
                                          ? l10n.english
                                          : l10n.french,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary(context)
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(
                                      AppConstants.smallPadding - 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.largeBorderRadius),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
