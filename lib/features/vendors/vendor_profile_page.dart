import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/responsive/responsive_breakpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/api_provider.dart';
import '../../shared/widgets/product_card.dart';
import '../../shared/widgets/network_circle_avatar.dart';
import '../../core/models/vendor_detail_model.dart';
import 'package:intl/intl.dart';

class VendorProfilePage extends ConsumerStatefulWidget {
  final String vendorId;
  
  const VendorProfilePage({
    super.key,
    required this.vendorId,
  });

  @override
  ConsumerState<VendorProfilePage> createState() => _VendorProfilePageState();
}

class _VendorProfilePageState extends ConsumerState<VendorProfilePage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _coverImageForVendor(VendorDetailModel vendor) {
    for (final candidate in [
      if (vendor.gallery.isNotEmpty) vendor.gallery.first,
      vendor.bannerUrl,
      vendor.logoUrl,
    ]) {
      if (_hasValidImage(candidate)) {
        return candidate.trim();
      }
    }
    return 'https://dummyimage.com/1200x600/111827/ffffff&text=Store';
  }

  bool _hasValidImage(String? url) {
    if (url == null) return false;
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    final lower = trimmed.toLowerCase();
    return lower != 'null' && lower != 'undefined';
  }

  @override
  Widget build(BuildContext context) {
    final vendorAsync = ref.watch(vendorDetailProvider(VendorDetailArgs(id: widget.vendorId)));
    final padding = ResponsiveBreakpoints.getHorizontalPadding(context);
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final columns = ResponsiveBreakpoints.getGridColumns(context);

    return Scaffold(
      body: vendorAsync.when(
        data: (vendor) {
          if (vendor == null) {
            return const Center(child: Text('No details found'));
          }
          final bannerImage = _coverImageForVendor(vendor);
          return SingleChildScrollView(
            child: Column(
              children: [
                // Banner with logo overlay
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Banner Image
                    Container(
                      width: double.infinity,
                      height: isMobile ? 200 : 300,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(bannerImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Logo and basic info
                    Positioned(
                      bottom: -60,
                      left: padding,
                      right: padding,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Logo
                          Container(
                            width: isMobile ? 100 : 120,
                            height: isMobile ? 100 : 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                vendor.logoUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          
                          if (!isMobile) ...[
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          vendor.name,
                                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      if (vendor.verified)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.verified,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Verified',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    vendor.shortDescription,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Back button
                    Positioned(
                      top: 40,
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.5),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 80),
                
                // Mobile title (if mobile)
                if (isMobile) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                vendor.name,
                                style: Theme.of(context).textTheme.headlineLarge,
                              ),
                            ),
                            if (vendor.verified)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'Verified',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          vendor.shortDescription,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Stats Row
                Container(
                  padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: Icons.star,
                        value: vendor.rating.toString(),
                        label: 'Rating',
                        isMobile: isMobile,
                      ),
                      _StatItem(
                        icon: Icons.rate_review,
                        value: vendor.reviewCount.toString(),
                        label: 'Reviews',
                        isMobile: isMobile,
                      ),
                      _StatItem(
                        icon: Icons.inventory_2,
                        value: vendor.productCount.toString(),
                        label: 'Products',
                        isMobile: isMobile,
                      ),
                      _StatItem(
                        icon: Icons.schedule,
                        value: '${DateTime.now().year - vendor.establishedDate.year}+',
                        label: 'Years',
                        isMobile: isMobile,
                      ),
                    ],
                  ),
                ),
                
                const Divider(),
                
                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.brandRed,
                  unselectedLabelColor: AppTheme.greyText,
                  indicatorColor: AppTheme.brandRed,
                  tabs: const [
                    Tab(text: 'Products'),
                    Tab(text: 'About'),
                    Tab(text: 'Reviews'),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Tab Content
                SizedBox(
                  height: 800,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Products Tab
                      _ProductsTab(
                        products: vendor.products,
                        padding: padding,
                        columns: columns,
                        isMobile: isMobile,
                      ),
                      
                      // About Tab
                      _AboutTab(vendor: vendor, padding: padding),
                      
                      // Reviews Tab
                      _ReviewsTab(
                        reviews: vendor.reviews,
                        padding: padding,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Error loading vendor: $error'),
          ),
        ),
      ),
    );
  }

}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isMobile;
  
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.brandRed, size: isMobile ? 24 : 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: isMobile ? 18 : 24,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: isMobile ? 12 : 14,
          ),
        ),
      ],
    );
  }
}

class _ProductsTab extends StatelessWidget {
  final List<dynamic> products;
  final double padding;
  final int columns;
  final bool isMobile;
  
  const _ProductsTab({
    required this.products,
    required this.padding,
    required this.columns,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(
        child: Text('No products available'),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: isMobile ? 0.65 : 0.7,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(product: products[index]);
        },
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  final dynamic vendor;
  final double padding;
  
  const _AboutTab({
    required this.vendor,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Us',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            vendor.fullDescription,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          
          Text(
            'Contact Information',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          _InfoRow(icon: Icons.location_on, text: vendor.address),
          _InfoRow(icon: Icons.phone, text: vendor.phone),
          _InfoRow(icon: Icons.email, text: vendor.email),
          _InfoRow(icon: Icons.language, text: vendor.website),
          _InfoRow(icon: Icons.access_time, text: vendor.openingHours),
          
          const SizedBox(height: 32),
          
          if (vendor.certifications.isNotEmpty) ...[
            Text(
              'Certifications',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: vendor.certifications.map<Widget>((cert) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.brandRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.brandRed.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, color: AppTheme.brandRed, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        cert,
                        style: const TextStyle(
                          color: AppTheme.brandRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],
          
          Text(
            'Categories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vendor.categories.map<Widget>((category) {
              return Chip(
                label: Text(category),
                backgroundColor: AppTheme.lightGrey,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  
  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.greyText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  final List<dynamic> reviews;
  final double padding;
  
  const _ReviewsTab({
    required this.reviews,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Center(child: Text('No reviews yet'));
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: padding),
      itemCount: reviews.length,
      separatorBuilder: (context, index) => const Divider(height: 32),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return _ReviewCard(review: review);
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final dynamic review;
  
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            NetworkCircleAvatar(
              imageUrl: (review.avatar as String?) ?? '',
              radius: 24,
              backgroundColor: AppTheme.brandRed,
              fallback: Text(
                (review.customerName.isNotEmpty ? review.customerName[0] : '?').toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.customerName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < review.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM dd, yyyy').format(review.date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          review.comment,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
