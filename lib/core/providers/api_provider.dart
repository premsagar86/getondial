import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/vendor_model.dart';
import '../models/product_model.dart';
import '../models/vendor_detail_model.dart' as vdm;
import '../models/contact_request.dart';
import '../models/category_model.dart';
import '../models/zone_model.dart';
import '../models/banner_model.dart';
import '../models/module_model.dart';

@immutable
class VendorDetailArgs {
  final String id;
  final int? moduleId;
  const VendorDetailArgs({required this.id, this.moduleId});

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is VendorDetailArgs && other.id == id && other.moduleId == moduleId);
  }

  @override
  int get hashCode => Object.hash(id, moduleId);
}

@immutable
class StoreItemsArgs {
  final String storeId;
  final int categoryId;
  final int offset;
  final int limit;
  final String type; // 'all' | 'veg' | 'non_veg' etc.
  final int? moduleId;
  const StoreItemsArgs({
    required this.storeId,
    this.categoryId = 0,
    this.offset = 1,
    this.limit = 10,
    this.type = 'all',
    this.moduleId,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is StoreItemsArgs &&
            other.storeId == storeId &&
            other.categoryId == categoryId &&
            other.offset == offset &&
            other.limit == limit &&
            other.type == type &&
            other.moduleId == moduleId);
  }

  @override
  int get hashCode => Object.hash(storeId, categoryId, offset, limit, type, moduleId);
}

@immutable
class StoresWithSubcategoryArgs {
  final int categoryId;
  final int moduleId;
  final List<String> vendorIds; // Use IDs instead of full objects for proper caching
  
  const StoresWithSubcategoryArgs({
    required this.categoryId,
    required this.moduleId,
    required this.vendorIds,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is StoresWithSubcategoryArgs &&
            other.categoryId == categoryId &&
            other.moduleId == moduleId &&
            _listEquals(other.vendorIds, vendorIds));
  }

  @override
  int get hashCode => Object.hash(categoryId, moduleId, Object.hashAll(vendorIds));
  
  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

@immutable
class StoresWithProductArgs {
  final String productId;
  final int categoryId;
  final int moduleId;
  final List<String> vendorIds;
  
  const StoresWithProductArgs({
    required this.productId,
    required this.categoryId,
    required this.moduleId,
    required this.vendorIds,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is StoresWithProductArgs &&
            other.productId == productId &&
            other.categoryId == categoryId &&
            other.moduleId == moduleId &&
            _listEquals(other.vendorIds, vendorIds));
  }

  @override
  int get hashCode => Object.hash(productId, categoryId, moduleId, Object.hashAll(vendorIds));
  
  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Initialize app (location + zone) early when observed
final appInitProvider = FutureProvider<void>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  await apiService.initializeApp();
});

// Store details (vendor details)
final vendorDetailProvider = FutureProvider.family<vdm.VendorDetailModel?, VendorDetailArgs>((ref, args) async {
  final apiService = ref.watch(apiServiceProvider);
  final detail = await apiService.getStoreDetails(args.id, moduleId: args.moduleId);
  return detail;
});

final partnerLogosProvider = Provider<List<String>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getPartnerLogos();
});

final contactSubmissionProvider = StateNotifierProvider<ContactSubmissionNotifier, AsyncValue<ContactResponse?>>((ref) {
  return ContactSubmissionNotifier(ref.watch(apiServiceProvider));
});

class ContactSubmissionNotifier extends StateNotifier<AsyncValue<ContactResponse?>> {
  final ApiService _apiService;
  
  ContactSubmissionNotifier(this._apiService) : super(const AsyncValue.data(null));
  
  Future<void> submitContact(ContactRequest request) async {
    state = const AsyncValue.loading();
    
    try {
      final response = await _apiService.submitContact(request);
      state = AsyncValue.data(response);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Categories (optionally filtered by moduleId)
final categoriesProvider = FutureProvider.family<List<CategoryModel>, int?>((ref, moduleId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getCategories(moduleId: moduleId);
});

// Stores by module (used to power category pages and vendors page)
final storesByModuleProvider = FutureProvider.family<List<VendorModel>, int>((ref, moduleId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getStoresByModule(
    moduleId: moduleId,
    featured: false,
    offset: 1,
    limit: 100,
  );
});

// Paginated stores by module (for loading more stores)
@immutable
class PaginatedStoresArgs {
  final int moduleId;
  final int offset;
  final int limit;
  
  const PaginatedStoresArgs({
    required this.moduleId,
    this.offset = 1,
    this.limit = 50,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PaginatedStoresArgs &&
            other.moduleId == moduleId &&
            other.offset == offset &&
            other.limit == limit);
  }

  @override
  int get hashCode => Object.hash(moduleId, offset, limit);
}

final paginatedStoresProvider = FutureProvider.family<List<VendorModel>, PaginatedStoresArgs>((ref, args) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getStoresByModule(
    moduleId: args.moduleId,
    featured: false,
    offset: args.offset,
    limit: args.limit,
  );
});

// Featured stores by module (featured=true)
final featuredStoresProvider = FutureProvider.family<List<VendorModel>, int>((ref, moduleId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getStoresByModule(
    moduleId: moduleId,
    featured: true, // Get only featured stores
    offset: 1,
    limit: 50,
  );
});

// Featured stores from ALL modules (curated mix)
final allFeaturedStoresProvider = FutureProvider<List<VendorModel>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final modulesAsync = await ref.watch(modulesProvider.future);
  
  // Get featured stores from each module
  final futures = modulesAsync.map((module) => 
    apiService.getStoresByModule(
      moduleId: module.id,
      featured: true,
      offset: 1,
      limit: 10, // Get up to 10 from each module
    )
  ).toList();
  
  final allStores = await Future.wait(futures);
  // Flatten and shuffle to get a good mix
  final flattened = allStores.expand((list) => list).toList();
  flattened.shuffle();
  // Return top 4-5 stores from different modules
  return flattened.take(5).toList();
});

// Latest stores by module (uses /stores/latest?type=all)
final latestStoresProvider = FutureProvider.family<List<VendorModel>, int>((ref, moduleId) async {
  final apiService = ref.watch(apiServiceProvider);
  final list = await apiService.getLatestStores(moduleId: moduleId, type: 'all');
  return list;
});

// Zones list
final zonesProvider = FutureProvider<List<ZoneModel>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getZones();
});

// Selected zone id (for UI) and actions to persist
final selectedZoneIdProvider = StateProvider<int?>((ref) => null);

final headersPreviewProvider = Provider<Map<String, dynamic>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getDebugHeaders();
});

final featuredBannersProvider = FutureProvider<List<BannerModel>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getBanners(featured: true);
});

// Items by store + category (latest)
final storeItemsByCategoryProvider = FutureProvider.family<List<ProductModel>, StoreItemsArgs>((ref, args) async {
  final apiService = ref.watch(apiServiceProvider);
  final list = await apiService.getStoreItemsLatest(
    args.storeId,
    categoryId: args.categoryId,
    offset: args.offset,
    limit: args.limit,
    type: args.type,
    moduleId: args.moduleId,
  );
  return list;
});

// Find stores that have items in a specific subcategory using store items API with category filter
final storesWithSubcategoryProvider = FutureProvider.family<List<VendorModel>, StoresWithSubcategoryArgs>((ref, args) async {
  final apiService = ref.watch(apiServiceProvider);
  
  // Get all stores for the module - use read to avoid circular dependency
  // Since storesByModuleProvider is a FutureProvider, we need to await it
  final allStores = await ref.read(storesByModuleProvider(args.moduleId).future);
  
  // Filter to only the vendors we need to check
  final vendors = allStores.where((v) => args.vendorIds.contains(v.id)).toList();
  
  if (kDebugMode) {
    // ignore: avoid_print
    print('[PROVIDER] storesWithSubcategoryProvider: Checking ${vendors.length} stores for categoryId=${args.categoryId}, moduleId=${args.moduleId}');
  }
  
  // Check each vendor using store items API filtered by categoryId
  final storesWithCategory = <VendorModel>[];
  
  // Process stores in parallel batches for better performance
  final batchSize = 5;
  for (var i = 0; i < vendors.length; i += batchSize) {
    final batch = vendors.skip(i).take(batchSize).toList();
    final results = await Future.wait(
      batch.map((vendor) async {
        try {
          // First check if category is in store's categories list (quick check)
          if (vendor.categories.contains(args.categoryId.toString())) {
            if (kDebugMode) {
              // ignore: avoid_print
              print('[PROVIDER] Store ${vendor.id} has category ${args.categoryId} in categories list');
            }
            return vendor;
          }
          
          // If not in categories list, check if store has items in this category
          // by calling store items API with categoryId filter
          final items = await apiService.getStoreItemsLatest(
            vendor.id,
            categoryId: args.categoryId,
            offset: 1,
            limit: 1, // We only need to check if at least one item exists
            moduleId: args.moduleId,
          );
          
          // If store has items in this category, return it
          if (items.isNotEmpty) {
            if (kDebugMode) {
              // ignore: avoid_print
              print('[PROVIDER] Store ${vendor.id} has ${items.length} items in category ${args.categoryId}');
            }
            return vendor;
          }
          
          return null;
        } catch (e) {
          // Skip this vendor if there's an error
          if (kDebugMode) {
            // ignore: avoid_print
            print('[PROVIDER] Error checking store ${vendor.id} for category ${args.categoryId}: $e');
          }
          return null;
        }
      }),
    );
    
    // Add non-null results to the list
    for (final result in results) {
      if (result != null) {
        storesWithCategory.add(result);
      }
    }
  }
  
  if (kDebugMode) {
    // ignore: avoid_print
    print('[PROVIDER] storesWithSubcategoryProvider(categoryId=${args.categoryId}, moduleId=${args.moduleId}) -> ${storesWithCategory.length} stores found');
  }
  
  return storesWithCategory;
});

// Find stores that have a specific product
final storesWithProductProvider = FutureProvider.family<List<VendorModel>, StoresWithProductArgs>((ref, args) async {
  final apiService = ref.watch(apiServiceProvider);
  
  // Get all stores for the module - use read to avoid circular dependency
  // Since storesByModuleProvider is a FutureProvider, we need to await it
  final allStores = await ref.read(storesByModuleProvider(args.moduleId).future);
  
  // Filter to only the vendors we need to check
  final vendors = allStores.where((v) => args.vendorIds.contains(v.id)).toList();
  
  final storesWithProduct = <VendorModel>[];
  
  const batchSize = 5;
  for (var i = 0; i < vendors.length; i += batchSize) {
    final batch = vendors.skip(i).take(batchSize).toList();
    final results = await Future.wait(
      batch.map((vendor) async {
        try {
          final items = await apiService.getStoreItemsLatest(
            vendor.id,
            categoryId: args.categoryId,
            offset: 1,
            limit: 30,
            moduleId: args.moduleId,
          );
          if (items.any((item) => item.id == args.productId)) return vendor;
          return null;
        } catch (_) {
          return null;
        }
      }),
    );
    for (final r in results) {
      if (r != null) storesWithProduct.add(r);
    }
  }
  
  return storesWithProduct;
});

// Items by store (recommended)
final storeItemsRecommendedProvider = FutureProvider.family<List<ProductModel>, StoreItemsArgs>((ref, args) async {
  final apiService = ref.watch(apiServiceProvider);
  final list = await apiService.getStoreItemsRecommended(
    args.storeId,
    offset: args.offset,
    limit: args.limit,
    moduleId: args.moduleId,
  );
  return list;
});
final modulesProvider = FutureProvider<List<ModuleModel>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getModules();
});

// Campaign items
final campaignItemsProvider = FutureProvider.family<List<ProductModel>, int?>((ref, moduleId) async {
  final apiService = ref.watch(apiServiceProvider);
  final list = await apiService.getCampaignItems(moduleId: moduleId);
  return list;
});

// Popular items
@immutable
class PopularItemsArgs {
  final String type;
  final int? moduleId;
  const PopularItemsArgs({
    this.type = 'all',
    this.moduleId,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PopularItemsArgs &&
            other.type == type &&
            other.moduleId == moduleId);
  }

  @override
  int get hashCode => Object.hash(type, moduleId);
}

final popularItemsProvider = FutureProvider.family<List<ProductModel>, PopularItemsArgs>((ref, args) async {
  final apiService = ref.watch(apiServiceProvider);
  final list = await apiService.getPopularItems(
    type: args.type,
    moduleId: args.moduleId,
  );
  return list;
});
