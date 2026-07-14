import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/responsive/responsive_breakpoints.dart';
import '../../core/theme/premium_theme.dart';
import '../../core/models/vendor_detail_model.dart';
import '../../core/models/review_model.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/util/global_keyboard_scroll_handler.dart';
import '../../core/models/product_model.dart';
import '../../shared/widgets/network_circle_avatar.dart';

class VendorDetailPage extends ConsumerStatefulWidget {
  final String vendorId;
  final int? moduleId;

  const VendorDetailPage({super.key, required this.vendorId, this.moduleId});

  @override
  ConsumerState<VendorDetailPage> createState() => _VendorDetailPageState();
}

class _VendorDetailPageState extends ConsumerState<VendorDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _itemsMode = 'latest';
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _reviewNameCtrl = TextEditingController();
  final TextEditingController _reviewPhoneCtrl = TextEditingController();
  final TextEditingController _reviewEmailCtrl = TextEditingController();
  final TextEditingController _reviewMessageCtrl = TextEditingController();
  final GlobalKey<FormState> _reviewFormKey = GlobalKey<FormState>();
  int _reviewRating = 0;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _keyboardFocusNode = FocusNode();
  static const double _scrollStep = 100.0;
  Timer? _productSearchDebounce;

  Timer? _scrollTimer;
  LogicalKeyboardKey? _pressedKey;
  static const Duration _initialScrollDelay = Duration(milliseconds: 300);
  static const Duration _continuousScrollInterval = Duration(milliseconds: 50);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setupKeyboardNavigation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _requestFocusWithRetry();
      }
    });
  }

  void _requestFocusWithRetry({int retries = 3}) {
    if (!mounted) return;

    if (_keyboardFocusNode.canRequestFocus) {
      _keyboardFocusNode.requestFocus();
    }

    if (retries > 0 && !_keyboardFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _requestFocusWithRetry(retries: retries - 1);
        }
      });
    }
  }

  @override
  void dispose() {
    _productSearchDebounce?.cancel();
    _stopContinuousScroll();
    _tabController.dispose();
    _searchCtrl.dispose();
    _scrollController.dispose();
    _keyboardFocusNode.dispose();
    KeyboardController.onUp = null;
    KeyboardController.onDown = null;
    KeyboardController.onLeft = null;
    KeyboardController.onRight = null;
    super.dispose();
  }

  void _stopContinuousScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
    _pressedKey = null;
  }

  void _startContinuousScroll(LogicalKeyboardKey key, double scrollDelta) {
    _stopContinuousScroll();
    _pressedKey = key;

    _performScroll(scrollDelta);

    _scrollTimer = Timer(_initialScrollDelay, () {
      if (_pressedKey == key && mounted) {
        _scrollTimer = Timer.periodic(_continuousScrollInterval, (timer) {
          if (_pressedKey != key || !mounted) {
            timer.cancel();
            _stopContinuousScroll();
            return;
          }
          _performScroll(scrollDelta);
        });
      }
    });
  }

  void _performScroll(double scrollDelta) {
    if (!mounted || !_scrollController.hasClients) return;
    if (!_scrollController.position.hasContentDimensions) return;

    final newOffset = (_scrollController.offset + scrollDelta).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    if (newOffset != _scrollController.offset) {
      _scrollController.jumpTo(newOffset);
    } else {
      _stopContinuousScroll();
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _startContinuousScroll(LogicalKeyboardKey.arrowUp, -_scrollStep);
        KeyboardController.up();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _startContinuousScroll(LogicalKeyboardKey.arrowDown, _scrollStep);
        KeyboardController.down();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _startContinuousScroll(LogicalKeyboardKey.arrowLeft, -_scrollStep);
        KeyboardController.left();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _startContinuousScroll(LogicalKeyboardKey.arrowRight, _scrollStep);
        KeyboardController.right();
        return KeyEventResult.handled;
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (_pressedKey == event.logicalKey) {
          _stopContinuousScroll();
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _setupKeyboardNavigation() {
    KeyboardController.onUp = () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients &&
            _scrollController.position.hasContentDimensions) {
          final newOffset = (_scrollController.offset - _scrollStep).clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          );
          if (newOffset != _scrollController.offset) {
            _scrollController.animateTo(
              newOffset,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      });
    };

    KeyboardController.onDown = () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients &&
            _scrollController.position.hasContentDimensions) {
          final newOffset = (_scrollController.offset + _scrollStep).clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          );
          if (newOffset != _scrollController.offset) {
            _scrollController.animateTo(
              newOffset,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      });
    };

    KeyboardController.onLeft = () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients &&
            _scrollController.position.hasContentDimensions) {
          final newOffset = (_scrollController.offset - _scrollStep).clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          );
          if (newOffset != _scrollController.offset) {
            _scrollController.animateTo(
              newOffset,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      });
    };

    KeyboardController.onRight = () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients &&
            _scrollController.position.hasContentDimensions) {
          final newOffset = (_scrollController.offset + _scrollStep).clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          );
          if (newOffset != _scrollController.offset) {
            _scrollController.animateTo(
              newOffset,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      });
    };
  }

  String _createSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }

  String _buildVendorShareUrl(VendorDetailModel vendor) {
    final slug = _createSlug(vendor.name);
    final moduleId = widget.moduleId ?? 1;
    return "https://getondial.com/#/vendor/${vendor.id}?moduleId=$moduleId&slug=$slug";
  }

  Future<void> _shareVendorLink(VendorDetailModel vendor) async {
    final url = _buildVendorShareUrl(vendor);
    final text = "Check out ${vendor.name} on GetOnDial:\n$url";
    await Share.share(text, subject: vendor.name);
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveBreakpoints.getHorizontalPadding(context);
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final double tabHeight =
        isMobile ? MediaQuery.of(context).size.height * 0.85 : 820.0;

    final detailAsync = ref.watch(
      vendorDetailProvider(
        VendorDetailArgs(id: widget.vendorId, moduleId: widget.moduleId),
      ),
    );

    return detailAsync.when(
      loading: () => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    AlwaysStoppedAnimation<Color>(PremiumTheme.primaryRed),
              ),
              const SizedBox(height: 24),
              Text(
                'Loading vendor details...',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
      error: (e, stackTrace) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: PremiumTheme.darkBlack,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading vendor details',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please check your connection and try again.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(
                      vendorDetailProvider(
                        VendorDetailArgs(
                          id: widget.vendorId,
                          moduleId: widget.moduleId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PremiumTheme.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (vendor) {
        if (vendor == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: PremiumTheme.darkBlack,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Vendor not found',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The vendor details could not be loaded. This vendor may not exist or may have been removed.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Go Back'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PremiumTheme.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Focus(
          focusNode: _keyboardFocusNode,
          autofocus: true,
          canRequestFocus: true,
          skipTraversal: false,
          onKeyEvent: _handleKeyEvent,
          child: GestureDetector(
            onTap: () {
              if (!_keyboardFocusNode.hasFocus && mounted) {
                _keyboardFocusNode.requestFocus();
              }
            },
            behavior: HitTestBehavior.translucent,
            child: Scaffold(
              body: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _buildHeroHeader(vendor, isMobile),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          children: [
                            const SizedBox(height: 28),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: padding),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isDesktop ? 1200 : double.infinity,
                                ),
                                child: _buildBodySections(
                                  context: context,
                                  vendor: vendor,
                                  isMobile: isMobile,
                                  tabHeight: tabHeight,
                                ),
                              ),
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBodySections({
    required BuildContext context,
    required VendorDetailModel vendor,
    required bool isMobile,
    required double tabHeight,
  }) {
    final isWide = MediaQuery.of(context).size.width >= 960;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildHighlightsSection(vendor, isMobile),
              ),
              const SizedBox(width: 32),
              Expanded(flex: 2, child: _buildGalleryStrip(context, vendor)),
            ],
          )
        else ...[
          _buildGalleryStrip(context, vendor),
          const SizedBox(height: 20),
          _buildHighlightsSection(vendor, isMobile),
        ],
        const SizedBox(height: 28),
        _buildTabBar(),
        const SizedBox(height: 20),
        SizedBox(
          height: tabHeight,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildProductsTabSection(vendor, isMobile),
              _buildAboutTab(vendor, isMobile),
              _buildReviewsTab(vendor.reviews, isMobile),
            ],
          ),
        ),
      ],
    );
  }

  bool _hasValidImage(String? url) {
    if (url == null) return false;
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    final lower = trimmed.toLowerCase();
    return lower != 'null' && lower != 'undefined';
  }

  Widget _buildHeroHeader(VendorDetailModel vendor, bool isMobile) {
    return SliverAppBar(
      expandedHeight: isMobile ? 540 : 580,
      pinned: true,
      stretch: true,
      backgroundColor: PremiumTheme.darkBlack,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.fadeTitle, StretchMode.zoomBackground],
        background: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final isMobileBg = w < 720;
            final logoUrl = _hasValidImage(vendor.logoUrl)
                ? vendor.logoUrl.trim()
                : 'https://dummyimage.com/400x400/ffffff/000000&text=Store';

            return Container(
              color: PremiumTheme.darkBlack,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: CustomPaint(
                      size: Size(w * 0.55, h * 0.45),
                      painter: _TopRightAccentPainter(),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: CustomPaint(
                      size: Size(w * 0.55, h * 0.35),
                      painter: _BottomLeftAccentPainter(),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: h * 0.28,
                    child: CustomPaint(
                      size: Size(w * 0.15, h * 0.48),
                      painter: _RightStripeAccentPainter(),
                    ),
                  ),
                  Positioned.fill(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobileBg ? 22 : 44,
                        ),
                        child: _buildBusinessCardContent(
                          vendor: vendor,
                          isMobile: isMobileBg,
                          logoUrl: logoUrl,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static const _ts = [
    Shadow(color: Color(0xBB000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  Widget _buildBusinessCardContent({
    required VendorDetailModel vendor,
    required bool isMobile,
    required String logoUrl,
  }) {
    final double titleSize = isMobile ? 22 : 30;
    final double subTitleSize = isMobile ? 15 : 18;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: isMobile ? 28 : 36),

        Container(
          width: isMobile ? 110 : 140,
          height: isMobile ? 68 : 84,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: logoUrl,
              fit: BoxFit.contain,
              memCacheWidth: 280,
              memCacheHeight: 168,
              placeholder: (_, __) =>
                  const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              errorWidget: (_, __, ___) => Icon(
                Icons.storefront_rounded,
                size: isMobile ? 30 : 38,
                color: PremiumTheme.darkGrey,
              ),
            ),
          ),
        ),

        SizedBox(height: isMobile ? 14 : 18),

        Text(
          vendor.name.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
            height: 1.2,
            shadows: _ts,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 6),

        Text(
          vendor.shortDescription.isNotEmpty
              ? vendor.shortDescription
              : vendor.name,
          style: TextStyle(
            color: Colors.white.withOpacity(0.92),
            fontSize: subTitleSize,
            fontWeight: FontWeight.w600,
            height: 1.35,
            shadows: _ts,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: isMobile ? 16 : 20),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildActionPill(
              icon: Icons.phone,
              label: 'Call',
              color: const Color(0xFF4CAF50),
              onTap: () => _launchPhone(vendor.phone),
            ),
            _buildActionPill(
              icon: Icons.chat_rounded,
              label: 'WhatsApp',
              color: const Color(0xFF25D366),
              onTap: () => _shareWhatsApp(vendor),
            ),
            _buildActionPill(
              icon: Icons.location_on,
              label: 'Location',
              color: PremiumTheme.primaryRed,
              onTap: () => _openInGoogleMaps(vendor),
            ),
            _buildActionPill(
              icon: Icons.mail,
              label: 'Mail',
              color: PremiumTheme.primaryRed,
              onTap: () => _launchEmail(vendor.email),
            ),
            _buildActionPill(
              icon: Icons.share,
              label: 'Share',
              color: Colors.white,
              onTap: () => _showShareSheet(context, vendor),
            ),
          ],
        ),

        SizedBox(height: isMobile ? 18 : 22),

        _buildInfoRow(
          icon: Icons.location_on,
          text: vendor.address.isNotEmpty ? vendor.address : vendor.location,
          maxLines: 3,
        ),
        const SizedBox(height: 10),
        _buildInfoRow(
          icon: Icons.mail,
          text: vendor.email,
          onTap: () => _launchEmail(vendor.email),
        ),
        const SizedBox(height: 10),
        if (vendor.website.isNotEmpty)
          _buildInfoRow(
            icon: Icons.language,
            text: vendor.website,
            onTap: () => _launchWebsite(vendor.website),
          ),

        SizedBox(height: isMobile ? 18 : 22),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: isMobile ? 160 : 190,
              child: _bottomBtn(
                icon: Icons.person_add_alt_1,
                label: 'Add to Phone Book',
                filled: false,
                onTap: () => _launchPhone(vendor.phone),
              ),
            ),
            SizedBox(
              width: isMobile ? 140 : 170,
              child: _bottomBtn(
                icon: Icons.bookmark,
                label: 'Save Card',
                filled: true,
                onTap: () => _showShareSheet(context, vendor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _bottomBtn({
    required IconData icon,
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: filled
                ? PremiumTheme.primaryRed
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
            border: filled ? null : Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    shadows: _ts,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  shadows: _ts,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment:
              maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: PremiumTheme.primaryRed,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: PremiumTheme.primaryRed.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                  shadows: _ts,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context, VendorDetailModel vendor) {
    final url = _buildVendorShareUrl(vendor);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Share Vendor Link",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                vendor.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, width: 1.5),
                  color: Colors.grey[50],
                ),
                child: SelectableText(
                  url,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: url));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("URL copied to clipboard!"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text("Copy URL"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PremiumTheme.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _shareVendorLink(vendor);
                      },
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text("Share"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PremiumTheme.primaryRed,
                        side: const BorderSide(
                          color: PremiumTheme.primaryRed,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _shareWhatsApp(vendor);
                  },
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text("Share on WhatsApp"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareWhatsApp(VendorDetailModel vendor) async {
    final whatsappPhone = vendor.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final url = _buildVendorShareUrl(vendor);
    final message = "Check out ${vendor.name} on GetOnDial:\n$url";

    final whatsappMobile = Uri.parse(
      whatsappPhone.isNotEmpty
          ? "whatsapp://send?phone=$whatsappPhone&text=${Uri.encodeComponent(message)}"
          : "whatsapp://send?text=${Uri.encodeComponent(message)}",
    );

    final whatsappWeb = Uri.parse(
      whatsappPhone.isNotEmpty
          ? "https://wa.me/$whatsappPhone?text=${Uri.encodeComponent(message)}"
          : "https://wa.me/?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(whatsappMobile)) {
      await launchUrl(whatsappMobile, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(whatsappWeb, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openInGoogleMaps(VendorDetailModel vendor) async {
    final query =
        (vendor.address.isNotEmpty ? vendor.address : vendor.location).trim();
    if (query.isEmpty) return;

    final encoded = Uri.encodeComponent(query);
    final googleMapsApp = Uri.parse('comgooglemaps://?q=$encoded');
    final googleMapsWeb = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encoded',
    );

    if (await canLaunchUrl(googleMapsApp)) {
      await launchUrl(googleMapsApp, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(googleMapsWeb, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildGalleryStrip(BuildContext context, VendorDetailModel vendor) {
    final images = vendor.gallery.take(4).toList();
    if (images.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gallery & Coverage',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return _GalleryImageCard(imageUrl: images[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightsSection(VendorDetailModel vendor, bool isMobile) {
    final amenities = vendor.amenities.take(6).toList();
    if (amenities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: -0.5,
                color: Colors.grey[900],
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: amenities
              .map(
                (a) => _HighlightChip(
                  label: a,
                  icon: Icons.check_circle_rounded,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Future<void> _launchPhone(String phone) async {
    final sanitized = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(
      scheme: 'tel',
      path: sanitized.isNotEmpty ? sanitized : phone,
    );
    await _launchUri(uri);
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    await _launchUri(uri);
  }

  Future<void> _launchWebsite(String url) async {
    final normalized = url.startsWith('http') ? url : 'https://$url';
    await _launchUri(Uri.parse(normalized));
  }

  Future<void> _launchUri(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: PremiumTheme.primaryRed,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: PremiumTheme.primaryRed,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        tabs: const [
          Tab(text: 'Products'),
          Tab(text: 'About'),
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildProductsTabSection(VendorDetailModel vendor, bool isMobile) {
    final moduleId = widget.moduleId;
    final padding = EdgeInsets.symmetric(horizontal: isMobile ? 8 : 0);

    final itemsAsync = (_itemsMode == 'recommended')
        ? ref.watch(
            storeItemsRecommendedProvider(
              StoreItemsArgs(
                storeId: vendor.id,
                offset: 1,
                limit: 30,
                moduleId: moduleId,
              ),
            ),
          )
        : ref.watch(
            storeItemsByCategoryProvider(
              StoreItemsArgs(
                storeId: vendor.id,
                categoryId: 0,
                offset: 1,
                limit: 30,
                type: 'all',
                moduleId: moduleId,
              ),
            ),
          );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: LayoutBuilder(
              builder: (context, constraints) {
                final useColumn = constraints.maxWidth < 420;
                final toggleButtons = ToggleButtons(
                  constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  isSelected: [
                    _itemsMode == 'latest',
                    _itemsMode == 'recommended',
                  ],
                  onPressed: (i) {
                    setState(
                      () => _itemsMode = (i == 0) ? 'latest' : 'recommended',
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  selectedColor: Colors.white,
                  fillColor: PremiumTheme.primaryRed,
                  borderColor: Colors.grey[300]!,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'Latest',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'Recommended',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                );

                final searchField = Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: PremiumTheme.primaryRed,
                          width: 2.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                    onChanged: (_) {
                      _productSearchDebounce?.cancel();
                      _productSearchDebounce =
                          Timer(const Duration(milliseconds: 300), () {
                        if (mounted) setState(() {});
                      });
                    },
                  ),
                );

                if (useColumn) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      toggleButtons,
                      const SizedBox(height: 12),
                      searchField,
                    ],
                  );
                }

                return Row(
                  children: [
                    toggleButtons,
                    const SizedBox(width: 12),
                    Expanded(child: searchField),
                  ],
                );
              },
            ),
            ),
            Padding(
              padding: padding,
              child: itemsAsync.when(
                data: (items) {
                  List<ProductModel> list =
                      items.isNotEmpty ? items : vendor.products;
                  final q = _searchCtrl.text.trim().toLowerCase();
                  if (q.isNotEmpty) {
                    list = list
                        .where(
                          (p) =>
                              p.name.toLowerCase().contains(q) ||
                              p.description.toLowerCase().contains(q),
                        )
                        .toList();
                  }
                  if (list.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 80),
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No products found',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth;
                      final columns = _calculateProductColumns(maxWidth);
                      final ratio =
                          _calculateProductAspectRatio(maxWidth, columns);
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(top: isMobile ? 8 : 16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: isMobile ? 8 : 16,
                          mainAxisSpacing: isMobile ? 8 : 16,
                          childAspectRatio: ratio,
                        ),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(list[index]);
                        },
                      );
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(PremiumTheme.primaryRed),
                    ),
                  ),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Items error: $e'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateProductColumns(double width) {
    if (width >= 1400) return 4;
    if (width >= 1024) return 3;
    if (width >= 720) return 2;
    return 2;
  }

  double _calculateProductAspectRatio(double width, int columns) {
    if (columns <= 0) return 0.7;
    final totalSpacing = (columns - 1) * 16;
    final itemWidth = (width - totalSpacing) / columns;
    if (itemWidth >= 500) return 0.9;
    if (itemWidth >= 360) return 0.82;
    if (itemWidth >= 280) return 0.75;
    return 0.72;
  }

  Widget _buildProductCard(ProductModel product) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final imageAspectRatio = isMobile ? 4 / 3 : 16 / 9;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[50]!],
        ),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: PremiumTheme.primaryRed.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(aspectRatio: imageAspectRatio, child: _productImage(product)),
          _productInfo(product),
        ],
      ),
    );
  }

  Widget _productImage(ProductModel product) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: product.imageUrl,
          fit: BoxFit.cover,
          memCacheWidth: 400,
          memCacheHeight: 400,
          placeholder: (_, __) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[200]!, Colors.grey[100]!],
              ),
            ),
            child: Icon(
              Icons.image_rounded,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[200]!, Colors.grey[100]!],
              ),
            ),
            child: Icon(
              Icons.image_rounded,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _productInfo(ProductModel product) {
    final description = product.description.trim();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isVerySmall = screenWidth < 400;

    return Padding(
      padding: EdgeInsets.all(isMobile ? (isVerySmall ? 6 : 7) : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (product.category.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? (isVerySmall ? 6 : 7) : 10,
                vertical: isMobile ? 3 : 5,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PremiumTheme.primaryRed.withOpacity(0.15),
                    PremiumTheme.primaryRed.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: PremiumTheme.primaryRed.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                product.category,
                style: TextStyle(
                  fontSize: isMobile ? (isVerySmall ? 9 : 10) : 11,
                  fontWeight: FontWeight.w700,
                  color: PremiumTheme.primaryRed,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: isMobile ? 5 : 8),
          ],
          Text(
            product.name,
            style: TextStyle(
              fontSize: isMobile ? (isVerySmall ? 13 : 15) : 17,
              fontWeight: FontWeight.w800,
              height: 1.15,
              color: Colors.grey[900],
            ),
            maxLines: isVerySmall ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isMobile ? 5 : 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? (isVerySmall ? 5 : 6) : 8,
              vertical: isMobile ? (isVerySmall ? 2 : 3) : 4,
            ),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  color: Colors.amber[700],
                  size: isMobile ? (isVerySmall ? 12 : 13) : 16,
                ),
                SizedBox(width: isMobile ? 3 : 4),
                Text(
                  product.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          if (description.isNotEmpty && !isVerySmall) ...[
            SizedBox(height: isMobile ? 3 : 6),
            Text(
              description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isMobile ? 10 : 12,
                height: 1.2,
              ),
            ),
          ],
          SizedBox(height: isMobile ? 4 : 6),
          Text(
            '₹${product.price.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: isMobile ? (isVerySmall ? 15 : 16) : 19,
              fontWeight: FontWeight.w800,
              color: PremiumTheme.primaryRed,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Builder(
            builder: (context) {
              final cartItems = ref.watch(cartProvider);
              final quantity = cartItems[product.id]?.quantity ?? 0;

              return Row(
                children: [
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: OutlinedButton(
                      onPressed: quantity > 0
                          ? () => ref.read(cartProvider.notifier).removeProduct(product)
                          : null,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.remove, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: PremiumTheme.lightGrey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        quantity > 0 ? '$quantity' : 'Add',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: PremiumTheme.darkBlack,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: OutlinedButton(
                      onPressed: () => ref.read(cartProvider.notifier).addProduct(product),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.add, size: 20),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab(VendorDetailModel vendor, bool isMobile) {
    final horizontal = ResponsiveBreakpoints.getHorizontalPadding(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(horizontal, 24, horizontal, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Us',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: -0.5,
                  color: Colors.grey[900],
                ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 18 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey[50]!],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey[200]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: PremiumTheme.primaryRed.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              vendor.fullDescription,
              style: TextStyle(
                color: Colors.grey[800],
                height: 1.6,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 18 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey[200]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: PremiumTheme.primaryRed.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why Customers Love Us',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: Colors.grey[900],
                      ),
                ),
                const SizedBox(height: 16),
                ...vendor.customerHighlights.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildLoveUsItem(item),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 28),
          if (vendor.categories.isNotEmpty) ...[
            Text(
              'Services',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    letterSpacing: -0.5,
                    color: Colors.grey[900],
                  ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: vendor.categories
                  .map(
                    (category) => _HighlightChip(
                      label: category,
                      icon: Icons.miscellaneous_services_rounded,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 28),
            Text(
              'Specialist In',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    letterSpacing: -0.5,
                    color: Colors.grey[900],
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? 18 : 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey[50]!],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[200]!, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: PremiumTheme.primaryRed.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Specialist in ${vendor.categories.take(3).join(', ')}',
                style: TextStyle(
                  color: Colors.grey[800],
                  height: 1.6,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
          Text(
            'Business Hours',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: -0.5,
                  color: Colors.grey[900],
                ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 18 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey[50]!],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey[200]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: PremiumTheme.primaryRed.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: vendor.businessHours.entries.map((entry) {
                return _ProfileStatChip(
                  icon: Icons.access_time_rounded,
                  label: entry.key,
                  value: entry.value,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 28),
          if (vendor.amenities.isNotEmpty) ...[
            Text(
              'Amenities & Services',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    letterSpacing: -0.5,
                    color: Colors.grey[900],
                  ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: vendor.amenities
                  .map(
                    (amenity) => _HighlightChip(
                      label: amenity,
                      icon: Icons.check_circle_rounded,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 28),
          ],
          Text(
            'Contact',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: -0.5,
                  color: Colors.grey[900],
                ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 18 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey[50]!],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey[200]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: PremiumTheme.primaryRed.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ContactRow(
                  icon: Icons.phone_rounded,
                  label: 'Phone',
                  value: vendor.phone,
                  onTap: () => _launchPhone(vendor.phone),
                ),
                const Divider(height: 20, thickness: 1),
                _ContactRow(
                  icon: Icons.email_rounded,
                  label: 'Email',
                  value: vendor.email,
                  onTap: () => _launchEmail(vendor.email),
                ),
                const Divider(height: 20, thickness: 1),
                if (vendor.website.isNotEmpty) ...[
                  _ContactRow(
                    icon: Icons.language_rounded,
                    label: 'Website',
                    value: vendor.website,
                    onTap: () => _launchWebsite(vendor.website),
                  ),
                  const Divider(height: 20, thickness: 1),
                ],
                _ContactRow(
                  icon: Icons.location_on_rounded,
                  label: 'Address',
                  value: vendor.address,
                  onTap: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(List<ReviewModel> reviews, bool isMobile) {
    if (kDebugMode) {
      print('[VendorDetailPage] Reviews tab: ${reviews.length} reviews');
    }
    final horizontal = ResponsiveBreakpoints.getHorizontalPadding(context);
    if (reviews.isEmpty) {
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontal, 24, horizontal, 24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.rate_review_rounded,
                      size: 64,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No reviews yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to review this store',
                    style: TextStyle(color: Colors.grey[600], fontSize: 15),
                  ),
                ],
              ),
            ),
            _buildReviewForm(isMobile),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(horizontal, 24, horizontal, 24),
      children: [
        ...reviews.map((review) {
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey[50]!],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey[200]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: PremiumTheme.primaryRed.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: PremiumTheme.primaryRed.withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: NetworkCircleAvatar(
                        imageUrl: review.avatar ?? '',
                        radius: 32,
                        backgroundColor: Colors.grey[100]!,
                        fallback: Icon(
                          Icons.person_rounded,
                          size: 32,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  review.customerName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                    color: Colors.grey[900],
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _formatDate(review.date),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (i) {
                              return Container(
                                margin: const EdgeInsets.only(right: 2),
                                child: Icon(
                                  i < review.rating.round()
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  size: 18,
                                  color: Colors.amber[700],
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: Text(
                    review.comment,
                    style: TextStyle(
                      color: Colors.grey[800],
                      height: 1.6,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        _buildReviewForm(isMobile),
      ],
    );
  }

  Widget _buildReviewForm(bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: PremiumTheme.primaryRed.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Give Feedback',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[900],
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your experience with this vendor and help others find quality service.',
            style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 20),
          Text(
            'Select a Rating',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (index) {
              final selected = index < _reviewRating;
              return GestureDetector(
                onTap: () => setState(() => _reviewRating = index + 1),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  child: Icon(
                    selected ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 30,
                    color: Colors.amber[700],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Form(
            key: _reviewFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _reviewNameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: _buildReviewFieldDecoration('Enter Full Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (isMobile) ...[
                  TextFormField(
                    controller: _reviewPhoneCtrl,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: _buildReviewFieldDecoration('Enter Phone Number'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reviewEmailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: _buildReviewFieldDecoration('Enter Email'),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _reviewPhoneCtrl,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: _buildReviewFieldDecoration('Enter Phone Number'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _reviewEmailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: _buildReviewFieldDecoration('Enter Email'),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reviewMessageCtrl,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  decoration: _buildReviewFieldDecoration('Enter your feedback'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your feedback';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: PremiumTheme.primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _submitReviewForm,
                    child: const Text(
                      'Give Feedback',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildReviewFieldDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: PremiumTheme.primaryRed, width: 2),
      ),
    );
  }

  void _submitReviewForm() {
    if (!_reviewFormKey.currentState!.validate()) return;
    if (_reviewRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating before submitting.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you for your feedback!')),
    );

    setState(() {
      _reviewRating = 0;
      _reviewNameCtrl.clear();
      _reviewPhoneCtrl.clear();
      _reviewEmailCtrl.clear();
      _reviewMessageCtrl.clear();
    });
  }

  Widget _buildLoveUsItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: PremiumTheme.primaryRed.withOpacity(0.14),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 16,
            color: PremiumTheme.primaryRed,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    if (diff < 30) return '${(diff / 7).floor()} weeks ago';
    return '${(diff / 30).floor()} months ago';
  }
}

class _GalleryImageCard extends StatefulWidget {
  final String imageUrl;

  const _GalleryImageCard({required this.imageUrl});

  @override
  State<_GalleryImageCard> createState() => _GalleryImageCardState();
}

class _GalleryImageCardState extends State<_GalleryImageCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0, isHovered ? -6 : 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isHovered ? 0.2 : 0.1),
              blurRadius: isHovered ? 20 : 10,
              offset: Offset(0, isHovered ? 8 : 2),
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 1.4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey[300]),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey[300],
                child: Icon(
                  Icons.image_rounded,
                  size: 48,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopRightAccentPainter extends CustomPainter {
  static const _deep = Color(0xFF7F1D1D);
  static const _mid = Color(0xFFDC2626);
  static const _lite = Color(0xFFEF4444);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.15, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..close(),
      Paint()
        ..color = _deep
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.40, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height * 0.72)
        ..close(),
      Paint()
        ..color = _mid
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.62, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height * 0.46)
        ..close(),
      Paint()
        ..color = _lite.withOpacity(0.65)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomLeftAccentPainter extends CustomPainter {
  static const _deep = Color(0xFF7F1D1D);
  static const _mid = Color(0xFFDC2626);
  static const _lite = Color(0xFFEF4444);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(0, size.height)
        ..lineTo(size.width, size.height)
        ..close(),
      Paint()
        ..color = _deep
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.35)
        ..lineTo(0, size.height)
        ..lineTo(size.width * 0.70, size.height)
        ..close(),
      Paint()
        ..color = _mid
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.60)
        ..lineTo(0, size.height)
        ..lineTo(size.width * 0.45, size.height)
        ..close(),
      Paint()
        ..color = _lite.withOpacity(0.55)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RightStripeAccentPainter extends CustomPainter {
  static const _deep = Color(0xFF7F1D1D);
  static const _mid = Color(0xFFDC2626);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.10, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width * 0.10, size.height)
        ..close(),
      Paint()
        ..color = _deep
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.40, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width * 0.40, size.height)
        ..close(),
      Paint()
        ..color = _mid
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HighlightChip extends StatefulWidget {
  final String label;
  final IconData icon;

  const _HighlightChip({required this.label, required this.icon});

  @override
  State<_HighlightChip> createState() => _HighlightChipState();
}

class _HighlightChipState extends State<_HighlightChip> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PremiumTheme.primaryRed.withOpacity(0.12),
              PremiumTheme.primaryRed.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: PremiumTheme.primaryRed.withOpacity(isHovered ? 0.4 : 0.2),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 16, color: PremiumTheme.primaryRed),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: const TextStyle(
                color: PremiumTheme.primaryRed,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 12,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PremiumTheme.primaryRed.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: PremiumTheme.primaryRed.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isMobile ? 15 : 17, color: PremiumTheme.primaryRed),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: isMobile ? 12 : 13,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isMobile;

  const _HeroStatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 12,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isMobile ? 14 : 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: isMobile ? 12 : 13,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final textStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontSize: isMobile ? 14 : 15);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PremiumTheme.primaryRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: PremiumTheme.primaryRed,
                size: isMobile ? 18 : 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          fontSize: isMobile ? 11 : 12,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: textStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_outward_rounded,
                size: isMobile ? 16 : 18,
                color: PremiumTheme.primaryRed,
              ),
          ],
        ),
      ),
    );
  }
}

class _BusinessInfoRow extends StatefulWidget {
  final _BusinessRow row;
  final VoidCallback? onAction;

  const _BusinessInfoRow({required this.row, required this.onAction});

  @override
  State<_BusinessInfoRow> createState() => _BusinessInfoRowState();
}

class _BusinessInfoRowState extends State<_BusinessInfoRow> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: PremiumTheme.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            widget.row.icon,
            color: PremiumTheme.primaryRed,
            size: 20,
          ),
        ),
        title: Text(
          widget.row.label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(
          widget.row.value,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        trailing: widget.row.action != null
            ? AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isHovered
                      ? PremiumTheme.primaryRed.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_outward_rounded, size: 20),
                  color: PremiumTheme.primaryRed,
                  onPressed: widget.row.action,
                ),
              )
            : null,
      ),
    );
  }
}

class _BusinessRow {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? action;

  const _BusinessRow({
    required this.icon,
    required this.label,
    required this.value,
  }) : action = null;
}
