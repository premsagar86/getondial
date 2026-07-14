import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/premium_theme.dart';
import '../../core/providers/search_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/models/vendor_model.dart';
import '../../core/models/module_model.dart';
import '../../core/models/product_model.dart';
import '../../shared/widgets/vendor_card.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _currentQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final query = _searchController.text;
      if (query != _currentQuery && mounted) {
        setState(() => _currentQuery = query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      backgroundColor: PremiumTheme.lightGrey,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 48,
                vertical: isMobile ? 16 : 24,
              ),
              decoration: BoxDecoration(
                color: PremiumTheme.pureWhite,
                boxShadow: PremiumTheme.cardShadow,
              ),
              child: Column(
                children: [
                  // Back button and title
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                        color: PremiumTheme.darkBlack,
                      ),
                      Expanded(
                        child: Text(
                          'Search',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  _buildSearchBar(isMobile),
                ],
              ),
            ),
            // Results
            Expanded(
              child: _currentQuery.trim().isEmpty
                  ? _buildEmptyState()
                  : _buildSearchResults(isMobile, isTablet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: PremiumTheme.lightGrey,
        borderRadius: PremiumTheme.mediumRadius,
        border: Border.all(
          color: PremiumTheme.primaryRed.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search stores, services, and products...',
          prefixIcon: Icon(
            Icons.search,
            color: PremiumTheme.primaryRed,
            size: 24,
          ),
          suffixIcon: _currentQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _currentQuery = '';
                    });
                  },
                  color: PremiumTheme.mediumGrey,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 20,
            vertical: isMobile ? 16 : 18,
          ),
        ),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: PremiumTheme.primaryRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              size: 64,
              color: PremiumTheme.primaryRed,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Start Searching',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Search for stores, services, or products',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PremiumTheme.mediumGrey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(bool isMobile, bool isTablet) {
    final searchAsync = ref.watch(searchProvider(_currentQuery));

    return searchAsync.when(
      data: (result) {
        if (result.totalCount == 0) {
          return _buildNoResults();
        }

        return Column(
          children: [
            // Tab bar
            Container(
              color: PremiumTheme.pureWhite,
              child: TabBar(
                controller: _tabController,
                labelColor: PremiumTheme.primaryRed,
                unselectedLabelColor: PremiumTheme.mediumGrey,
                indicatorColor: PremiumTheme.primaryRed,
                indicatorWeight: 3,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.store, size: 18),
                        const SizedBox(width: 8),
                        Text('Stores (${result.stores.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.business_center, size: 18),
                        const SizedBox(width: 8),
                        Text('Services (${result.services.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_bag, size: 18),
                        const SizedBox(width: 8),
                        Text('Products (${result.products.length})'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStoresList(result.stores, isMobile, isTablet),
                  _buildServicesList(result.services, isMobile, isTablet),
                  _buildProductsList(result.products, isMobile, isTablet),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: PremiumTheme.primaryRed,
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: PremiumTheme.primaryRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Error searching',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PremiumTheme.mediumGrey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: PremiumTheme.mediumGrey,
          ),
          const SizedBox(height: 24),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or check spelling',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PremiumTheme.mediumGrey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoresList(
    List<VendorModel> stores,
    bool isMobile,
    bool isTablet,
  ) {
    if (stores.isEmpty) {
      return _buildEmptyTab('No stores found');
    }

    final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);
    final spacing = isMobile ? 12.0 : 20.0;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: isMobile ? 0.75 : 0.8,
        ),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          final store = stores[index];
          return VendorCard(
            vendor: store,
            onTap: () {
              context.push('/vendor/${store.id}');
            },
          );
        },
      ),
    );
  }

  Widget _buildServicesList(
    List<ModuleModel> services,
    bool isMobile,
    bool isTablet,
  ) {
    if (services.isEmpty) {
      return _buildEmptyTab('No services found');
    }

    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);
    final spacing = isMobile ? 16.0 : 24.0;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: isMobile ? 1.2 : 1.5,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return _ServiceCard(service: service);
        },
      ),
    );
  }

  Widget _buildProductsList(
    List<ProductModel> products,
    bool isMobile,
    bool isTablet,
  ) {
    if (products.isEmpty) {
      return _buildEmptyTab('No products found');
    }

    final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);
    final spacing = isMobile ? 12.0 : 20.0;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: isMobile ? 0.7 : 0.75,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _ProductCard(product: product);
        },
      ),
    );
  }

  Widget _buildEmptyTab(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: PremiumTheme.mediumGrey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: PremiumTheme.mediumGrey,
                ),
          ),
        ],
      ),
    );
  }
}

// Service Card Widget
class _ServiceCard extends StatefulWidget {
  final ModuleModel service;

  const _ServiceCard({required this.service});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          // Navigate to vendors page filtered by module
          context.push('/vendors?moduleId=${widget.service.id}');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
          decoration: BoxDecoration(
            color: PremiumTheme.pureWhite,
            borderRadius: PremiumTheme.largeRadius,
            border: Border.all(
              color: _isHovered
                  ? PremiumTheme.primaryRed
                  : PremiumTheme.lightGrey,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: _isHovered
                ? PremiumTheme.hoverShadow
                : PremiumTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Image.network(
                    widget.service.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: PremiumTheme.redGradient,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.business_center,
                            size: 48,
                            color: PremiumTheme.pureWhite,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Content
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.service.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          widget.service.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: PremiumTheme.mediumGrey,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Product Card Widget
class _ProductCard extends ConsumerStatefulWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  ConsumerState<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<_ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
        decoration: BoxDecoration(
          color: PremiumTheme.pureWhite,
          borderRadius: PremiumTheme.mediumRadius,
          border: Border.all(
            color: _isHovered
                ? PremiumTheme.primaryRed
                : PremiumTheme.lightGrey,
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: _isHovered
              ? PremiumTheme.hoverShadow
              : PremiumTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      widget.product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: PremiumTheme.redGradient,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.shopping_bag,
                              size: 32,
                              color: PremiumTheme.pureWhite,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                ],
              ),
            ),
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.product.category,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: PremiumTheme.mediumGrey,
                                fontSize: 10,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${widget.product.price.toStringAsFixed(0)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: PremiumTheme.primaryRed,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        if (widget.product.rating > 0)
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                widget.product.rating.toStringAsFixed(1),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ref.read(cartProvider.notifier).addProduct(widget.product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${widget.product.name} added to cart'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart_outlined),
                        label: const Text('Add to Cart'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
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
}

