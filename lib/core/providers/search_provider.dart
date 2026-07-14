import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vendor_model.dart';
import '../models/module_model.dart';
import '../models/product_model.dart';
import 'api_provider.dart';

class SearchResult {
  final List<VendorModel> stores;
  final List<ModuleModel> services;
  final List<ProductModel> products;

  const SearchResult({
    required this.stores,
    required this.services,
    required this.products,
  });

  int get totalCount => stores.length + services.length + products.length;
}

final searchProvider = FutureProvider.family<SearchResult, String>((ref, query) async {
  if (query.trim().length < 2) {
    return const SearchResult(stores: [], services: [], products: []);
  }

  // Debounce: wait 400ms before executing search
  final completer = Completer<void>();
  final timer = Timer(const Duration(milliseconds: 400), completer.complete);
  ref.onDispose(timer.cancel);
  await completer.future;

  final searchQuery = query.toLowerCase().trim();

  final modulesAsync = ref.watch(modulesProvider);
  final allModules = await modulesAsync.when(
    data: (modules) => Future.value(modules),
    loading: () => Future.value(<ModuleModel>[]),
    error: (_, __) => Future.value(<ModuleModel>[]),
  );

  // Fetch stores from up to 3 modules in parallel instead of all
  final modulesToSearch = allModules.take(3).toList();
  final storeResults = await Future.wait(
    modulesToSearch.map((module) async {
      try {
        return await ref.read(storesByModuleProvider(module.id).future);
      } catch (_) {
        return <VendorModel>[];
      }
    }),
  );
  final allStores = storeResults.expand((s) => s).toList();

  final allProducts = <ProductModel>[];
  try {
    final popularProducts = await ref.read(
      popularItemsProvider(const PopularItemsArgs(type: 'all', moduleId: null)).future,
    );
    allProducts.addAll(popularProducts);
  } catch (_) {}

  // Only fetch product details for top 5 matching stores
  final matchingStores = allStores.where((store) {
    return store.name.toLowerCase().contains(searchQuery) ||
        store.shortDescription.toLowerCase().contains(searchQuery);
  }).take(5).toList();

  final productResults = await Future.wait(
    matchingStores.map((store) async {
      try {
        return await ref.read(
          storeItemsByCategoryProvider(
            StoreItemsArgs(storeId: store.id, categoryId: 0, offset: 1, limit: 15),
          ).future,
        );
      } catch (_) {
        return <ProductModel>[];
      }
    }),
  );
  for (final products in productResults) {
    allProducts.addAll(products);
  }

  final filteredStores = allStores.where((store) {
    return store.name.toLowerCase().contains(searchQuery) ||
        store.shortDescription.toLowerCase().contains(searchQuery) ||
        store.location.toLowerCase().contains(searchQuery) ||
        store.categories.any((cat) => cat.toLowerCase().contains(searchQuery));
  }).toList();

  final filteredServices = allModules.where((module) {
    return module.name.toLowerCase().contains(searchQuery) ||
        module.description.toLowerCase().contains(searchQuery) ||
        module.moduleType.toLowerCase().contains(searchQuery);
  }).toList();

  final filteredProducts = allProducts.where((product) {
    return product.name.toLowerCase().contains(searchQuery) ||
        product.description.toLowerCase().contains(searchQuery) ||
        product.category.toLowerCase().contains(searchQuery);
  }).toList();

  return SearchResult(
    stores: filteredStores,
    services: filteredServices,
    products: filteredProducts,
  );
});

