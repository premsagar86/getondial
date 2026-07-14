import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/category_model.dart';
import '../../core/models/vendor_model.dart';
import '../../core/models/product_model.dart';
import '../../core/providers/api_provider.dart';
import '../../core/theme/premium_theme.dart';
import '../../core/util/global_keyboard_scroll_handler.dart';
import '../../shared/widgets/product_card.dart';

/// 🔧 URL FIXER — prevents 404 image errors
String fixImage(String url) {
  if (url.isEmpty || url == 'null') return '';
  return url.replaceAll('/storage/app/public', '/storage');
}

String _categoryMeta(CategoryModel c) {
  final children = c.childes.length;
  final products = c.productsCount;
  if (children > 0 && products > 0) return '$children sub • $products items';
  if (children > 0) return '$children subcategories';
  if (products > 0) return '$products items';
  return 'Category';
}

class CategoryDetailPage extends ConsumerStatefulWidget {
  final String categoryId;
  const CategoryDetailPage({super.key, required this.categoryId});

  @override
  ConsumerState<CategoryDetailPage> createState() =>
      _CategoryDetailPageState();
}

class _CategoryDetailPageState extends ConsumerState<CategoryDetailPage> {
  int? _selectedSubCategoryId;
  int? _selectedModuleId;
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

  void _handleSubCategoryTap(CategoryModel subCategory, int parentModuleId) {
    // Show dialog with stores that have items in this subcategory
    _showSubcategoryStores(context, ref, subCategory, parentModuleId);
  }

  void _showSubcategoryStores(
    BuildContext context,
    WidgetRef ref,
    CategoryModel subCategory,
    int parentModuleId,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    // Use subcategory's moduleId, or fallback to parent's moduleId, or default to 1
    int moduleId = subCategory.moduleId;
    if (moduleId == 0) {
      moduleId = parentModuleId;
    }
    if (moduleId == 0) {
      moduleId = 1; // Default fallback
    }
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: isMobile ? double.infinity : 500,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      subCategory.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PremiumTheme.darkBlack,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Stores with items in this category',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PremiumTheme.mediumGrey,
                ),
              ),
              const SizedBox(height: 24),
              // Stores List
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    // First get all stores for the module
                    final allStoresAsync = ref.watch(
                      storesByModuleProvider(moduleId),
                    );
                    
                    return allStoresAsync.when(
                      data: (allStores) {
                        // Now check each store using store details API to verify they have items in this subcategory
                        final storesAsync = ref.watch(
                          storesWithSubcategoryProvider(
                            StoresWithSubcategoryArgs(
                              categoryId: subCategory.id,
                              moduleId: moduleId,
                              vendorIds: allStores.map((v) => v.id).toList(),
                            ),
                          ),
                        );
                        
                        return storesAsync.when(
                          data: (storesWithCategory) {
                            if (storesWithCategory.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.store_outlined,
                                      size: 64,
                                      color: PremiumTheme.mediumGrey,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No stores found',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: PremiumTheme.mediumGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No stores currently have items in ${subCategory.name}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: PremiumTheme.mediumGrey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available in ${storesWithCategory.length} store${storesWithCategory.length > 1 ? 's' : ''}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: PremiumTheme.darkBlack,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: storesWithCategory.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final store = storesWithCategory[index];
                                      return InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          context.push(
                                            '/vendor/${store.id}?moduleId=$moduleId',
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: PremiumTheme.lightGrey,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              // Store Logo
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.network(
                                                  store.logoUrl,
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        color: PremiumTheme.primaryRed.withValues(alpha: 0.1),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Icon(
                                                        Icons.store,
                                                        color: PremiumTheme.primaryRed,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              // Store Info
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      store.name,
                                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                        color: PremiumTheme.darkBlack,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.location_on,
                                                          size: 14,
                                                          color: PremiumTheme.mediumGrey,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            store.location,
                                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                              color: PremiumTheme.mediumGrey,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Arrow Icon
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                                color: PremiumTheme.mediumGrey,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (error, _) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error checking stores',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  error.toString(),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: PremiumTheme.mediumGrey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, _) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading stores',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error.toString(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: PremiumTheme.mediumGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  CategoryModel? _findCategoryById(List<CategoryModel> items, int targetId) {
    for (final item in items) {
      if (item.id == targetId) return item;
      final nested = _findCategoryById(item.childes, targetId);
      if (nested != null) return nested;
    }
    return null;
  }

  void _showProductStores(
    BuildContext context,
    WidgetRef ref,
    ProductModel product,
    int categoryId,
    int moduleId,
    List<VendorModel> vendors,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: isMobile ? double.infinity : 500,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PremiumTheme.darkBlack,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Find this product in stores',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PremiumTheme.mediumGrey,
                ),
              ),
              const SizedBox(height: 24),
              // Stores List
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final storesAsync = ref.watch(
                      storesWithProductProvider(
                        StoresWithProductArgs(
                          productId: product.id,
                          categoryId: categoryId,
                          moduleId: moduleId,
                          vendorIds: vendors.map((v) => v.id).toList(),
                        ),
                      ),
                    );
                    
                    return storesAsync.when(
                      data: (stores) {
                        if (stores.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.store_outlined,
                                  size: 64,
                                  color: PremiumTheme.mediumGrey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Not available in any store',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: PremiumTheme.mediumGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'This product is currently out of stock',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: PremiumTheme.mediumGrey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available in ${stores.length} store${stores.length > 1 ? 's' : ''}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: PremiumTheme.darkBlack,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: stores.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final store = stores[index];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      context.push(
                                        '/vendor/${store.id}?moduleId=$moduleId',
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: PremiumTheme.lightGrey,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          // Store Logo
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              store.logoUrl,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: PremiumTheme.primaryRed.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Icon(
                                                    Icons.store,
                                                    color: PremiumTheme.primaryRed,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Store Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  store.name,
                                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: PremiumTheme.darkBlack,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      size: 14,
                                                      color: PremiumTheme.mediumGrey,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        store.location,
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                          color: PremiumTheme.mediumGrey,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Arrow Icon
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: PremiumTheme.mediumGrey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, _) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading stores',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error.toString(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: PremiumTheme.mediumGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider(null));
    final isMobile = MediaQuery.of(context).size.width < 600;

    return categoriesAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (e, st) => Scaffold(
            body: Center(child: Text('Failed to load category: $e')),
          ),
      data: (cats) {
        final all = cats;
        final map = _flatten(all);
        final id = int.tryParse(widget.categoryId);
        final cat = id != null ? map[id] : null;

        if (cat == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Category')),
            body: const Center(child: Text('Category not found')),
          );
        }

        final moduleCandidate = _selectedModuleId ?? cat.moduleId;
        final moduleId = moduleCandidate == 0 ? cat.moduleId : moduleCandidate;
        final selectedChild =
            _selectedSubCategoryId != null
                ? _findCategoryById(cat.childes, _selectedSubCategoryId!)
                : null;

        return Scaffold(
          appBar: AppBar(
            title: Text(cat.name),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (GoRouter.of(context).canPop()) {
                  context.pop();
                } else {
                  context.go('/vendors');
                }
              },
            ),
          ),
          body: PrimaryScrollController(
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🖼️ Header Image with FIX
                AspectRatio(
                  aspectRatio: 16 / 6,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        fixImage(cat.image),
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                gradient: PremiumTheme.redGradient,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.category,
                                  color: Colors.white,
                                  size: 64,
                                ),
                              ),
                            ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        left: isMobile ? 16 : 32,
                        bottom: isMobile ? 16 : 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 24 : 32,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _categoryMeta(cat),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                /// 🧭 Subcategories
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 32,
                    vertical: isMobile ? 24 : 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.childes.isEmpty
                            ? 'No subcategories'
                            : 'Subcategories',
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.w800,
                          color: PremiumTheme.darkBlack,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (cat.childes.isNotEmpty)
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cat.childes.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final ch = cat.childes[index];
                            final currentModuleId = moduleId;
                            return _SubCategoryListTile(
                              category: ch,
                              isSelected: ch.id == _selectedSubCategoryId,
                              onTap: () => _handleSubCategoryTap(ch, currentModuleId),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                /// ⭐ Featured Stores (with FIXED images)
                Container(
                  width: double.infinity,
                  color: Colors.grey.shade50,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedChild == null
                                  ? 'Featured Stores Near You'
                                  : 'Vendors offering ${selectedChild.name}',
                              style: TextStyle(
                                fontSize: isMobile ? 22 : 26,
                                fontWeight: FontWeight.w800,
                                color: PremiumTheme.darkBlack,
                              ),
                            ),
                            if (selectedChild != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Showing partners linked to ${selectedChild.name}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: PremiumTheme.mediumGrey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Consumer(
                        builder: (context, ref, _) {
                          final storesAsync = ref.watch(
                            storesByModuleProvider(moduleId),
                          );

                          return storesAsync.when(
                            data: (stores) {
                              final filtered =
                                  selectedChild == null
                                      ? stores
                                      : stores.where(
                                          (vendor) => vendor.categories.contains(
                                            selectedChild.id.toString(),
                                          ),
                                        ).toList();

                              if (filtered.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Text(
                                          selectedChild == null
                                              ? 'No nearby stores found.'
                                              : 'No vendors currently list ${selectedChild.name}.',
                                          style: TextStyle(
                                            color: PremiumTheme.mediumGrey,
                                          ),
                                        ),
                                        // Show items section even if no vendors
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: 32,
                                            left: isMobile ? 16 : 32,
                                            right: isMobile ? 16 : 32,
                                          ),
                                          child: selectedChild != null
                                              ? _SubcategoryItemsSectionAllVendors(
                                                  category: selectedChild,
                                                  vendors: const [],
                                                  moduleId: moduleId,
                                                  isMobile: isMobile,
                                                  onProductTap: _showProductStores,
                                                )
                                              : _CategoryItemsSection(
                                                  category: cat,
                                                  vendors: const [],
                                                  moduleId: moduleId,
                                                  isMobile: isMobile,
                                                  onProductTap: _showProductStores,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        itemCount: filtered.length,
                                        separatorBuilder:
                                            (_, __) => const SizedBox(height: 16),
                                        itemBuilder: (context, index) {
                                          final v = filtered[index];
                                          return _VendorListCard(
                                            name: v.name,
                                            imageUrl: fixImage(v.bannerUrl),
                                            location: v.location.isNotEmpty ? v.location : 'View details',
                                            onTap: () => context.go(
                                              '/vendor/${v.id}?moduleId=$moduleId',
                                            ),
                                          );
                                        },
                                      ),
                                      // Show items - for main category OR selected subcategory
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isMobile ? 16 : 32,
                                          vertical: 24,
                                        ),
                                        child: selectedChild != null
                                            ? _SubcategoryItemsSectionAllVendors(
                                                category: selectedChild,
                                                vendors: filtered,
                                                moduleId: moduleId,
                                                isMobile: isMobile,
                                                onProductTap: _showProductStores,
                                              )
                                            : _CategoryItemsSection(
                                                category: cat,
                                                vendors: filtered,
                                                moduleId: moduleId,
                                                isMobile: isMobile,
                                                onProductTap: _showProductStores,
                                              ),
                                      ),
                                    ],
                                  );
                            },

                            loading:
                                () => const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),

                            error:
                                (e, st) => Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text('Failed to load stores: $e'),
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  /// Flatten nested categories
  Map<int, CategoryModel> _flatten(List<CategoryModel> roots) {
    final map = <int, CategoryModel>{};

    void dfs(CategoryModel c) {
      map[c.id] = c;
      for (final ch in c.childes) {
        dfs(ch);
      }
    }

    for (final r in roots) {
      dfs(r);
    }

    return map;
  }

}

class _VendorListCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String location;
  final VoidCallback onTap;

  const _VendorListCard({
    required this.name,
    required this.imageUrl,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PremiumTheme.lightGrey),
          boxShadow: PremiumTheme.cardShadow,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl.isNotEmpty
                    ? imageUrl
                    : 'https://via.placeholder.com/140x120?text=No+Image',
                width: 120,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      width: 120,
                      height: 100,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.storefront, color: Colors.grey),
                    ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: PremiumTheme.darkBlack,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.redAccent),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: theme.bodyMedium?.copyWith(
                            color: PremiumTheme.mediumGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('View Vendor'),
                      style: TextButton.styleFrom(
                        foregroundColor: PremiumTheme.primaryRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that shows items for the main category
class _CategoryItemsSection extends ConsumerStatefulWidget {
  final CategoryModel category;
  final List<VendorModel> vendors;
  final int moduleId;
  final bool isMobile;
  final Function(BuildContext, WidgetRef, ProductModel, int, int, List<VendorModel>) onProductTap;

  const _CategoryItemsSection({
    required this.category,
    required this.vendors,
    required this.moduleId,
    required this.isMobile,
    required this.onProductTap,
  });

  @override
  ConsumerState<_CategoryItemsSection> createState() => _CategoryItemsSectionState();
}

class _CategoryItemsSectionState extends ConsumerState<_CategoryItemsSection> {
  bool _showAllItems = false;
  static const int _initialDisplayCount = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.vendors.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items in ${widget.category.name}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: widget.isMobile ? 18 : 22,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No vendors available to show items for ${widget.category.name}.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: PremiumTheme.mediumGrey,
            ),
          ),
        ],
      );
    }

    // Show items from the first vendor for the main category
    final firstVendor = widget.vendors.first;
    final itemsAsync = ref.watch(
      storeItemsByCategoryProvider(
        StoreItemsArgs(
          storeId: firstVendor.id,
          categoryId: widget.category.id,
          moduleId: widget.moduleId,
          limit: 100, // Load all items but show only 10 initially
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items in ${widget.category.name}',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: widget.isMobile ? 18 : 22,
          ),
        ),
        if (widget.vendors.length > 1) ...[
          const SizedBox(height: 4),
          Text(
            'Showing items from ${widget.vendors.length} vendor${widget.vendors.length > 1 ? 's' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: PremiumTheme.mediumGrey,
            ),
          ),
        ],
        const SizedBox(height: 16),
        itemsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return Text(
                'No products are currently listed under ${widget.category.name}.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: PremiumTheme.mediumGrey,
                ),
              );
            }
            // Show 10 initially, all when toggled
            final displayCount = _showAllItems ? items.length : _initialDisplayCount;
            final display = items.take(displayCount).toList();
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = _gridColumns(constraints.maxWidth);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: widget.isMobile ? 0.65 : 0.7,
                      ),
                      itemCount: display.length,
                      itemBuilder: (context, index) {
                        final product = display[index];
                        return ProductCard(
                          product: product,
                          onTap: () => widget.onProductTap(
                            context,
                            ref,
                            product,
                            widget.category.id,
                            widget.moduleId,
                            widget.vendors,
                          ),
                        );
                      },
                    );
                  },
                ),
                // View More / View Less button
                if (items.length > _initialDisplayCount)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showAllItems = !_showAllItems;
                          });
                        },
                        icon: Icon(
                          _showAllItems ? Icons.expand_less : Icons.expand_more,
                        ),
                        label: Text(
                          _showAllItems
                              ? 'View Less'
                              : 'View More (${items.length - _initialDisplayCount} more)',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: PremiumTheme.primaryRed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(
            'Failed to load items: $e',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  int _gridColumns(double width) {
    if (widget.isMobile) return 2;
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    return 2;
  }
}

/// Widget that aggregates items from multiple vendors for a subcategory
class _SubcategoryItemsSectionAllVendors extends ConsumerStatefulWidget {
  final CategoryModel category;
  final List<VendorModel> vendors;
  final int moduleId;
  final bool isMobile;
  final Function(BuildContext, WidgetRef, ProductModel, int, int, List<VendorModel>) onProductTap;

  const _SubcategoryItemsSectionAllVendors({
    required this.category,
    required this.vendors,
    required this.moduleId,
    required this.isMobile,
    required this.onProductTap,
  });

  @override
  ConsumerState<_SubcategoryItemsSectionAllVendors> createState() => _SubcategoryItemsSectionAllVendorsState();
}

class _SubcategoryItemsSectionAllVendorsState extends ConsumerState<_SubcategoryItemsSectionAllVendors> {
  bool _showAllItems = false;
  static const int _initialDisplayCount = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If no vendors, try to fetch items from first available vendor or show message
    if (widget.vendors.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items in ${widget.category.name}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: widget.isMobile ? 18 : 22,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No vendors available to show items for ${widget.category.name}.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: PremiumTheme.mediumGrey,
            ),
          ),
        ],
      );
    }

    // For now, show items from the first vendor (we can enhance this later to aggregate from all)
    // This ensures items are always visible when a subcategory is selected
    final firstVendor = widget.vendors.first;
    final itemsAsync = ref.watch(
      storeItemsByCategoryProvider(
        StoreItemsArgs(
          storeId: firstVendor.id,
          categoryId: widget.category.id,
          moduleId: widget.moduleId,
          limit: 100, // Load all items but show only 10 initially
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items in ${widget.category.name}',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: widget.isMobile ? 18 : 22,
          ),
        ),
        if (widget.vendors.length > 1) ...[
          const SizedBox(height: 4),
          Text(
            'Showing items from ${widget.vendors.length} vendor${widget.vendors.length > 1 ? 's' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: PremiumTheme.mediumGrey,
            ),
          ),
        ],
        const SizedBox(height: 16),
        itemsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return Text(
                'No products are currently listed under ${widget.category.name}.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: PremiumTheme.mediumGrey,
                ),
              );
            }
            // Show 10 initially, all when toggled
            final displayCount = _showAllItems ? items.length : _initialDisplayCount;
            final display = items.take(displayCount).toList();
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
              builder: (context, constraints) {
                final columns = _gridColumns(constraints.maxWidth);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: widget.isMobile ? 0.65 : 0.7,
                  ),
                  itemCount: display.length,
                  itemBuilder: (context, index) {
                    final product = display[index];
                    return ProductCard(
                      product: product,
                      onTap: () => widget.onProductTap(
                        context,
                        ref,
                        product,
                        widget.category.id,
                        widget.moduleId,
                        widget.vendors,
                      ),
                    );
                  },
                );
              },
            ),
            // View More / View Less button
            if (items.length > _initialDisplayCount)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showAllItems = !_showAllItems;
                      });
                    },
                    icon: Icon(
                      _showAllItems ? Icons.expand_less : Icons.expand_more,
                    ),
                    label: Text(
                      _showAllItems
                          ? 'View Less'
                          : 'View More (${items.length - _initialDisplayCount} more)',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: PremiumTheme.primaryRed,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(
            'Failed to load items: $e',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  int _gridColumns(double width) {
    if (widget.isMobile) return 2;
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    return 2;
  }
}

class _SubCategoryListTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  final bool isSelected;

  const _SubCategoryListTile({
    required this.category,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final bgColor = isSelected
        ? PremiumTheme.primaryRed.withValues(alpha: 0.08)
        : Colors.white;
    final borderColor =
        isSelected ? PremiumTheme.primaryRed : PremiumTheme.lightGrey;
    final titleColor =
        isSelected ? PremiumTheme.primaryRed : PremiumTheme.darkBlack;
    final metaColor =
        isSelected ? PremiumTheme.primaryRed.withOpacity(0.7) : PremiumTheme.mediumGrey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: PremiumTheme.cardShadow,
        ),
        child: Row(
          children: [
            Icon(
              Icons.label_important,
              color: titleColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: theme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _categoryMeta(category),
                    style: theme.bodySmall?.copyWith(
                      color: metaColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: metaColor,
            ),
          ],
        ),
      ),
    );
  }
}
