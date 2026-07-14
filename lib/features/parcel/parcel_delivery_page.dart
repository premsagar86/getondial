import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/responsive/responsive_breakpoints.dart';
import '../../core/util/global_keyboard_scroll_handler.dart';

class ParcelDeliveryPage extends StatefulWidget {
  const ParcelDeliveryPage({super.key});

  @override
  State<ParcelDeliveryPage> createState() => _ParcelDeliveryPageState();
}

class _ParcelDeliveryPageState extends State<ParcelDeliveryPage> {
  final ScrollController _scrollController = ScrollController();
  static const double _scrollStep = 100.0;

  @override
  void initState() {
    super.initState();
    _setupKeyboardNavigation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Clean up keyboard handlers
    KeyboardController.onUp = null;
    KeyboardController.onDown = null;
    KeyboardController.onLeft = null;
    KeyboardController.onRight = null;
    super.dispose();
  }

  void _setupKeyboardNavigation() {
    KeyboardController.onUp = () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          (_scrollController.offset - _scrollStep).clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    };

    KeyboardController.onDown = () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          (_scrollController.offset + _scrollStep).clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    };

    KeyboardController.onLeft = () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          (_scrollController.offset - _scrollStep).clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    };

    KeyboardController.onRight = () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          (_scrollController.offset + _scrollStep).clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    };
  }

  Future<void> _launchUri(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final padding = ResponsiveBreakpoints.getHorizontalPadding(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.brandBlack),
          onPressed: () {
            // Try GoRouter pop first
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // Fallback to home page
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: PrimaryScrollController(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: isMobile ? 20 : 40,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Main Content
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isMobile ? double.infinity : 600,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon/Illustration
                      Container(
                        width: isMobile ? 120 : 160,
                        height: isMobile ? 120 : 160,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.brandRed,
                              AppTheme.brandRed.withValues(alpha: 0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.brandRed.withValues(alpha: 0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_shipping_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isMobile ? 32 : 48),

                      // Title
                      Text(
                        'Parcel Delivery',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: isMobile ? 32 : 48,
                              color: AppTheme.brandBlack,
                              letterSpacing: -0.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isMobile ? 16 : 24),

                      // Message
                      Container(
                        padding: EdgeInsets.all(isMobile ? 24 : 32),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: isMobile ? 32 : 40,
                              color: AppTheme.brandRed,
                            ),
                            SizedBox(height: isMobile ? 16 : 20),
                            Text(
                              'Parcel delivery is currently available in the application',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: isMobile ? 18 : 22,
                                    color: AppTheme.brandBlack,
                                    height: 1.5,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isMobile ? 12 : 16),
                            Text(
                              'Download the GET ON DIAL app to access parcel delivery services and more.',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: isMobile ? 14 : 16,
                                    height: 1.6,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isMobile ? 40 : 56),

                      // App Store Buttons
                      Text(
                        'Download Now',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: isMobile ? 16 : 18,
                              color: Colors.grey[700],
                            ),
                      ),
                      SizedBox(height: isMobile ? 20 : 28),

                      Wrap(
                        spacing: isMobile ? 16 : 20,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _AppStoreButton(
                            label: 'App Store',
                            icon: Icons.apple,
                            onTap: () => _launchUri(
                              'https://apps.apple.com/in/app/get-on-dial/id6476094551',
                            ),
                            isMobile: isMobile,
                          ),
                          _AppStoreButton(
                            label: 'Play Store',
                            icon: Icons.android,
                            onTap: () => _launchUri(
                              'https://play.google.com/store/apps/details?id=com.getondial.app&pcampaignid=web_share',
                            ),
                            isMobile: isMobile,
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 40 : 60),

                      // Features List
                      Container(
                        padding: EdgeInsets.all(isMobile ? 20 : 28),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.brandRed.withValues(alpha: 0.05),
                              Colors.white,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.brandRed.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'What you can do:',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: isMobile ? 16 : 18,
                                  ),
                            ),
                            SizedBox(height: isMobile ? 16 : 20),
                            _FeatureItem(
                              icon: Icons.send_rounded,
                              text: 'Send parcels anywhere',
                              isMobile: isMobile,
                            ),
                            SizedBox(height: 12),
                            _FeatureItem(
                              icon: Icons.track_changes_rounded,
                              text: 'Track deliveries in real-time',
                              isMobile: isMobile,
                            ),
                            SizedBox(height: 12),
                            _FeatureItem(
                              icon: Icons.schedule_rounded,
                              text: 'Schedule pickups and deliveries',
                              isMobile: isMobile,
                            ),
                            SizedBox(height: 12),
                            _FeatureItem(
                              icon: Icons.payment_rounded,
                              text: 'Secure payment options',
                              isMobile: isMobile,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _AppStoreButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isMobile;

  const _AppStoreButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isMobile,
  });

  @override
  State<_AppStoreButton> createState() => _AppStoreButtonState();
}

class _AppStoreButtonState extends State<_AppStoreButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isMobile ? 24 : 32,
            vertical: widget.isMobile ? 14 : 18,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? AppTheme.brandRed
                  : Colors.grey[300]!,
              width: _isHovered ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppTheme.brandRed.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          transform: Matrix4.identity()
            ..translate(0, _isHovered ? -4 : 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: widget.isMobile ? 24 : 28,
                color: AppTheme.brandBlack,
              ),
              SizedBox(width: widget.isMobile ? 12 : 16),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: widget.isMobile ? 16 : 18,
                      color: AppTheme.brandBlack,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isMobile;

  const _FeatureItem({
    required this.icon,
    required this.text,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.brandRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: isMobile ? 18 : 20,
            color: AppTheme.brandRed,
          ),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.grey[700],
                ),
          ),
        ),
      ],
    );
  }
}

