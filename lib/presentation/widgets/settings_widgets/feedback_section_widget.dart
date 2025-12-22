import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/core/services/feedback_service.dart';
import 'package:hymnes_sda_fr/features/auth/bloc/auth_bloc.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';
import 'package:hymnes_sda_fr/shared/constants/app_colors.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';
import 'package:hymnes_sda_fr/shared/widgets/custom_toast.dart';

class FeedbackSectionWidget extends StatefulWidget {
  const FeedbackSectionWidget({super.key});

  @override
  State<FeedbackSectionWidget> createState() => _FeedbackSectionWidgetState();
}

class _FeedbackSectionWidgetState extends State<FeedbackSectionWidget> {
  final TextEditingController _feedbackController = TextEditingController();
  final FeedbackService _feedbackService = FeedbackService();
  FeedbackType _selectedType = FeedbackType.general;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_feedbackController.text.trim().isEmpty) {
      ToastService.showWarning(
        context,
        title: AppLocalizations.of(context)!.warning,
        message: AppLocalizations.of(context)!.feedbackEmptyMessage,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get user info if available
      final authState = context.read<AuthBloc>().state;
      String? userEmail;
      String? userName;
      String? userId;

      if (authState is Authenticated) {
        userEmail = authState.user.email;
        userName = authState.user.displayName;
        userId = authState.user.uid;
      }

      // Submit feedback
      await _feedbackService.submitFeedback(
        message: _feedbackController.text.trim(),
        type: _selectedType,
        userEmail: userEmail,
        userName: userName,
        userId: userId,
      );

      if (!mounted) return;

      // Show success message
      ToastService.showSuccess(
        context,
        title: AppLocalizations.of(context)!.success,
        message: AppLocalizations.of(context)!.feedbackSuccessMessage,
      );

      // Clear the text field
      _feedbackController.clear();
      setState(() {
        _selectedType = FeedbackType.general;
      });
    } catch (e) {
      if (!mounted) return;
      ToastService.showError(
        context,
        title: AppLocalizations.of(context)!.error,
        message: AppLocalizations.of(context)!.feedbackErrorMessage,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showFeedbackDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.sendFeedback),
        backgroundColor: AppColors.cardBackground(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.feedbackDescription,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 14,
                  ),
                ),
                const Gap(16),

                // Feedback Type Selection
                Text(
                  l10n.feedbackType,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildTypeChip(
                      l10n.feedbackGeneral,
                      FeedbackType.general,
                      Icons.chat_bubble_outline,
                      setState,
                    ),
                    _buildTypeChip(
                      l10n.feedbackBug,
                      FeedbackType.bug,
                      Icons.bug_report_outlined,
                      setState,
                    ),
                    _buildTypeChip(
                      l10n.feedbackFeature,
                      FeedbackType.feature,
                      Icons.lightbulb_outline,
                      setState,
                    ),
                    _buildTypeChip(
                      l10n.feedbackReview,
                      FeedbackType.review,
                      Icons.star_outline,
                      setState,
                    ),
                  ],
                ),
                const Gap(16),

                // Feedback Text Field
                TextField(
                  controller: _feedbackController,
                  maxLines: 6,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    hintText: l10n.feedbackPlaceholder,
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary(context)
                          .withValues(alpha: 0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                      borderSide: BorderSide(
                        color: AppColors.border(context),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                      borderSide: BorderSide(
                        color: AppColors.border(context),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground(context),
                  ),
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const Gap(8),
                Text(
                  l10n.feedbackPrivacyNote,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _feedbackController.clear();
              setState(() {
                _selectedType = FeedbackType.general;
              });
            },
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    Navigator.of(context).pop();
                    _submitFeedback();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(l10n.submit),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(
    String label,
    FeedbackType type,
    IconData icon,
    StateSetter setState,
  ) {
    final isSelected = _selectedType == type;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : AppColors.textSecondary(context),
          ),
          const Gap(4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          this.setState(() {
            _selectedType = type;
          });
        });
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.cardBackground(context),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary(context),
        fontSize: 12,
      ),
      showCheckmark: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppColors.border(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppConstants.smallBorderRadius),
                ),
                child: Icon(
                  Icons.feedback_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.feedbackTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      l10n.feedbackSubtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          Text(
            l10n.feedbackHelp,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(context),
            ),
          ),
          const Gap(16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _showFeedbackDialog,
              icon: const Icon(Icons.send_outlined),
              label: Text(l10n.sendFeedback),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.defaultPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
