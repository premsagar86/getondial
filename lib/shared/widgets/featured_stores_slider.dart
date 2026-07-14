import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/premium_theme.dart';
import '../../core/responsive/responsive_breakpoints.dart';
import '../../core/providers/api_provider.dart';
import '../../core/models/vendor_model.dart';
import '../../shared/widgets/animated_fade_in.dart';
import '../../shared/widgets/section_header.dart';
import 'vendor_card.dart';

/// Enhanced Featured Stores Slider with clean UI/UX
class FeaturedStoresSlider extends ConsumerStatefulWidget {
  final int? moduleId;
  
  const FeaturedStoresSlider({
    super.key,
    this.moduleId,
  });

  @override
  ConsumerState<FeaturedStoresSlider> createState() => _FeaturedStoresSliderState();
}

class _FeaturedStoresSliderState extends ConsumerState<FeaturedStoresSlider> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollButtons);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollButtons);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollButtons() {
    if (!_scrollController.hasClients) return;
    final canLeft = _scrollController.offset > 0;
    final canRight = _scrollController.offset < _scrollController.position.maxScrollExtent - 10;
    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      (_scrollController.offset - 300).clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      (_scrollController.offset + 300).clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 && 
                     MediaQuery.of(context).size.width < 1024;
    final padding = ResponsiveBreakpoints.getHorizontalPadding(context);
    final maxWidth = ResponsiveBreakpoints.getMaxContentWidth(context);
    
    // Fetch featured stores from ALL modules (curated mix)
    final featuredStoresAsync = ref.watch(
      widget.moduleId != null 
        ? featuredStoresProvider(widget.moduleId!) 
        : allFeaturedStoresProvider,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 48 : 72,
        horizontal: isMobile ? padding : padding + 60, // Extra padding for arrows
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumTheme.pureWhite,
            Colors.grey[50]!,
            PremiumTheme.pureWhite,
          ],
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: featuredStoresAsync.when(
          data: (stores) {
            final featuredStores = stores.take(6).toList();
            
            if (featuredStores.isEmpty) {
              final allStoresAsync = ref.watch(
                storesByModuleProvider(widget.moduleId ?? 1),
              );
              return allStoresAsync.when(
                data: (allStores) {
                  final fallbackStores = allStores.take(6).toList();
                  if (fallbackStores.isEmpty) {
                    return _buildEmptyState(context, isMobile);
                  }
                  final storesList = _buildStoresList(context, isMobile, isTablet, fallbackStores);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateScrollButtons();
                  });
                  return storesList;
                },
                loading: () => _buildLoadingState(context, isMobile),
                error: (_, __) => _buildEmptyState(context, isMobile),
              );
            }
            
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateScrollButtons();
            });
            final storesList = _buildStoresList(context, isMobile, isTablet, featuredStores);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateScrollButtons();
            });
            return storesList;
          },
          loading: () => _buildLoadingState(context, isMobile),
          error: (_, __) => _buildEmptyState(context, isMobile),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isMobile) {
    return Column(
      children: [
        SectionHeader(
          title: 'Featured Stores',
          subtitle: 'Discover our top-rated partners',
          centerAlign: true,
        ),
        SizedBox(height: isMobile ? 32 : 48),
        Container(
          padding: EdgeInsets.all(isMobile ? 24 : 32),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PremiumTheme.lightGrey),
          ),
          child: Column(
            children: [
              Icon(
                Icons.store_outlined,
                size: isMobile ? 48 : 64,
                color: PremiumTheme.mediumGrey,
              ),
              SizedBox(height: isMobile ? 16 : 24),
              Text(
                'No featured stores available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PremiumTheme.darkBlack,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 8 : 12),
              Text(
                'Check back soon for exciting new partners',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PremiumTheme.mediumGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context, bool isMobile) {
    return Column(
      children: [
        SectionHeader(
          title: 'Featured Stores',
          subtitle: 'Discover our top-rated partners',
          centerAlign: true,
        ),
        SizedBox(height: isMobile ? 32 : 48),
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(PremiumTheme.primaryRed),
          ),
        ),
      ],
    );
  }

  Widget _buildStoresList(
    BuildContext context,
    bool isMobile,
    bool isTablet,
    List<VendorModel> stores,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate card width based on screen size - significantly increased
    double cardWidth;
    if (isMobile) {
      cardWidth = (screenWidth - 80) * 0.75; // 75% of available width (increased from 65%)
    } else if (isTablet) {
      cardWidth = 360; // Increased from 280
    } else {
      cardWidth = 420; // Increased from 320
    }
    
    final spacing = isMobile ? 20.0 : 32.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with View All button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: SectionHeader(
                title: 'Featured Stores',
                subtitle: 'Discover our top-rated partners and trusted local businesses',
                centerAlign: false,
              ),
            ),
            if (!isMobile) ...[
              const SizedBox(width: 24),
              TextButton.icon(
                onPressed: () => context.go('/vendors'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('View All'),
                style: TextButton.styleFrom(
                  foregroundColor: PremiumTheme.primaryRed,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ],
        ),
        
        SizedBox(height: isMobile ? 32 : 48),
        
        // Stores Slider with Navigation
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: isMobile ? 320 : 450,
              child: ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 60, // Extra padding for arrows
                ),
                itemCount: stores.length,
                separatorBuilder: (_, __) => SizedBox(width: spacing),
                itemBuilder: (context, index) {
                  final store = stores[index];
                  return AnimatedFadeIn(
                    delay: Duration(milliseconds: 200 + (index * 100)),
                    slideOffset: const Offset(0, 20),
                    curve: Curves.easeOutCubic,
                    child: SizedBox(
                      width: cardWidth,
                      child: _EnhancedStoreCard(
                        store: store,
                        index: index,
                        moduleId: widget.moduleId,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Navigation Arrows (Desktop/Tablet only) - positioned outside to avoid blocking
            if (!isMobile) ...[
              // Left Arrow - positioned outside the scrollable area
              Positioned(
                left: -20,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  ignoring: !_canScrollLeft,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _canScrollLeft ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _canScrollLeft ? _scrollLeft : null,
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: PremiumTheme.pureWhite,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.chevron_left_rounded,
                              color: PremiumTheme.primaryRed,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Right Arrow - positioned outside the scrollable area
              Positioned(
                right: -20,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  ignoring: !_canScrollRight,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _canScrollRight ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _canScrollRight ? _scrollRight : null,
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: PremiumTheme.pureWhite,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: PremiumTheme.primaryRed,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        
        // View All Button for Mobile
        if (isMobile) ...[
          const SizedBox(height: 24),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => context.go('/vendors'),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('View All Stores'),
              style: OutlinedButton.styleFrom(
                foregroundColor: PremiumTheme.primaryRed,
                side: BorderSide(color: PremiumTheme.primaryRed, width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Enhanced Store Card with modern design
class _EnhancedStoreCard extends StatefulWidget {
  final VendorModel store;
  final int index;
  final int? moduleId;

  const _EnhancedStoreCard({
    required this.store,
    required this.index,
    this.moduleId,
  });

  @override
  State<_EnhancedStoreCard> createState() => _EnhancedStoreCardState();
}

class _EnhancedStoreCardState extends State<_EnhancedStoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _elevationAnimation = Tween<double>(begin: 2.0, end: 12.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool hover) {
    setState(() => _isHovered = hover);
    if (hover) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: PremiumTheme.primaryRed.withValues(
                      alpha: _isHovered ? 0.15 : 0.05,
                    ),
                    blurRadius: _elevationAnimation.value * 2,
                    offset: Offset(0, _elevationAnimation.value),
                    spreadRadius: _isHovered ? 2 : 0,
                  ),
                ],
              ),
              child: VendorCard(
                vendor: widget.store,
                onTap: () {
                  context.push(
                    '/vendor/${widget.store.id}${widget.moduleId != null ? '?moduleId=${widget.moduleId}' : ''}',
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
