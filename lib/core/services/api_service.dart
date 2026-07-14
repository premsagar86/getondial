import '../models/vendor_model.dart';
import '../models/product_model.dart';
import '../models/vendor_detail_model.dart' as vdm;
import '../models/review_model.dart';
import '../models/contact_request.dart';
import '../models/category_model.dart';
import '../models/zone_model.dart';
import '../models/banner_model.dart';
import '../models/module_model.dart';
import 'storage_service.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';

class _TimedCache<T> {
  const _TimedCache(this.value, this.timestamp);
  final T value;
  final DateTime timestamp;

  bool isFresh(Duration ttl) => DateTime.now().difference(timestamp) < ttl;
}

class ApiService {
  static const String baseUrl = 'https://getondial.com/api/v1';
  static const String _moduleImageBase =
      'https://getondial.com/storage/app/public/module/';
  static const String _categoryImageBase =
      'https://getondial.com/storage/app/public/category/';
  static const String _storeImageBase =
      'https://getondial.com/storage/app/public/store/';
  static const String _bannerImageBase =
      'https://getondial.com/storage/app/public/banner/';
  static const String _productImageBase =
      'https://getondial.com/storage/app/public/product/';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
      headers: {
        'X-localization': 'en',
      },
    ),
  );

  /// ✅ NEW: constructor with Web-safe interceptor
  ApiService() {
    // Prevent Flutter Web from crashing when backend returns HTML error pages
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          if (response.data is String &&
              (response.data.contains('<html') ||
                  response.data.contains('<!DOCTYPE html'))) {
            handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                error: 'Server returned HTML instead of JSON',
                type: DioExceptionType.badResponse,
              ),
            );
            return;
          }
          handler.next(response);
        },
      ),
    );

    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 20);
    _dio.options.sendTimeout = const Duration(seconds: 15);
  }

  static const Duration _cacheTtl = Duration(minutes: 5);
  static const Duration _fastCacheTtl = Duration(minutes: 2);

  // Modules cache
  List<ModuleModel>? _cachedModules;
  DateTime? _modulesCachedAt;

  // Categories cache (all modules)
  List<CategoryModel>? _cachedCategories;
  DateTime? _categoriesCachedAt;

  // Zones cache
  List<ZoneModel>? _cachedZones;
  DateTime? _zonesCachedAt;

  final StorageService _storage = StorageService.instance;
  final Map<String, vdm.VendorDetailModel?> _storeDetailCache = {};
  final Map<String, Future<vdm.VendorDetailModel?>> _storeDetailRequests = {};
  final Map<String, List<ProductModel>> _storeItemsCache = {};
  final Map<String, Future<List<ProductModel>>> _storeItemsRequests = {};
  final Map<String, _TimedCache<List<VendorModel>>> _latestStoresCache = {};
  final Map<String, Future<List<VendorModel>>> _latestStoresRequests = {};
  final Map<String, _TimedCache<List<VendorModel>>> _storesByModuleCache = {};
  final Map<String, Future<List<VendorModel>>> _storesByModuleRequests = {};

  // Get all categories (optionally filter by moduleId)
  Future<List<CategoryModel>> getCategories({int? moduleId}) async {
    // Return cache if fresh
    if (_cachedCategories != null && _categoriesCachedAt != null) {
      final isFresh =
          DateTime.now().difference(_categoriesCachedAt!) < _cacheTtl;
      if (isFresh) {
        final all = _cachedCategories!;
        return moduleId == null
            ? all
            : all
                .where((c) => c.moduleId == moduleId && c.parentId == 0)
                .toList();
      }
    }

    try {
      final res = await _dio.get('/categories');
      final data = res.data;
      if (data is List) {
        final categories =
            data.map<CategoryModel>((raw) {
              final m = raw as Map<String, dynamic>;
              final cat = CategoryModel.fromJson(m);
              // normalize image to full URL
              final img = _resolveCategoryImage(cat.image);
              return CategoryModel(
                id: cat.id,
                name: cat.name,
                image: img,
                parentId: cat.parentId,
                moduleId: cat.moduleId,
                slug: cat.slug,
                productsCount: cat.productsCount,
                childes:
                    cat.childes
                        .map(
                          (ch) => CategoryModel(
                            id: ch.id,
                            name: ch.name,
                            image: _resolveCategoryImage(ch.image),
                            parentId: ch.parentId,
                            moduleId: ch.moduleId,
                            slug: ch.slug,
                            productsCount: ch.productsCount,
                            childes: ch.childes,
                          ),
                        )
                        .toList(),
              );
            }).toList();

        _cachedCategories = categories;
        _categoriesCachedAt = DateTime.now();

        final topLevel = categories.where((c) => c.parentId == 0).toList();
        return moduleId == null
            ? topLevel
            : topLevel.where((c) => c.moduleId == moduleId).toList();
      }

      return [];
    } on DioException catch (_) {
      return [];
    } catch (_) {
      return [];
    }
  }

  // Ensure we have location + zone id, request from user if missing.
  Future<void> _ensureLocationAndZone() async {
    await _storage.init();
    var lat = _storage.getLatitude();
    var lng = _storage.getLongitude();
    var zones = _storage.getZoneIds();

    if (lat == null || lng == null) {
      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          await Geolocator.requestPermission();
        }
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );
        lat = pos.latitude;
        lng = pos.longitude;
        if (kDebugMode) {
          // ignore: avoid_print
          print(
            '[INIT] Captured device location lat=${lat.toString()}, lng=${lng.toString()}',
          );
        }
      } catch (_) {
        // Fallback to provided example coordinates (Visakhapatnam)
        lat = 17.736786411094663;
        lng = 83.31544903923952;
        if (kDebugMode) {
          // ignore: avoid_print
          print(
            '[INIT][WARN] Using fallback location lat=${lat.toString()}, lng=${lng.toString()}',
          );
        }
      }
      await _storage.setLocation(lat, lng);
    }

    if (zones.isEmpty) {
      try {
        final res = await _dio.get(
          '/config/get-zone-id',
          queryParameters: {'lat': lat, 'lng': lng},
        );
        final data = res.data;
        if (data is Map && data['zone_id'] != null) {
          // Some backends return single zone_id, some return array
          final z = data['zone_id'];
          List<int> zoneIds;
          if (z is List) {
            zoneIds =
                z
                    .map((e) => int.tryParse(e.toString()) ?? 0)
                    .where((e) => e > 0)
                    .toList();
          } else {
            final id = int.tryParse(z.toString());
            zoneIds = id != null ? [id] : [];
          }
          if (zoneIds.isNotEmpty) {
            await _storage.setZoneIds(zoneIds);
            zones = zoneIds;
            if (kDebugMode) {
              // ignore: avoid_print
              print(
                '[INIT] Applied zoneId(s) from /config/get-zone-id -> ${zones.toString()}',
              );
            }
          }
        }
      } catch (_) {}
    }

    // Secondary fallback: derive nearest zone from /zone/list if still empty
    if (zones.isEmpty) {
      try {
        final res = await _dio.get('/zone/list');
        final data = res.data;
        if (data is List) {
          int? bestId;
          double bestDist = double.infinity;
          for (final z in data) {
            if (z is! Map<String, dynamic>) continue;
            final id = int.tryParse((z['id'] ?? '').toString());
            final coords = z['coordinates'];
            if (id == null || coords == null) continue;
            final c = _centroidFromGeoJson(coords);
            if (c == null) continue;
            final d = _haversine(lat, lng, c[0], c[1]);
            if (d < bestDist) {
              bestDist = d;
              bestId = id;
            }
          }
          if (bestId != null) {
            await _storage.setZoneIds([bestId]);
            zones = [bestId];
            if (kDebugMode) {
              // ignore: avoid_print
              print(
                '[INIT] Derived nearest zone from /zone/list -> ${zones.toString()}',
              );
            }
          }
        }
      } catch (_) {}
    }

    // Final fallback to known working zone id
    if (zones.isEmpty) {
      await _storage.setZoneIds([21]);
      if (kDebugMode) {
        // ignore: avoid_print
        print('[INIT][WARN] Falling back to default zoneId [21]');
      }
    }
  }

  // Public initializer to be optionally called on app start
  Future<void> initializeApp() async {
    await _ensureLocationAndZone();
    if (kDebugMode) {
      // ignore: avoid_print
      print(
        '[INIT] initializeApp complete. headers=${_defaultHeaders().toString()}',
      );
    }
  }

  Map<String, dynamic> _defaultHeaders() {
    final zones = _storage.getZoneIds();
    final lat = _storage.getLatitude();
    final lng = _storage.getLongitude();
    final token = _storage.getToken();
    final headers = <String, dynamic>{'X-localization': _storage.getLanguage()};
    if (zones.isNotEmpty) headers['zoneId'] = zones.toString();
    if (lat != null) headers['latitude'] = lat.toString();
    if (lng != null) headers['longitude'] = lng.toString();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    headers['Content-Type'] = 'application/json';
    return headers;
  }

  // Public: get current headers (for debug panel)
  Map<String, dynamic> getDebugHeaders() => _defaultHeaders();

  // Get list of zones
  Future<List<ZoneModel>> getZones() async {
    if (_cachedZones != null && _zonesCachedAt != null) {
      final fresh = DateTime.now().difference(_zonesCachedAt!) < _cacheTtl;
      if (fresh) return _cachedZones!;
    }
    try {
      final res = await _dio.get('/zone/list');
      final data = res.data;
      if (data is List) {
        final zones =
            data
                .whereType<Map<String, dynamic>>()
                .map((z) => ZoneModel.fromJson(z))
                .toList();
        _cachedZones = zones;
        _zonesCachedAt = DateTime.now();
        return zones;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // Manually set zone(s)
  Future<void> setZoneIds(List<int> zones) async {
    await _storage.setZoneIds(zones);
  }

  // Manually set location
  Future<void> setLocation(double lat, double lng) async {
    await _storage.setLocation(lat, lng);
  }

  // Fetch featured stores and filter by module id
  Future<List<VendorModel>> getStoresByModule({
    required int moduleId,
    bool featured = true,
    String filterBy = 'all',
    int offset = 1, // API uses 1-based offset
    int limit = 50, // Default to 50 to get all stores
  }) async {
    final cacheKey = '$moduleId|$featured|$filterBy|$offset|$limit';
    final cached = _storesByModuleCache[cacheKey];
    if (cached != null && cached.isFresh(_fastCacheTtl)) {
      return cached.value;
    }

    if (_storesByModuleRequests.containsKey(cacheKey)) {
      return _storesByModuleRequests[cacheKey]!;
    }

    Future<List<VendorModel>> loader() async {
      await _ensureLocationAndZone();
      final sw = Stopwatch()..start();
      try {
        final baseHeaders = _defaultHeaders();
        final headers = {...baseHeaders, 'moduleId': moduleId.toString()};
        if (kDebugMode) {
          // ignore: avoid_print
          print(
            '[API] GET /stores/get-stores/$filterBy params={offset:$offset, limit:$limit} headers=${headers.toString()}',
          );
        }

        final res = await _dio.get(
          '/stores/get-stores/$filterBy',
          queryParameters: {
            'offset': offset,
            'limit': limit,
          },
          options: Options(headers: headers),
        );
        final data = res.data;
        
        // Handle both response formats: {stores: [...]} or direct list
        List<dynamic> rawStores = [];
        if (data is Map && data['stores'] is List) {
          rawStores = data['stores'] as List;
        } else if (data is List) {
          rawStores = data;
        } else if (data is Map && data['data'] is List) {
          rawStores = data['data'] as List;
        }
        
        if (kDebugMode) {
          // ignore: avoid_print
          print('====> API Request URL: ${res.requestOptions.uri}');
          print('====> API Response: [${res.statusCode}] ${res.requestOptions.path}');
          print('[API] /stores/get-stores/$filterBy - received ${rawStores.length} stores');
        }
        
        if (rawStores.isEmpty) {
          return [];
        }
        
        final list =
            rawStores
                .whereType<Map<String, dynamic>>()
                .where(
                  (e) =>
                      e['module_id'] != null &&
                      int.tryParse(e['module_id'].toString()) == moduleId,
                )
                .map<VendorModel>(_vendorFromStore)
                .toList();
        if (kDebugMode) {
          // ignore: avoid_print
          print(
            '[API] /stores/get-stores/$filterBy - filtered ${list.length} by moduleId=$moduleId',
          );
        }
        return list;
      } on DioException catch (e) {
        if (kDebugMode) {
          // ignore: avoid_print
          print(
            '[API][ERROR] stores DioException ${e.message ?? ''} status=${e.response?.statusCode?.toString() ?? ''} data=${e.response?.data?.toString() ?? ''}',
          );
        }
        return [];
      } catch (e) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('[API][ERROR] stores ${e.toString()}');
        }
        return [];
      } finally {
        if (kDebugMode) {
          sw.stop();
          // ignore: avoid_print
          print(
            '[API][PERF] getStoresByModule(moduleId=$moduleId) took ${sw.elapsedMilliseconds}ms',
          );
        }
      }
    }

    final future = loader();
    _storesByModuleRequests[cacheKey] = future;
    final result = await future;
    _storesByModuleRequests.remove(cacheKey);
    _storesByModuleCache[cacheKey] = _TimedCache(result, DateTime.now());
    return result;
  }

  // Fetch latest stores for a module using /stores/latest?type=all
  Future<List<VendorModel>> getLatestStores({
    required int moduleId,
    String type = 'all',
  }) async {
    final cacheKey = '$moduleId|$type';
    final cached = _latestStoresCache[cacheKey];
    if (cached != null && cached.isFresh(_fastCacheTtl)) {
      return cached.value;
    }

    if (_latestStoresRequests.containsKey(cacheKey)) {
      return _latestStoresRequests[cacheKey]!;
    }

    Future<List<VendorModel>> loader() async {
      await _ensureLocationAndZone();
      final sw = Stopwatch()..start();
      try {
        final baseHeaders = _defaultHeaders();
        final headers = {...baseHeaders, 'moduleId': moduleId.toString()};
        if (kDebugMode) {
          // ignore: avoid_print
          print(
            '[API] GET /stores/latest params={type:$type} headers=${headers.toString()}',
          );
        }

        final res = await _dio.get(
          '/stores/latest',
          queryParameters: {'type': type},
          options: Options(headers: headers),
        );

        final data = res.data;
        if (data is List) {
          if (kDebugMode) {
            // ignore: avoid_print
            print('[API] /stores/latest - received ${data.length} records');
          }
          final list =
              data
                  .whereType<Map<String, dynamic>>()
                  .where(
                    (e) =>
                        e['module_id'] != null &&
                        int.tryParse(e['module_id'].toString()) == moduleId,
                  )
                  .map<VendorModel>(_vendorFromStore)
                  .toList();
          if (kDebugMode) {
            // ignore: avoid_print
            print(
              '[API] /stores/latest - filtered ${list.length} by moduleId=$moduleId',
            );
          }
          return list;
        }

        if (kDebugMode) {
          // ignore: avoid_print
          print(
            '[API][WARN] /stores/latest unexpected response shape: ${data.runtimeType}',
          );
        }
        return [];
      } on DioException catch (e) {
        if (kDebugMode) {
          // ignore: avoid_print
          print(
            '[API][ERROR] latest stores DioException ${e.message ?? ''} status=${e.response?.statusCode?.toString() ?? ''} data=${e.response?.data?.toString() ?? ''}',
          );
        }
        return getStoresByModule(moduleId: moduleId, featured: false);
      } catch (e) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('[API][ERROR] latest stores ${e.toString()}');
        }
        return [];
      } finally {
        if (kDebugMode) {
          sw.stop();
          // ignore: avoid_print
          print(
            '[API][PERF] getLatestStores(moduleId=$moduleId, type=$type) took ${sw.elapsedMilliseconds}ms',
          );
        }
      }
    }

    final future = loader();
    _latestStoresRequests[cacheKey] = future;
    final result = await future;
    _latestStoresRequests.remove(cacheKey);
    _latestStoresCache[cacheKey] = _TimedCache(result, DateTime.now());
    return result;
  }

  // Fetch banners
  Future<List<BannerModel>> getBanners({bool featured = true}) async {
    await _ensureLocationAndZone();
    try {
      final res = await _dio.get(
        '/banners',
        queryParameters: {'featured': featured ? 1 : 0},
        options: Options(headers: _defaultHeaders()),
      );
      final data = res.data;
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().map((m) {
          final id = int.tryParse((m['id'] ?? 0).toString()) ?? 0;
          final image = (m['image'] ?? '').toString();
          final type = (m['type'] ?? '').toString();
          final d = (m['data'] ?? '').toString();
          final url =
              image.startsWith('http') ? image : '$_bannerImageBase$image';
          return BannerModel(id: id, imageUrl: url, type: type, data: d);
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // Get all vendors - returns dummy data
  // Store details (real API): GET /stores/details/{id} + reviews
  Future<vdm.VendorDetailModel?> getStoreDetails(
    String id, {
    int? moduleId,
  }) async {
    await _ensureLocationAndZone();
    final key = _detailCacheKey(id, moduleId);
    if (_storeDetailCache.containsKey(key)) {
      return _storeDetailCache[key];
    }
    if (_storeDetailRequests.containsKey(key)) {
      return _storeDetailRequests[key]!;
    }
    final future = _fetchVendorDetails(id, moduleId: moduleId);
    _storeDetailRequests[key] = future;
    final result = await future;
    _storeDetailRequests.remove(key);
    _storeDetailCache[key] = result;
    return result;
  }

  // Store reviews: GET /stores/reviews?store_id={id}
  // Backend route: GET /api/v1/stores/reviews?store_id={store_id}
  Future<List<ReviewModel>> getStoreReviews(
    String storeId, {
    int? moduleId,
  }) async {
    await _ensureLocationAndZone();
    try {
      final headers = _defaultHeaders();
      if (moduleId != null) headers['moduleId'] = moduleId.toString();
      if (kDebugMode) {
        // ignore: avoid_print
        print('====> API Call: /api/v1/stores/reviews?store_id=$storeId');
        print('Header: ${headers.toString()}');
      }
      final res = await _dio.get(
        '/stores/reviews',
        queryParameters: {'store_id': storeId},
        options: Options(headers: headers),
      );
      final data = res.data;

      // Some backends return a raw list, others wrap it in an object (e.g. { reviews: [...] }).
      List<dynamic>? rawList;
      if (data is List) {
        rawList = data;
      } else if (data is Map<String, dynamic>) {
        // Try common keys used to wrap collections
        final reviewsField = data['reviews'] ?? data['data'] ?? data['items'];
        if (reviewsField is List) {
          rawList = reviewsField;
        }
      }

      if (kDebugMode) {
        print('[API] store reviews rawList length: ${rawList?.length ?? 0}');
        if (rawList == null) {
          print('[API][WARN] store reviews response not a list or wrapped list. type=${data.runtimeType}');
          print('[API][WARN] Response data: $data');
        } else if (rawList.isNotEmpty) {
          print('[API] First review sample: ${rawList.first}');
        }
      }

      if (rawList == null) return const [];

      return rawList.whereType<Map<String, dynamic>>().map((m) {
        final id = (m['id'] ?? '').toString();
        
        // Try multiple possible customer-name fields
        String customer = 'Customer';
        if (m['customer'] is Map) {
          customer =
              (m['customer']['name'] ?? m['customer']['full_name'] ?? 'Customer')
                  .toString();
        } else if (m['name'] != null) {
          customer = m['name'].toString();
        } else if (m['customer_name'] != null) {
          customer = m['customer_name'].toString();
        }

        // Extract avatar from customer object or direct field
        String? avatar;
        if (m['customer'] is Map) {
          avatar = m['customer']['avatar']?.toString() ?? 
                   m['customer']['image']?.toString() ?? 
                   m['customer']['profile_image']?.toString();
        }
        if (avatar == null || avatar.isEmpty) {
          avatar = m['avatar']?.toString() ?? 
                   m['image']?.toString() ?? 
                   m['profile_image']?.toString();
        }
        if (avatar != null && (avatar.isEmpty || avatar == 'null')) {
          avatar = null;
        }

        final ratingStr =
            (m['rating'] ?? m['average_rating'] ?? m['rating_value'] ?? 0)
                .toString();
        final ratingVal = double.tryParse(ratingStr) ?? 0.0;

        final comment =
            (m['comment'] ?? m['review'] ?? m['feedback'] ?? m['message'] ?? '').toString();

        final createdAt =
            (m['created_at'] ?? m['date'] ?? m['createdAt'] ?? m['timestamp'] ?? '').toString();
        final dt = DateTime.tryParse(createdAt) ?? DateTime.now();

        if (kDebugMode && rawList != null && rawList.length <= 3) {
          final commentPreview = comment.length > 30 ? '${comment.substring(0, 30)}...' : comment;
          print('[API] Parsed review: id=$id, customer=$customer, rating=$ratingVal, comment=$commentPreview');
        }

        return ReviewModel(
          id: id,
          customerName: customer,
          rating: ratingVal,
          comment: comment,
          date: dt,
          avatar: avatar,
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[API][ERROR] store reviews ${e.toString()}');
      }
      return const [];
    }
  }

  // Store items: recommended
  Future<List<ProductModel>> getStoreItemsRecommended(
    String storeId, {
    int offset = 1,
    int limit = 50,
    int? moduleId,
  }) async {
    await _ensureLocationAndZone();
    final key = _itemsCacheKey(
      storeId,
      0,
      offset,
      limit,
      'recommended',
      moduleId,
    );
    return _cachedStoreItems(
      key,
      () => _fetchStoreItemsRecommended(
        storeId,
        offset: offset,
        limit: limit,
        moduleId: moduleId,
      ),
    );
  }

  // Store items: latest
  Future<List<ProductModel>> getStoreItemsLatest(
    String storeId, {
    int categoryId = 0,
    int offset = 1,
    int limit = 10,
    String type = 'all',
    int? moduleId,
  }) async {
    await _ensureLocationAndZone();
    final key = _itemsCacheKey(
      storeId,
      categoryId,
      offset,
      limit,
      type,
      moduleId,
    );
    return _cachedStoreItems(
      key,
      () => _fetchStoreItemsLatest(
        storeId,
        categoryId: categoryId,
        offset: offset,
        limit: limit,
        type: type,
        moduleId: moduleId,
      ),
    );
  }

  Future<List<ProductModel>> _fetchStoreItemsRecommended(
    String storeId, {
    int offset = 1,
    int limit = 50,
    int? moduleId,
  }) async {
    final headers = _defaultHeaders();
    if (moduleId != null) headers['moduleId'] = moduleId.toString();
    if (kDebugMode) {
      // ignore: avoid_print
      print(
        '====> API Call: /api/v1/items/recommended?store_id=$storeId&offset=$offset&limit=$limit',
      );
      print('Header: ${headers.toString()}');
    }
    final res = await _dio.get(
      '/items/recommended',
      queryParameters: {'store_id': storeId, 'offset': offset, 'limit': limit},
      options: Options(headers: headers),
    );
    final data = res.data;
    return _extractProductsFromResponse(data, '[API] /items/recommended');
  }

  Future<List<ProductModel>> _fetchStoreItemsLatest(
    String storeId, {
    int categoryId = 0,
    int offset = 1,
    int limit = 10,
    String type = 'all',
    int? moduleId,
  }) async {
    final headers = _defaultHeaders();
    if (moduleId != null) headers['moduleId'] = moduleId.toString();
    if (kDebugMode) {
      // ignore: avoid_print
      print(
        '====> API Call: /api/v1/items/latest?store_id=$storeId&category_id=$categoryId&offset=$offset&limit=$limit&type=$type',
      );
      print('Header: ${headers.toString()}');
    }
    final res = await _dio.get(
      '/items/latest',
      queryParameters: {
        'store_id': storeId,
        'category_id': categoryId,
        'offset': offset,
        'limit': limit,
        'type': type,
      },
      options: Options(headers: headers),
    );
    final data = res.data;
    return _extractProductsFromResponse(data, '[API] /items/latest');
  }

  Future<List<ProductModel>> _cachedStoreItems(
    String key,
    Future<List<ProductModel>> Function() fetcher,
  ) async {
    if (_storeItemsCache.containsKey(key)) {
      return _storeItemsCache[key]!;
    }
    if (_storeItemsRequests.containsKey(key)) {
      return _storeItemsRequests[key]!;
    }
    final future = fetcher();
    _storeItemsRequests[key] = future;
    try {
      final result = await future;
      _storeItemsCache[key] = result;
      return result;
    } finally {
      _storeItemsRequests.remove(key);
    }
  }

  // Get campaign items: GET /campaigns/item
  Future<List<ProductModel>> getCampaignItems({int? moduleId}) async {
    await _ensureLocationAndZone();
    final headers = _defaultHeaders();
    if (moduleId != null) headers['moduleId'] = moduleId.toString();
    if (kDebugMode) {
      // ignore: avoid_print
      print('====> API Call: /api/v1/campaigns/item');
      print('Header: ${headers.toString()}');
    }
    try {
      final res = await _dio.get(
        '/campaigns/item',
        options: Options(headers: headers),
      );
      final data = res.data;
      return _extractProductsFromResponse(data, '[API] /campaigns/item');
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[API][ERROR] campaign items ${e.toString()}');
      }
      return const [];
    }
  }

  // Get popular items: GET /items/popular?type=all
  Future<List<ProductModel>> getPopularItems({
    String type = 'all',
    int? moduleId,
  }) async {
    await _ensureLocationAndZone();
    final headers = _defaultHeaders();
    if (moduleId != null) headers['moduleId'] = moduleId.toString();
    if (kDebugMode) {
      // ignore: avoid_print
      print(
        '====> API Call: /api/v1/items/popular?type=$type',
      );
      print('Header: ${headers.toString()}');
    }
    try {
      final res = await _dio.get(
        '/items/popular',
        queryParameters: {'type': type},
        options: Options(headers: headers),
      );
      final data = res.data;
      return _extractProductsFromResponse(data, '[API] /items/popular');
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[API][ERROR] popular items ${e.toString()}');
      }
      return const [];
    }
  }

  // Submit contact - returns dummy response
  Future<ContactResponse> submitContact(ContactRequest request) async {
    await Future.delayed(const Duration(milliseconds: 800));

    return ContactResponse(
      success: true,
      ticketId: 'CNT-${DateTime.now().millisecondsSinceEpoch}',
      message: 'Thank you! Your message has been received.',
    );
  }

  // Get partner logos - returns dummy data
  List<String> getPartnerLogos() {
    return [
      'https://dummyimage.com/140x60/DC2626/fff&text=Partner+1',
      'https://dummyimage.com/140x60/DC2626/fff&text=Partner+2',
      'https://dummyimage.com/140x60/DC2626/fff&text=Partner+3',
      'https://dummyimage.com/140x60/DC2626/fff&text=Partner+4',
      'https://dummyimage.com/140x60/DC2626/fff&text=Partner+5',
      'https://dummyimage.com/140x60/DC2626/fff&text=Partner+6',
    ];
  }

  /// Parses schedules array from API response to businessHours Map
  /// Converts day numbers (0-6) to day names and formats times
  Map<String, String> _parseSchedulesToBusinessHours(dynamic schedulesData) {
    final Map<String, String> businessHours = {};
    
    if (schedulesData == null) {
      if (kDebugMode) {
        print('[API] No schedules data found in response');
      }
      return businessHours;
    }
    
    if (schedulesData is! List) {
      if (kDebugMode) {
        print('[API][WARN] schedules is not a List, got ${schedulesData.runtimeType}');
      }
      return businessHours;
    }
    
    // Day number to day name mapping (0=Sunday, 1=Monday, ..., 6=Saturday)
    const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    
    for (final schedule in schedulesData) {
      if (schedule is! Map<String, dynamic>) continue;
      
      final dayNum = schedule['day'];
      if (dayNum == null) continue;
      
      final dayIndex = (dayNum is int) ? dayNum : int.tryParse(dayNum.toString());
      if (dayIndex == null || dayIndex < 0 || dayIndex > 6) continue;
      
      final dayName = dayNames[dayIndex];
      
      // Parse opening and closing times
      final openingTimeStr = schedule['opening_time']?.toString() ?? '';
      final closingTimeStr = schedule['closing_time']?.toString() ?? '';
      
      if (openingTimeStr.isEmpty || closingTimeStr.isEmpty) continue;
      
      // Format time from "HH:MM:SS" or "HH:MM" to "HH:MM AM/PM"
      final openingTime = _formatTimeString(openingTimeStr);
      final closingTime = _formatTimeString(closingTimeStr);
      
      if (openingTime != null && closingTime != null) {
        businessHours[dayName] = '$openingTime - $closingTime';
      }
    }
    
    if (kDebugMode) {
      print('[API] Parsed ${businessHours.length} business hours from schedules');
    }
    
    return businessHours;
  }
  
  /// Formats time string from "HH:MM:SS" or "HH:MM" to "HH:MM AM/PM"
  String? _formatTimeString(String timeStr) {
    if (timeStr.isEmpty) return null;
    
    // Extract HH:MM part (first 5 characters)
    final timePart = timeStr.length >= 5 ? timeStr.substring(0, 5) : timeStr;
    final parts = timePart.split(':');
    
    if (parts.length < 2) return null;
    
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    
    // Convert to 12-hour format
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    
    return '$hour12:$minuteStr $period';
  }

  Future<vdm.VendorDetailModel?> _fetchVendorDetails(
    String id, {
    int? moduleId,
  }) async {
    try {
      final headers = _defaultHeaders();
      if (moduleId != null) headers['moduleId'] = moduleId.toString();
      if (kDebugMode) {
        // ignore: avoid_print
        print('====> API Call: /api/v1/stores/details/$id');
        print('Header: ${headers.toString()}');
      }
      final res = await _dio.get(
        '/stores/details/$id',
        options: Options(headers: headers),
      );
      final data = res.data;
      
      if (kDebugMode) {
        print('[API] Store details response status: ${res.statusCode}');
        print('[API] Store details response type: ${data.runtimeType}');
        if (data is Map) {
          print('[API] Store details keys: ${data.keys.take(10).toList()}');
          print('[API] Store ID in response: ${data['id']}');
          if (data.containsKey('schedules')) {
            print('[API] Schedules found: ${data['schedules']}');
          }
        }
      }
      
      if (data is Map<String, dynamic>) {
        // Check if the response indicates an error
        if (data.containsKey('error') || data.containsKey('message')) {
          if (kDebugMode) {
            print('[API][ERROR] Store details API returned error: ${data['error'] ?? data['message']}');
          }
          throw Exception('API error: ${data['error'] ?? data['message'] ?? 'Unknown error'}');
        }
        
        // Check if data is empty or invalid
        if (data.isEmpty || data['id'] == null) {
          if (kDebugMode) {
            print('[API][ERROR] Store details response is empty or missing ID');
          }
          return null;
        }
        
        final model = _vendorDetailFromStore(data);
        final headerModuleId =
            moduleId ?? int.tryParse((data['module_id'] ?? '').toString());
        
        // Parse schedules to businessHours
        final businessHours = _parseSchedulesToBusinessHours(data['schedules']);
        
        if (kDebugMode) {
          print('[API] Parsed vendor model: id=${model.id}, name=${model.name}');
          print('[API] Using moduleId: $headerModuleId');
          print('[API] Business hours parsed: ${businessHours.length} days');
        }
        
        // Fetch subresources in parallel to reduce perceived latency
        final results = await Future.wait([
          getStoreItemsRecommended(id, moduleId: headerModuleId),
          getStoreItemsLatest(id, moduleId: headerModuleId),
          getStoreReviews(id, moduleId: headerModuleId),
        ]);
        final recommended = results[0] as List<ProductModel>;
        final latest = results[1] as List<ProductModel>;
        final reviews = results[2] as List<ReviewModel>;
        
        if (kDebugMode) {
          print('[API] Fetched ${reviews.length} reviews for store: $id');
          if (reviews.isNotEmpty) {
            print('[API] First review: ${reviews.first.customerName} - ${reviews.first.rating} stars');
          }
        }
        final Map<String, ProductModel> unique = {};
        for (final p in recommended) {
          unique[p.id] = p;
        }
        for (final p in latest) {
          unique.putIfAbsent(p.id, () => p);
        }
        return vdm.VendorDetailModel(
          id: model.id,
          name: model.name,
          logoUrl: model.logoUrl,
          bannerUrl: model.bannerUrl,
          shortDescription: model.shortDescription,
          fullDescription: model.fullDescription,
          categories: model.categories,
          location: model.location,
          address: model.address,
          phone: model.phone,
          email: model.email,
          website: model.website,
          rating: model.rating,
          reviewCount: model.reviewCount,
          productCount: model.productCount,
          verified: model.verified,
          establishedDate: model.establishedDate,
          certifications: model.certifications,
          socialMedia: model.socialMedia,
          openingHours: model.openingHours,
          gallery: const [],
          totalReviews: reviews.length,
          businessHours: businessHours,
          amenities: const [],
          customerHighlights: const [],
          products: unique.values.toList(),
          reviews: reviews,
          establishedYear: model.establishedDate.year,
        );
      }
      if (kDebugMode) {
        // ignore: avoid_print
        print('[API][ERROR] store details: Response data is not a Map');
        print('[API][ERROR] Response type: ${data.runtimeType}');
        print('[API][ERROR] Response data: $data');
      }
      throw Exception('Invalid response format from store details API: expected Map, got ${data.runtimeType}');
    } on DioException catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print(
          '[API][ERROR] store details DioException ${e.message ?? ''} status=${e.response?.statusCode?.toString() ?? ''} data=${e.response?.data?.toString() ?? ''}',
        );
      }
      // For 404 errors, return null (vendor not found)
      // For other errors, throw to show error state
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to load vendor details: ${e.message ?? 'Unknown error'}');
    } catch (e, stackTrace) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[API][ERROR] store details exception: ${e.toString()}');
        print('[API][ERROR] Stack trace: $stackTrace');
      }
      // Return null to show "not found" instead of error state
      // This handles cases where the API returns unexpected formats or other errors
      return null;
    }
  }

  List<ProductModel> _extractProductsFromResponse(
    dynamic data,
    String logPrefix,
  ) {
    if (data is Map) {
      final rawList =
          (data['products'] is List)
              ? (data['products'] as List)
              : (data['items'] is List)
              ? (data['items'] as List)
              : (data['data'] is List)
              ? (data['data'] as List)
              : const [];
      if (kDebugMode) {
        // ignore: avoid_print
        print('$logPrefix parsed ${rawList.length} products');
      }
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(_productFromItem)
          .toList();
    }
    if (data is List) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('$logPrefix list size=${data.length}');
      }
      return data
          .whereType<Map<String, dynamic>>()
          .map(_productFromItem)
          .toList();
    }
    return const [];
  }
  String _itemsCacheKey(
    String storeId,
    int categoryId,
    int offset,
    int limit,
    String type,
    int? moduleId,
  ) {
    return '$storeId|$categoryId|$offset|$limit|$type|${moduleId ?? 'auto'}';
  }

  String _detailCacheKey(String storeId, int? moduleId) {
    return '$storeId|${moduleId ?? 'auto'}';
  }

  // --- Private helpers -------------------------------------------------------

  String _resolveModuleImage(String fileOrUrl) {
    if (fileOrUrl.isEmpty) {
      return 'https://dummyimage.com/600x400/DC2626/ffffff&text=Module';
    }
    if (fileOrUrl.startsWith('http')) return fileOrUrl;
    return ApiService._moduleImageBase + fileOrUrl;
  }

  String _resolveCategoryImage(String fileOrUrl) {
    if (fileOrUrl.isEmpty) {
      return 'https://dummyimage.com/600x400/DC2626/ffffff&text=Category';
    }
    if (fileOrUrl.startsWith('http')) return fileOrUrl;
    return ApiService._categoryImageBase + fileOrUrl;
  }

  VendorModel _vendorFromStore(Map<String, dynamic> s) {
    final id = s['id']?.toString() ?? '';
    final name = (s['name'] ?? '').toString();
    final logo = (s['logo'] ?? '').toString();
    final cover = (s['cover_photo'] ?? '').toString();
    final address = (s['address'] ?? '').toString();
    final phone = (s['phone'] ?? '').toString();
    final email = (s['email'] ?? '').toString();
    final rating = (s['avg_rating'] ?? 0).toString();
    final ratingVal = double.tryParse(rating) ?? 0.0;
    final ratingCount = int.tryParse((s['rating_count'] ?? 0).toString()) ?? 0;
    final distance =
        (s['distance'] != null)
            ? double.tryParse(s['distance'].toString())
            : null;

    String locationMeta = '';
    if (distance != null) {
      final km = (distance / 1000.0);
      // The API looks like meters; if it's already kilometers, this still reads fine
      locationMeta = '${km.toStringAsFixed(1)} km away';
    }

    final categoryIds = _parseCategoryIds(s['category_ids']);

    return VendorModel(
      id: id,
      name: name,
      logoUrl: _resolveStoreImage(logo),
      bannerUrl: _resolveStoreImage(cover.isNotEmpty ? cover : logo),
      shortDescription: address.isNotEmpty ? address : 'Featured store',
      fullDescription: address,
      categories: categoryIds,
      location: locationMeta.isNotEmpty ? locationMeta : 'Nearby',
      address: address,
      phone: phone,
      email: email,
      website: '',
      rating: ratingVal,
      reviewCount: ratingCount,
      productCount: int.tryParse((s['total_order'] ?? 0).toString()) ?? 0,
      verified:
          (s['active']?.toString() == '1') || (s['open']?.toString() == '1'),
      establishedDate:
          DateTime.tryParse((s['created_at'] ?? '').toString()) ??
          DateTime(2020, 1, 1),
      certifications: const <String>[],
      socialMedia: const <String, String>{},
      openingHours: (s['delivery_time'] ?? '').toString(),
    );
  }

  vdm.VendorDetailModel _vendorDetailFromStore(Map<String, dynamic> s) {
    final base = _vendorFromStore(s);
    return vdm.VendorDetailModel(
      id: base.id,
      name: base.name,
      logoUrl: base.logoUrl,
      bannerUrl: base.bannerUrl,
      shortDescription: base.shortDescription,
      fullDescription: base.fullDescription,
      categories: base.categories,
      location: base.location,
      address: base.address,
      phone: base.phone,
      email: base.email,
      website: base.website,
      rating: base.rating,
      reviewCount: base.reviewCount,
      productCount: base.productCount,
      verified: base.verified,
      establishedDate: base.establishedDate,
      certifications: base.certifications,
      socialMedia: base.socialMedia,
      openingHours: base.openingHours,
      gallery: const <String>[],
      totalReviews: base.reviewCount,
      businessHours: const <String, String>{},
      amenities: const <String>[],
      customerHighlights: List<String>.from((s['customerHighlights'] as List? ?? [])),
      products: const <ProductModel>[],
      reviews: const <ReviewModel>[],
      establishedYear: base.establishedDate.year,
    );
  }

  String _resolveStoreImage(String fileOrUrl) {
    if (fileOrUrl.isEmpty) {
      return 'https://dummyimage.com/600x400/DC2626/ffffff&text=Store';
    }
    if (fileOrUrl.startsWith('http')) return fileOrUrl;
    return ApiService._storeImageBase + fileOrUrl;
  }

  ProductModel _productFromItem(Map<String, dynamic> m) {
    final id = (m['id'] ?? '').toString();
    final name = (m['name'] ?? m['title'] ?? '').toString();
    final description =
        (m['description'] ?? m['short_description'] ?? '').toString();
    // price can be number or string
    double price = 0.0;
    final p = m['price'] ?? m['discounted_price'] ?? m['mrp'];
    if (p != null) price = double.tryParse(p.toString()) ?? 0.0;
    // image may be 'image', 'image_full_url', 'images'[0]
    String imageUrl = '';
    final img = m['image'] ?? m['image_full_url'];
    if (img != null && img.toString().isNotEmpty) {
      imageUrl = img.toString();
    } else if (m['images'] is List && (m['images'] as List).isNotEmpty) {
      final first = (m['images'] as List).first;
      if (first is String) {
        imageUrl = first;
      } else if (first is Map && first['image'] != null) {
        imageUrl = first['image'].toString();
      }
    }
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = ApiService._productImageBase + imageUrl;
    }
    final category =
        (m['category'] is Map)
            ? ((m['category']['name'] ?? '').toString())
            : (m['category_name'] ?? '').toString();
    final inStock = (m['stock']?.toString() ?? '1') != '0';
    final ratingVal =
        double.tryParse((m['avg_rating'] ?? m['rating'] ?? 0).toString()) ??
        0.0;
    final reviews =
        int.tryParse(
          (m['rating_count'] ?? m['reviews_count'] ?? 0).toString(),
        ) ??
        0;

    return ProductModel(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl:
          imageUrl.isNotEmpty
              ? imageUrl
              : 'https://dummyimage.com/600x400/DC2626/ffffff&text=Product',
      category: category.isNotEmpty ? category : 'General',
      inStock: inStock,
      rating: ratingVal,
      reviews: reviews,
    );
  }

  List<double>? _centroidFromGeoJson(dynamic coordinates) {
    try {
      final coords =
          (coordinates is Map && coordinates['coordinates'] != null)
              ? coordinates['coordinates']
              : coordinates;
      if (coords is List && coords.isNotEmpty) {
        final firstRing = coords.first;
        if (firstRing is List && firstRing.isNotEmpty) {
          double sumLat = 0;
          double sumLng = 0;
          int n = 0;
          for (final p in firstRing) {
            if (p is List && p.length >= 2) {
              final lng = (p[0] as num).toDouble();
              final lat = (p[1] as num).toDouble();
              sumLat += lat;
              sumLng += lng;
              n++;
            }
          }
          if (n > 0) {
            return [sumLat / n, sumLng / n];
          }
        }
      }
    } catch (_) {}
    return null;
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180.0);

  String _titleFromType(String moduleType) {
    final t = moduleType.toLowerCase();
    if (t.contains('food')) return 'Food Delivery';
    if (t.contains('pharmacy') || t.contains('medicine')) {
      return 'Healthcare';
    }
    if (t.contains('parcel')) return 'Parcel Services';
    if (t.contains('ecommerce')) return 'E-Commerce';
    if (t.contains('grocery')) return 'Grocery';
    return moduleType.isNotEmpty ? moduleType : 'Service';
  }

  String _fallbackDescription(String moduleType) {
    final t = moduleType.toLowerCase();
    if (t.contains('food')) {
      return 'Deliver meals from verified restaurants with live tracking.';
    }
    if (t.contains('pharmacy') || t.contains('medicine')) {
      return 'Book healthcare appointments and pharmacy deliveries.';
    }
    if (t.contains('parcel')) {
      return 'Manage first and last-mile parcel logistics for your business.';
    }
    if (t.contains('ecommerce')) {
      return 'Launch curated storefronts for retail and lifestyle products.';
    }
    if (t.contains('grocery')) {
      return 'Offer essentials through hyperlocal grocery partners.';
    }
    return 'Discover full-stack capabilities tailored for local commerce.';
  }

  String _summarize(String text, int maxChars) {
    final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.length <= maxChars) return clean;
    return '${clean.substring(0, maxChars - 1).trimRight()}…';
  }

  List<String> _parseCategoryIds(dynamic source) {
    if (source == null) return const [];
    if (source is List) {
      return source
          .map((entry) {
            if (entry is Map<String, dynamic>) {
              final id = entry['id']?.toString() ?? '';
              return id;
            }
            return entry?.toString() ?? '';
          })
          .where((id) => id.isNotEmpty)
          .toList();
    }
    if (source is String && source.isNotEmpty) {
      try {
        final decoded = jsonDecode(source);
        return _parseCategoryIds(decoded);
      } catch (_) {
        return source
            .split(',')
            .map((raw) => raw.trim())
            .where((id) => id.isNotEmpty)
            .toList();
      }
    }
    return const [];
  }

  Future<List<ModuleModel>> getModules() async {
    if (_cachedModules != null && _modulesCachedAt != null) {
      final fresh =
          DateTime.now().difference(_modulesCachedAt!) < _cacheTtl;
      if (fresh) return _cachedModules!;
    }

    try {
      final res = await _dio.get('/module');
      final data = res.data;
      if (data is List) {
        final modules =
            data
                .whereType<Map<String, dynamic>>()
                .map((raw) {
                  final model = ModuleModel.fromJson(raw);
                  final image = _resolveModuleImage(model.imageUrl);
                  final name =
                      model.name.isNotEmpty
                          ? model.name
                          : _titleFromType(model.moduleType);
                  final description =
                      model.description.isNotEmpty
                          ? _summarize(model.description, 140)
                          : _fallbackDescription(model.moduleType);
                  return ModuleModel(
                    id: model.id,
                    name: name,
                    description: description,
                    imageUrl: image,
                    moduleType: model.moduleType,
                  );
                })
                .toList();
        _cachedModules = modules;
        _modulesCachedAt = DateTime.now();
        return modules;
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[API][ERROR] getModules ${e.toString()}');
      }
    }

    return const [];
  }
}
