import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/responsive/responsive_breakpoints.dart';
import '../../core/theme/premium_theme.dart';
import '../../core/providers/api_provider.dart';
import '../../core/models/vendor_model.dart';
import '../../core/util/global_keyboard_scroll_handler.dart';
import '../../shared/layout/premium_section.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/vendor_card.dart';
import '../../core/data/ap_ts_location_filters.dart';

class VendorsPage extends ConsumerStatefulWidget {
  static const int _defaultModuleId = 1;
  final int? moduleId; // optional: pass via route query param

  const VendorsPage({super.key, this.moduleId});

  @override
  ConsumerState<VendorsPage> createState() => _VendorsPageState();
}

class _VendorsPageState extends ConsumerState<VendorsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  static const double _scrollStep = 100.0;
  String _searchQuery = '';
  bool _showAllStores = false; // Toggle for View More/Less stores
  bool _showAllCategories = false; // Toggle for View More/Less categories
  static const int _initialDisplayCount = 10;

  String _selectedState = kAllStatesLabel;
  String _selectedCity = kAllCitiesLabel;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _setupKeyboardNavigation();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    KeyboardController.onUp = null;
    KeyboardController.onDown = null;
    KeyboardController.onLeft = null;
    KeyboardController.onRight = null;
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  List<VendorModel> _filterVendors(List<VendorModel> vendors) {
    return vendors.where((vendor) {
      final locOk = vendorMatchesLocationFilter(
        location: vendor.location,
        address: vendor.address,
        selectedState:
            _selectedState == kAllStatesLabel ? null : _selectedState,
        selectedCity:
            _effectiveCityForFilter == kAllCitiesLabel
                ? null
                : _effectiveCityForFilter,
      );
      if (!locOk) return false;
      if (_searchQuery.isEmpty) return true;
      return vendor.name.toLowerCase().contains(_searchQuery) ||
          vendor.shortDescription.toLowerCase().contains(_searchQuery) ||
          vendor.location.toLowerCase().contains(_searchQuery) ||
          vendor.address.toLowerCase().contains(_searchQuery) ||
          vendor.categories.any(
            (cat) => cat.toLowerCase().contains(_searchQuery),
          );
    }).toList();
  }

  bool get _hasLocationFilter =>
      _selectedState != kAllStatesLabel ||
      _effectiveCityForFilter != kAllCitiesLabel;

  /// Keeps filter logic valid if city list changes (e.g. after state change).
  String get _effectiveCityForFilter {
    final opts = citiesForPartnerState(_selectedState);
    return opts.contains(_selectedCity) ? _selectedCity : kAllCitiesLabel;
  }

  void _onStateChanged(String? value) {
    if (value == null) return;
    setState(() {
      _selectedState = value;
      _selectedCity = kAllCitiesLabel;
    });
  }

  void _onCityChanged(String? value) {
    if (value == null) return;
    setState(() {
      _selectedCity = value;
    });
  }

  Widget _buildStateDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedState,
      decoration: InputDecoration(
        labelText: 'State',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: PremiumTheme.lightGrey,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      isExpanded: true,
      items:
          kPartnerStateOptions
              .map(
                (s) => DropdownMenuItem<String>(
                  value: s,
                  child: Text(s, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
      onChanged: _onStateChanged,
    );
  }

  Widget _buildCityDropdown(BuildContext context) {
    final cityOptions = citiesForPartnerState(_selectedState);

    return DropdownButtonFormField<String>(
      value: _effectiveCityForFilter,
      decoration: InputDecoration(
        labelText: 'City',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: PremiumTheme.lightGrey,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      isExpanded: true,
      items:
          cityOptions
              .map(
                (c) => DropdownMenuItem<String>(
                  value: c,
                  child: Text(c, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
      onChanged: _selectedState == kAllStatesLabel ? null : _onCityChanged,
    );
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

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveBreakpoints.getHorizontalPadding(context);
    final columns = ResponsiveBreakpoints.getGridColumns(context);
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);
    final vendorCardHeight = _vendorCardHeight(
      isMobile: isMobile,
      isTablet: isTablet,
    );

    final resolvedModuleId = widget.moduleId ?? VendorsPage._defaultModuleId;
    final categoriesAsync = ref.watch(categoriesProvider(resolvedModuleId));
    // Use storesByModuleProvider to get all stores (loaded initially, up to 500)
    final vendorsAsync = ref.watch(storesByModuleProvider(resolvedModuleId));

    return PrimaryScrollController(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // PremiumSection(
            //   backgroundGradient: PremiumTheme.darkGradient,
            //   padding: EdgeInsets.symmetric(
            //     horizontal: padding,
            //     vertical: isMobile ? 40 : 80,
            //   ),
            //   child: _buildHero(context, isMobile),
            // ),
            PremiumSection(
              backgroundColor: PremiumTheme.pureWhite,
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: isMobile ? 24 : 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Module Header
                  Padding(
                    padding: EdgeInsets.only(bottom: isMobile ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Stores',
                          style: Theme.of(
                            context,
                          ).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: isMobile ? 28 : 36,
                            color: PremiumTheme.darkBlack,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Browse all stores in this module',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: PremiumTheme.mediumGrey),
                        ),
                      ],
                    ),
                  ),
                  categoriesAsync.when(
                    data: (cats) {
                      if (cats.isEmpty) return const SizedBox.shrink();

                      // Show 10 categories initially, all when toggled
                      final displayCount =
                          _showAllCategories
                              ? cats.length
                              : _initialDisplayCount;
                      final categoriesToShow = cats.take(displayCount).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SectionHeader(
                            title: 'Browse Categories',
                            subtitle: 'Find what you need faster',
                            centerAlign: false,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children:
                                categoriesToShow.map((c) {
                                  return _CategoryChip(
                                    name: c.name,
                                    imageUrl: c.image,
                                    onTap:
                                        () => context.go('/categories/${c.id}'),
                                  );
                                }).toList(),
                          ),
                          // View More / View Less button for categories
                          if (cats.length > _initialDisplayCount)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Center(
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _showAllCategories = !_showAllCategories;
                                    });
                                  },
                                  icon: Icon(
                                    _showAllCategories
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                  ),
                                  label: Text(
                                    _showAllCategories
                                        ? 'View Less Categories'
                                        : 'View More Categories (${cats.length - _initialDisplayCount} more)',
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: PremiumTheme.primaryRed,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 20 : 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 32),
                        ],
                      );
                    },
                    loading:
                        () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: LinearProgressIndicator(minHeight: 2),
                        ),
                    error:
                        (e, _) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text('Categories error: $e'),
                        ),
                  ),
                  // Search Bar (always visible)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: PremiumTheme.lightGrey,
                      borderRadius: PremiumTheme.mediumRadius,
                      border: Border.all(
                        color:
                            _searchQuery.isNotEmpty
                                ? PremiumTheme.primaryRed.withValues(alpha: 0.5)
                                : PremiumTheme.lightGrey,
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText:
                            'Search stores by name, location, or category...',
                        prefixIcon: Icon(
                          Icons.search,
                          color:
                              _searchQuery.isNotEmpty
                                  ? PremiumTheme.primaryRed
                                  : PremiumTheme.mediumGrey,
                          size: 24,
                        ),
                        suffixIcon:
                            _searchQuery.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
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
                  ),
                  // === State & city filters (Andhra Pradesh / Telangana) ===
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child:
                        isMobile
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildStateDropdown(context),
                                const SizedBox(height: 12),
                                _buildCityDropdown(context),
                              ],
                            )
                            : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildStateDropdown(context)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildCityDropdown(context)),
                              ],
                            ),
                  ),
                  vendorsAsync.when(
                    data: (vendors) {
                      // All stores are loaded initially (up to 500)
                      final filteredVendors = _filterVendors(vendors);

                      if (vendors.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(80),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.store_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No stores found for this module',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    color: PremiumTheme.mediumGrey,
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
                          // Results count
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _searchQuery.isEmpty && !_hasLocationFilter
                                      ? '${vendors.length} Store${vendors.length > 1 ? 's' : ''} Available'
                                      : '${filteredVendors.length} of ${vendors.length} Store${filteredVendors.length != 1 ? 's' : ''} Found',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: PremiumTheme.darkBlack,
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty ||
                                    _hasLocationFilter)
                                  TextButton.icon(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                        _selectedState = kAllStatesLabel;
                                        _selectedCity = kAllCitiesLabel;
                                      });
                                    },
                                    icon: const Icon(Icons.clear_all, size: 18),
                                    label: const Text('Clear'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: PremiumTheme.primaryRed,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Filtered results or empty state
                          if (filteredVendors.isEmpty &&
                              (_searchQuery.isNotEmpty || _hasLocationFilter))
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(60),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 64,
                                      color: PremiumTheme.mediumGrey,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No stores found',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.copyWith(
                                        color: PremiumTheme.darkBlack,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _hasLocationFilter
                                          ? 'Try another state or city, or clear filters'
                                          : 'Try different keywords or check spelling',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        color: PremiumTheme.mediumGrey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else ...[
                            // Display stores (10 initially, all when toggled)
                            Builder(
                              builder: (context) {
                                final displayCount =
                                    _searchQuery.isEmpty &&
                                            !_hasLocationFilter &&
                                            !_showAllStores
                                        ? _initialDisplayCount
                                        : filteredVendors.length;
                                final storesToShow =
                                    filteredVendors.take(displayCount).toList();

                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: isMobile ? 1 : 4,
                                        crossAxisSpacing: isMobile ? 12 : 24,
                                        mainAxisSpacing: isMobile ? 12 : 24,
                                        mainAxisExtent: isMobile ? 220 : 260,
                                      ),
                                  itemCount: storesToShow.length,
                                  itemBuilder: (context, index) {
                                    return VendorCard(
                                      vendor: storesToShow[index],
                                      moduleId: resolvedModuleId,
                                      onTap: () {
                                        final moduleIdParam =
                                            '?moduleId=$resolvedModuleId';
                                        context.push(
                                          '/vendor/${storesToShow[index].id}$moduleIdParam',
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                            // View More / View Less button (only when not searching and more than 10 stores)
                            if (_searchQuery.isEmpty &&
                                !_hasLocationFilter &&
                                filteredVendors.length > _initialDisplayCount)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Center(
                                  child: TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _showAllStores = !_showAllStores;
                                      });
                                    },
                                    icon: Icon(
                                      _showAllStores
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                    ),
                                    label: Text(
                                      _showAllStores
                                          ? 'View Less'
                                          : 'View More (${filteredVendors.length - _initialDisplayCount} more)',
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: PremiumTheme.primaryRed,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 20 : 24,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ],
                      );
                    },
                    loading:
                        () => _VendorSkeletonGrid(
                          columns: columns,
                          isMobile: isMobile,
                          cardHeight: vendorCardHeight,
                        ),
                    error:
                        (error, stack) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(80),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading stores: $error',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                  ),
                ],
              ),
            ),

            PremiumSection(
              backgroundGradient: PremiumTheme.redGradient,
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 72),
              child: _VendorCta(isMobile: isMobile),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget _buildHero(BuildContext context, bool isMobile) {
//   final stats = [
//     {'value': '1200+', 'label': 'Live products'},
//     {'value': '98%', 'label': 'Verification score'},
//     {'value': '45+', 'label': 'Cities onboarded'},
//   ];
//   final badges = ['Retail', 'Hyperlocal', 'Healthcare', 'Logistics'];
//   final insights = [
//     {'title': 'Pre-vetted KYC', 'desc': 'Documents, licenses, GST verified'},
//     {'title': 'One contract', 'desc': 'Single SLA across modules'},
//     {'title': 'Launch support', 'desc': 'Local ground team + playbooks'},
//   ];

//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         'Partner marketplace',
//         style: Theme.of(context).textTheme.labelLarge?.copyWith(
//           color: Colors.white70,
//           letterSpacing: 2,
//         ),
//       ),
//       const SizedBox(height: 12),
//       Text(
//         'Discover & partner with local businesses',
//         style: Theme.of(context).textTheme.displaySmall?.copyWith(
//           color: Colors.white,
//           fontSize: isMobile ? 32 : 44,
//         ),
//       ),
//       const SizedBox(height: 12),
//       Text(
//         'Browse verified vendors, explore curated categories, and open new channels for service delivery.',
//         style: Theme.of(
//           context,
//         ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
//       ),
//       const SizedBox(height: 28),
//       Wrap(
//         spacing: 12,
//         runSpacing: 12,
//         children:
//             badges
//                 .map(
//                   (badge) => Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(999),
//                       color: Colors.white.withValues(alpha: 0.1),
//                       border: Border.all(
//                         color: Colors.white.withValues(alpha: 0.15),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(Icons.check, size: 16, color: Colors.white),
//                         const SizedBox(width: 6),
//                         Text(
//                           badge,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//                 .toList(),
//       ),
//       const SizedBox(height: 28),
//       Wrap(
//         spacing: 16,
//         runSpacing: 16,
//         children:
//             stats
//                 .map(
//                   (stat) => _VendorHeroStat(
//                     value: stat['value']!,
//                     label: stat['label']!,
//                   ),
//                 )
//                 .toList(),
//       ),
//       const SizedBox(height: 28),
//       Wrap(
//         spacing: 12,
//         runSpacing: 12,
//         children: [
//           ElevatedButton.icon(
//             onPressed: () => context.go('/contact'),
//             icon: const Icon(Icons.handshake),
//             label: const Text('Join as a Partner'),
//             style: ElevatedButton.styleFrom(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isMobile ? 16 : 24,
//                 vertical: 16,
//               ),
//             ),
//           ),
//           OutlinedButton.icon(
//             onPressed: () => context.go('/vendors'),
//             icon: const Icon(Icons.grid_view),
//             label: const Text('Explore Modules'),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: Colors.white,
//               side: const BorderSide(color: Colors.white, width: 1.5),
//               padding: EdgeInsets.symmetric(
//                 horizontal: isMobile ? 16 : 24,
//                 vertical: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//       const SizedBox(height: 32),
//       Container(
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: Colors.white.withValues(alpha: 0.08),
//           borderRadius: PremiumTheme.largeRadius,
//           border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children:
//               insights
//                   .map(
//                     (insight) => Padding(
//                       padding: const EdgeInsets.only(bottom: 12),
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.brightness_1,
//                             size: 10,
//                             color: Colors.white70,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   insight['title']!,
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   insight['desc']!,
//                                   style: const TextStyle(color: Colors.white70),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                   .toList(),
//         ),
//       ),
//     ],
//   );
// }

class _CategoryChip extends StatefulWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.name,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient:
                isHovered
                    ? LinearGradient(
                      colors: [
                        Colors.purpleAccent.withOpacity(0.8),
                        Colors.deepPurple.withOpacity(0.8),
                      ],
                    )
                    : null,
            border:
                isHovered
                    ? null
                    : Border.all(color: Colors.grey.shade300, width: 1.2),
            boxShadow:
                isHovered
                    ? [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [],
            color: isHovered ? null : Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: NetworkImage(widget.imageUrl),
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(width: 8),
              Text(
                widget.name,
                style: TextStyle(
                  color: isHovered ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VendorCta extends StatelessWidget {
  final bool isMobile;

  const _VendorCta({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Want to become a partner?',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontSize: isMobile ? 28 : 36,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Join our network of trusted vendors and grow your business with enterprise-grade tooling and support.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => context.go('/contact'),
              icon: const Icon(Icons.person_add),
              label: const Text('Apply Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: PremiumTheme.primaryRed,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 18 : 28,
                  vertical: 16,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/vendors'),
              icon: const Icon(Icons.download),
              label: const Text('Download Deck'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 1.5),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 18 : 28,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

double _vendorCardHeight({required bool isMobile, required bool isTablet}) {
  if (isMobile) return 240; // Significantly reduced from 360
  if (isTablet) return 320; // Reduced from 400
  return 380; // Reduced from 430
}

class _VendorSkeletonGrid extends StatelessWidget {
  final int columns;
  final bool isMobile;
  final double cardHeight;
  const _VendorSkeletonGrid({
    required this.columns,
    required this.isMobile,
    required this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    final count = (columns * 2).clamp(2, 8).toInt();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: isMobile ? 16 : 24,
        mainAxisSpacing: isMobile ? 16 : 24,
        childAspectRatio: isMobile ? 0.75 : 0.85,
      ),
      itemCount: count,
      itemBuilder:
          (_, __) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PremiumTheme.lightGrey),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: PremiumTheme.lightGrey,
                    borderRadius: BorderRadius.circular(36),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 12,
                  width: double.infinity,
                  color: PremiumTheme.lightGrey,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: double.infinity,
                  color: PremiumTheme.lightGrey.withValues(alpha: 0.7),
                ),
                const Spacer(),
                Container(
                  height: 36,
                  width: double.infinity,
                  color: PremiumTheme.lightGrey,
                ),
              ],
            ),
          ),
    );
  }
}
