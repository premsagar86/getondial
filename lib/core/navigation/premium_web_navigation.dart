import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/cart_provider.dart';
import '../theme/premium_theme.dart';
import '../util/global_keyboard_scroll_handler.dart';
import '../../shared/widgets/social_media_section.dart';

/// Premium Web-Style Navigation Bar (Desktop)
class PremiumWebNavBar extends ConsumerStatefulWidget {
  const PremiumWebNavBar({super.key});

  @override
  ConsumerState<PremiumWebNavBar> createState() => _PremiumWebNavBarState();
}

class _PremiumWebNavBarState extends ConsumerState<PremiumWebNavBar> {
  String? _hoveredItem;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final cartCount = ref.watch(cartItemCountProvider);

    final width = MediaQuery.of(context).size.width;
    final showCompact = width < 1100;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: PremiumTheme.pureWhite.withValues(alpha: 0.9),
            border: Border(
              bottom: BorderSide(
                color: PremiumTheme.lightGrey.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Row(
              children: [
                _buildLogo(),
                const Spacer(),
                if (!showCompact) ...[
                  _buildNavLink('Home', '/', currentPath),
                  const SizedBox(width: 32),
                  _buildNavLink('Partners', '/vendors', currentPath),
                  const SizedBox(width: 32),
                  _buildNavLink('About', '/about', currentPath),
                  const SizedBox(width: 32),
                  _buildSearchButton(),
                  const SizedBox(width: 16),
                  _buildGetTheAppButton(),
                  const SizedBox(width: 16),
                  _buildCTAButton(),
                  const SizedBox(width: 16),
                  _buildQuickAction(
                    Icons.phone_in_talk,
                    'Call',
                    'tel:+918688882233',
                  ),
                  const SizedBox(width: 12),
                  _buildQuickAction(
                    Icons.email_outlined,
                    'Mail',
                    'mailto:info@getondial.com',
                  ),
                  const SizedBox(width: 16),
                  _buildCartButton(cartCount),
                ] else
                  Row(
                    children: [
                      _buildSearchButton(),
                      const SizedBox(width: 8),
                      _buildMenuButton(currentPath),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/'),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: PremiumTheme.redGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  'assets/image/logoo.png', // make sure the filename matches exactly
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'GET ON DIAL',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: PremiumTheme.darkBlack,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavLink(String label, String path, String currentPath) {
    final isActive = currentPath == path;
    final isHovered = _hoveredItem == label;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredItem = label),
      onExit: (_) => setState(() => _hoveredItem = null),
      child: GestureDetector(
        onTap: () => context.go(path),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    isActive
                        ? PremiumTheme.primaryRed
                        : (isHovered
                            ? PremiumTheme.primaryRed.withValues(alpha: 0.3)
                            : Colors.transparent),
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              color:
                  isActive
                      ? PremiumTheme.primaryRed
                      : (isHovered
                          ? PremiumTheme.darkBlack
                          : PremiumTheme.darkGrey),
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    final isSearchActive = GoRouterState.of(context).uri.path == '/search';
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/search'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSearchActive
                ? PremiumTheme.primaryRed.withValues(alpha: 0.1)
                : PremiumTheme.lightGrey,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSearchActive
                  ? PremiumTheme.primaryRed
                  : PremiumTheme.lightGrey,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                size: 18,
                color: isSearchActive
                    ? PremiumTheme.primaryRed
                    : PremiumTheme.mediumGrey,
              ),
              const SizedBox(width: 8),
              Text(
                'Search',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSearchActive
                      ? PremiumTheme.primaryRed
                      : PremiumTheme.darkGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGetTheAppButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _launchAppInstaller,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: PremiumTheme.pureWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: PremiumTheme.primaryRed.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Text(
                'Get the App',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: PremiumTheme.primaryRed,
                ),
              ),
              const SizedBox(width: 8),
              Transform.rotate(
                angle: -0.1,
                child: Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: PremiumTheme.primaryRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchAppInstaller() {
    final appUrl = _getPlatformStoreUrl();
    if (appUrl != null) {
      _launchExternal(appUrl);
    }
  }

  String? _getPlatformStoreUrl() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'https://apps.apple.com/in/app/get-on-dial/id6476094551';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'https://play.google.com/store/apps/details?id=com.getondial.app&pcampaignid=web_share';
    }
    return 'https://play.google.com/store/apps/details?id=com.getondial.app&pcampaignid=web_share';
  }

  Widget _buildCTAButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/contact'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            gradient: PremiumTheme.redGradient,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: PremiumTheme.primaryRed.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: PremiumTheme.pureWhite,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_forward,
                color: PremiumTheme.pureWhite,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String tooltip, String url) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => _launchExternal(url),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: PremiumTheme.primaryRed.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: PremiumTheme.primaryRed.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(icon, size: 18, color: PremiumTheme.primaryRed),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String currentPath) {
    return IconButton(
      icon: const Icon(
        Icons.menu_rounded,
        size: 28,
        color: PremiumTheme.darkBlack,
      ),
      onPressed: () => _openNavSheet(currentPath),
    );
  }

  Widget _buildCartButton(int cartCount) {
    return GestureDetector(
      onTap: () => context.go('/cart'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: PremiumTheme.lightGrey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 18,
                  color: PremiumTheme.darkBlack,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cart',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: PremiumTheme.darkGrey,
                  ),
                ),
              ],
            ),
          ),
          if (cartCount > 0)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: PremiumTheme.primaryRed,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  cartCount > 99 ? '99+' : '$cartCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openNavSheet(String currentPath) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Links',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _SheetLink(label: 'Home', path: '/', currentPath: currentPath),
                _SheetLink(
                  label: 'Partners',
                  path: '/vendors',
                  currentPath: currentPath,
                ),
                _SheetLink(
                  label: 'About',
                  path: '/about',
                  currentPath: currentPath,
                ),
                _SheetLink(
                  label: 'Search',
                  path: '/search',
                  currentPath: currentPath,
                ),
                const Divider(height: 32),
                Text('Contact', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildQuickAction(
                      Icons.phone_in_talk,
                      'Call',
                      'tel:+918688882233',
                    ),
                    _buildQuickAction(
                      Icons.email_outlined,
                      'Mail',
                      'mailto:info@getondial.com',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    this.context.go('/contact');
                  },
                  child: const Text('Contact Us'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Premium Mobile Navigation (Bottom Nav)
class PremiumMobileNav extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PremiumMobileNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);

    return Container(
      decoration: BoxDecoration(
        color: PremiumTheme.pureWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: PremiumTheme.primaryRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'GBC',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: PremiumTheme.primaryRed,
                  ),
                ),
              ),
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.storefront_rounded, 'Partners'),
              _buildNavItem(2, Icons.info_rounded, 'About'),
              _buildNavItem(3, Icons.mail_rounded, 'Contact'),
              _buildCartNavItem(context, cartCount),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isActive
                  ? PremiumTheme.primaryRed.withValues(alpha: 0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isActive ? PremiumTheme.primaryRed : PremiumTheme.mediumGrey,
                  size: 22,
                ),
                if (index == 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: PremiumTheme.primaryRed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'GBC',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: PremiumTheme.primaryRed,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color:
                    isActive
                        ? PremiumTheme.primaryRed
                        : PremiumTheme.mediumGrey,
              ),
            ),
            SizedBox(height: isActive ? 2 : 0),
            if (isActive)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: PremiumTheme.primaryRed,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartNavItem(BuildContext context, int cartCount) {
    return GestureDetector(
      onTap: () => context.go('/cart'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: PremiumTheme.lightGrey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: PremiumTheme.darkBlack,
                  size: 22,
                ),
                const SizedBox(height: 2),
                Text(
                  'Cart',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: PremiumTheme.darkGrey,
                  ),
                ),
              ],
            ),
          ),
          if (cartCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: PremiumTheme.primaryRed,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  cartCount > 99 ? '99+' : '$cartCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Premium Tablet Navigation (Side Rail)
class PremiumTabletNav extends ConsumerStatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PremiumTabletNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  ConsumerState<PremiumTabletNav> createState() => _PremiumTabletNavState();
}

class _PremiumTabletNavState extends ConsumerState<PremiumTabletNav> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartItemCountProvider);

    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: PremiumTheme.pureWhite,
        border: Border(
          right: BorderSide(color: PremiumTheme.lightGrey, width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: PremiumTheme.redGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business_center,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(height: 48),

          // Nav Items
          _buildRailItem(0, Icons.home_rounded, 'Home'),
          _buildRailItem(1, Icons.storefront_rounded, 'Partners'),
          _buildRailItem(2, Icons.info_rounded, 'About'),
          _buildRailItem(3, Icons.mail_rounded, 'Contact'),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => context.go('/cart'),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: PremiumTheme.primaryRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: PremiumTheme.primaryRed,
                      size: 28,
                    ),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: PremiumTheme.primaryRed,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cartCount > 99 ? '99+' : '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRailItem(int index, IconData icon, String tooltip) {
    final isActive = widget.currentIndex == index;
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: () => widget.onTap(index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isActive
                      ? PremiumTheme.primaryRed.withValues(alpha: 0.1)
                      : (isHovered
                          ? PremiumTheme.lightGrey
                          : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color:
                      isActive ? PremiumTheme.primaryRed : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Icon(
              icon,
              color:
                  isActive ? PremiumTheme.primaryRed : PremiumTheme.mediumGrey,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

/// Adaptive Scaffold with Premium Navigation
class PremiumAdaptiveScaffold extends StatefulWidget {
  final Widget child;

  const PremiumAdaptiveScaffold({super.key, required this.child});

  @override
  State<PremiumAdaptiveScaffold> createState() =>
      _PremiumAdaptiveScaffoldState();
}

class _PremiumAdaptiveScaffoldState extends State<PremiumAdaptiveScaffold> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/vendors');
        break;
      case 2:
        context.go('/about');
        break;
      case 3:
        context.go('/contact');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600 && size.width < 1024;
    final isDesktop = size.width >= 1024;

    // Update current index based on route
    final currentPath = GoRouterState.of(context).uri.path;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newIndex = _getIndexFromPath(currentPath);
      if (newIndex != _currentIndex) {
        setState(() => _currentIndex = newIndex);
      }
    });

    if (isDesktop) {
      // Desktop: Top Navigation Bar with Footer
      return Scaffold(
        body: GlobalKeyboardScrollWrapper(
          child: Column(
            children: [
              const PremiumWebNavBar(),
              Expanded(child: widget.child),
              _buildFooter(),
            ],
          ),
        ),
      );
    } else if (isTablet) {
      // Tablet: Side Rail
      return Scaffold(
        body: GlobalKeyboardScrollWrapper(
          child: Row(
            children: [
              PremiumTabletNav(currentIndex: _currentIndex, onTap: _onNavTap),
              Expanded(child: widget.child),
            ],
          ),
        ),
      );
    } else {
      // Mobile: Bottom Navigation
      return Scaffold(
        body: GlobalKeyboardScrollWrapper(child: widget.child),
        bottomNavigationBar: PremiumMobileNav(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
        ),
      );
    }
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      decoration: BoxDecoration(
        color: PremiumTheme.pureWhite,
        border: Border(
          top: BorderSide(
            color: PremiumTheme.lightGrey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '© ${DateTime.now().year} Get On Dial. All rights reserved.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SocialMediaSection(
            showTitle: false,
            compact: true,
            horizontal: true,
          ),
        ],
      ),
    );
  }

  int _getIndexFromPath(String path) {
    if (path == '/') return 0;
    if (path.startsWith('/vendors')) return 1;
    if (path.startsWith('/about')) return 2;
    if (path.startsWith('/contact')) return 3;
    return 0;
  }
}

Future<void> _launchExternal(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    debugPrint('Could not launch $url');
  }
}

class _SheetLink extends StatelessWidget {
  final String label;
  final String path;
  final String currentPath;
  const _SheetLink({
    required this.label,
    required this.path,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final isActive = currentPath == path;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 0,
      onTap: () {
        Navigator.of(context).pop();
        router.go(path);
      },
      leading: Icon(
        Icons.circle,
        size: 10,
        color: isActive ? PremiumTheme.primaryRed : Colors.grey.shade400,
      ),
      title: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: PremiumTheme.darkBlack),
      ),
    );
  }
}
