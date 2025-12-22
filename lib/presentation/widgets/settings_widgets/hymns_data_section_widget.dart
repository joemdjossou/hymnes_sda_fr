import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hymnes_sda_fr/gen/l10n/app_localizations.dart';
import 'package:hymnes_sda_fr/shared/constants/app_constants.dart';
import 'package:logger/logger.dart';

import '../../../core/models/hymns_version_metadata.dart';
import '../../../core/services/hymns_storage_service.dart';
import '../../../core/services/hymns_sync_service.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/custom_toast.dart';

/// Settings widget for managing hymns data (updates, rollback, reset)
class HymnsDataSectionWidget extends StatefulWidget {
  const HymnsDataSectionWidget({super.key});

  @override
  State<HymnsDataSectionWidget> createState() => _HymnsDataSectionWidgetState();
}

class _HymnsDataSectionWidgetState extends State<HymnsDataSectionWidget> {
  final Logger _logger = Logger();
  final HymnsSyncService _syncService = HymnsSyncService();
  final HymnsStorageService _storage = HymnsStorageService();

  HymnsVersionMetadata? _metadata;
  StorageInfo? _storageInfo;
  SyncStatus _syncStatus = SyncStatus.idle;
  double _syncProgress = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _listenToSyncStatus();
  }

  void _listenToSyncStatus() {
    _syncService.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _syncStatus = status;
        });
      }
    });

    _syncService.progressStream.listen((progress) {
      if (mounted) {
        setState(() {
          _syncProgress = progress;
        });
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final metadata = await HymnsMetadataStorage.load();
      final storageInfo = await _storage.getStorageInfo();

      setState(() {
        _metadata = metadata;
        _storageInfo = storageInfo;
        _isLoading = false;
      });
    } catch (e) {
      _logger.e('Failed to load hymns data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkForUpdates() async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    try {
      final result = await _syncService.checkForUpdates(forceCheck: true);

      if (!mounted) return;

      if (result.success) {
        ToastService.showSuccess(
          context,
          title: l10n.success,
          message: 'Updated to version ${result.newVersion}',
        );
        await _loadData();
      } else if (result.message != null) {
        ToastService.showInfo(
          context,
          title: 'Info',
          message: result.message!,
        );
      } else if (result.error != null) {
        ToastService.showError(
          context,
          title: l10n.error,
          message: result.error!,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ToastService.showError(
        context,
        title: l10n.error,
        message: 'Failed to check for updates: $e',
      );
    }
  }

  Future<void> _rollbackToPrevious() async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.warning),
        content: const Text('Revert to previous hymns version?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Revert'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final result = await _storage.rollbackToPrevious();

      if (!mounted) return;

      if (result.success) {
        // Update metadata
        if (_metadata != null && _metadata!.previousVersion != null) {
          final updatedMetadata = _metadata!.copyWith(
            currentVersion: _metadata!.previousVersion,
            currentVersionChecksum: _metadata!.previousVersionChecksum,
            currentVersionTimestamp: _metadata!.previousVersionTimestamp,
            currentVersionStatus: 'stable',
          );
          await HymnsMetadataStorage.save(updatedMetadata);
        }

        ToastService.showSuccess(
          context,
          title: l10n.success,
          message: 'Reverted to previous version',
        );
        await _loadData();
      } else {
        ToastService.showError(
          context,
          title: l10n.error,
          message: result.error ?? 'Rollback failed',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ToastService.showError(
        context,
        title: l10n.error,
        message: 'Rollback failed: $e',
      );
    }
  }

  Future<void> _clearBlacklist() async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.warning),
        content: const Text(
          'Clear blacklisted versions? This will allow previously failed versions to be tried again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      if (_metadata != null) {
        final updatedMetadata = _metadata!.clearBlacklist();
        await HymnsMetadataStorage.save(updatedMetadata);

        ToastService.showSuccess(
          context,
          title: l10n.success,
          message: 'Blacklist cleared',
        );
        await _loadData();
      }
    } catch (e) {
      if (!mounted) return;
      ToastService.showError(
        context,
        title: l10n.error,
        message: 'Failed to clear blacklist: $e',
      );
    }
  }

  Future<void> _resetToOriginal() async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.warning),
        content: const Text(
          'Reset to original bundled hymns? '
          'This will delete all downloaded versions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final result = await _storage.resetToAssets();

      if (!mounted) return;

      if (result.success) {
        // Reset metadata to bundled version
        final resetMetadata = HymnsVersionMetadata.initial(
          bundledVersion: _storage.bundledVersion,
        );
        await HymnsMetadataStorage.save(resetMetadata);

        ToastService.showSuccess(
          context,
          title: l10n.success,
          message: 'Reset to original version',
        );
        await _loadData();
      } else {
        ToastService.showError(
          context,
          title: l10n.error,
          message: result.error ?? 'Reset failed',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ToastService.showError(
        context,
        title: l10n.error,
        message: 'Reset failed: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;

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
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
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
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                  Icons.library_music_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hymns Data',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'Manage hymns updates and versions',
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

          const Gap(16),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            // Version Info
            _buildInfoRow(
              'Current Version',
              _metadata?.currentVersion ?? 'Unknown',
            ),
            const Gap(8),
            _buildInfoRow(
              'Previous Version',
              _metadata?.previousVersion ?? 'None',
            ),
            const Gap(8),
            _buildInfoRow(
              'Status',
              _metadata?.currentVersionStatus ?? 'Unknown',
            ),
            const Gap(8),
            _buildInfoRow(
              'Storage',
              _storageInfo?.formattedCurrentSize ?? 'Unknown',
            ),
            if (_metadata?.failedVersions.isNotEmpty == true) ...[
              const Gap(8),
              _buildInfoRow(
                'Blacklisted',
                '${_metadata!.failedVersions.length} version(s)',
              ),
            ],

            const Gap(16),

            // Sync Status
            if (_syncStatus != SyncStatus.idle) ...[
              _buildSyncStatus(),
              const Gap(16),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    icon: Icons.cloud_download_outlined,
                    label: 'Check Updates',
                    onTap: _syncStatus == SyncStatus.idle
                        ? _checkForUpdates
                        : null,
                    gradient: AppColors.primaryGradient(context),
                  ),
                ),
              ],
            ),

            const Gap(12),

            // Advanced Actions
            if (_metadata?.failedVersions.isNotEmpty == true) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      icon: Icons.block,
                      label: 'Clear Blacklist',
                      onTap: _syncStatus == SyncStatus.idle
                          ? _clearBlacklist
                          : null,
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.withValues(alpha: 0.8),
                          Colors.deepPurple.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(12),
            ],
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    icon: Icons.history,
                    label: 'Revert',
                    onTap: _metadata?.previousVersion != null &&
                            _syncStatus == SyncStatus.idle
                        ? _rollbackToPrevious
                        : null,
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withValues(alpha: 0.8),
                        Colors.deepOrange.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    icon: Icons.restore,
                    label: 'Reset',
                    onTap: _syncStatus == SyncStatus.idle
                        ? _resetToOriginal
                        : null,
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.withValues(alpha: 0.8),
                        Colors.redAccent.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary(context).withValues(alpha: 0.8),
            fontStyle: FontStyle.italic,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncStatus() {
    String statusText;
    IconData statusIcon;

    switch (_syncStatus) {
      case SyncStatus.checking:
        statusText = 'Checking for updates...';
        statusIcon = Icons.search;
        break;
      case SyncStatus.downloading:
        statusText = 'Downloading... ${(_syncProgress * 100).toInt()}%';
        statusIcon = Icons.cloud_download;
        break;
      case SyncStatus.validating:
        statusText = 'Validating...';
        statusIcon = Icons.verified_user;
        break;
      case SyncStatus.installing:
        statusText = 'Installing...';
        statusIcon = Icons.install_desktop;
        break;
      case SyncStatus.completed:
        statusText = 'Update completed!';
        statusIcon = Icons.check_circle;
        break;
      case SyncStatus.error:
        statusText = 'Update failed';
        statusIcon = Icons.error;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(statusIcon, size: 20, color: AppColors.primary),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_syncStatus == SyncStatus.downloading) ...[
                  const Gap(8),
                  LinearProgressIndicator(
                    value: _syncProgress,
                    backgroundColor: Colors.grey.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Gradient gradient,
  }) {
    final isEnabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.defaultPadding,
          ),
          decoration: BoxDecoration(
            gradient: isEnabled
                ? gradient
                : LinearGradient(
                    colors: [
                      Colors.grey.withValues(alpha: 0.3),
                      Colors.grey.withValues(alpha: 0.3),
                    ],
                  ),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isEnabled ? Colors.white : Colors.grey,
                size: 20,
              ),
              const Gap(8),
              Text(
                label,
                style: TextStyle(
                  color: isEnabled ? Colors.white : Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

