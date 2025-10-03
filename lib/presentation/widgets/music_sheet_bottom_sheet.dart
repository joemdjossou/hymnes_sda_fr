import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../shared/constants/app_colors.dart';

/// Widget responsible for displaying music sheet PDFs in a web view
/// Follows Single Responsibility Principle and Open/Closed Principle
class MusicSheetBottomSheet extends StatefulWidget {
  final List<String> pdfUrls;
  final String hymnTitle;
  final String hymnNumber;

  const MusicSheetBottomSheet({
    super.key,
    required this.pdfUrls,
    required this.hymnTitle,
    required this.hymnNumber,
  });

  /// Static method to show the bottom sheet
  /// Follows Open/Closed Principle - can be extended without modification
  static void show(
    BuildContext context, {
    required List<String> pdfUrls,
    required String hymnTitle,
    required String hymnNumber,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MusicSheetBottomSheet(
        pdfUrls: pdfUrls,
        hymnTitle: hymnTitle,
        hymnNumber: hymnNumber,
      ),
    );
  }

  @override
  State<MusicSheetBottomSheet> createState() => _MusicSheetBottomSheetState();
}

class _MusicSheetBottomSheetState extends State<MusicSheetBottomSheet>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<WebViewController> _controllers = [];
  bool _isLoading = true;
  bool _hasWebViewError = false;
  String? _errorMessage;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.pdfUrls.length,
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controllersInitialized) {
      _initializeControllers();
      _controllersInitialized = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    final l10n = AppLocalizations.of(context)!;
    for (int i = 0; i < widget.pdfUrls.length; i++) {
      try {
        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                    _hasWebViewError = false;
                    _errorMessage = null;
                  });
                }
              },
              onPageFinished: (String url) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _hasWebViewError = false;
                  });
                }
              },
              onWebResourceError: (WebResourceError error) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _hasWebViewError = true;
                    _errorMessage = l10n.failedToLoadPdf;
                  });
                }
              },
            ),
          );

        // Load the PDF with a timeout
        _loadPdfWithTimeout(controller, widget.pdfUrls[i]);
        _controllers.add(controller);
      } catch (e) {
        if (mounted) {
          setState(() {
            _hasWebViewError = true;
            _errorMessage = 'WebView initialization failed: $e';
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _loadPdfWithTimeout(
      WebViewController controller, String url) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await controller.loadRequest(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (mounted) {
            setState(() {
              _hasWebViewError = true;
              _errorMessage = l10n.pdfLoadingTimeout;
              _isLoading = false;
            });
          }
          throw TimeoutException(
              'PDF loading timeout', const Duration(seconds: 10));
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasWebViewError = true;
          _errorMessage = l10n.failedToLoadPdf;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openInBrowser(String url) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.cannotOpenPdfInBrowser),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOpeningPdf(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
          _buildHeader(l10n),
          // Tab bar (if multiple PDFs)
          if (widget.pdfUrls.length > 1) _buildTabBar(),
          // Content
          Expanded(
            child: widget.pdfUrls.length == 1
                ? _buildSingleWebView(0)
                : _buildTabBarView(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.music_note,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.hymnNumber(widget.hymnNumber)} - Music Sheet',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.hymnTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: List.generate(
          widget.pdfUrls.length,
          (index) => Tab(
            text: 'Sheet ${index + 1}',
            icon: const Icon(Icons.picture_as_pdf, size: 16),
          ),
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary(context),
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: List.generate(
        widget.pdfUrls.length,
        (index) => _buildSingleWebView(index),
      ),
    );
  }

  Widget _buildSingleWebView(int index) {
    final currentUrl = widget.pdfUrls[index];
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (!_hasWebViewError && _controllers.isNotEmpty)
              WebViewWidget(controller: _controllers[index])
            else
              _buildErrorState(context, currentUrl),
            if (_isLoading && !_hasWebViewError)
              Container(
                color: AppColors.cardBackground(context),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.loadingMusicSheet,
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String url) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: AppColors.cardBackground(context),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.unableToDisplayPdf,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? l10n.webViewFailedToLoad,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _openInBrowser(url),
                icon: const Icon(Icons.open_in_browser),
                label: Text(l10n.openInBrowser),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _hasWebViewError = false;
                    _isLoading = true;
                  });
                  _initializeControllers();
                },
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
