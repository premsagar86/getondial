// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../core/responsive/responsive_breakpoints.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/theme/premium_theme.dart';
// import '../../core/providers/api_provider.dart';
// import '../../core/models/module_model.dart';
// import '../../core/models/testimonial_model.dart';
// import '../../shared/widgets/hero_section.dart';
// import '../../shared/widgets/section_header.dart';
// import '../../shared/widgets/partner_logo_slider.dart';
// import '../../shared/widgets/testimonial_card.dart';
// import '../../shared/widgets/animated_counter.dart';

// class EnhancedHomePage extends ConsumerWidget {
//   const EnhancedHomePage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final modulesAsync = ref.watch(modulesProvider);
//     final partnerLogos = ref.watch(partnerLogosProvider);
//     final padding = ResponsiveBreakpoints.getHorizontalPadding(context);
//     final isMobile = ResponsiveBreakpoints.isMobile(context);
//     final isDesktop = ResponsiveBreakpoints.isDesktop(context);

//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           // Hero Section
//           HeroSection(
//             title: 'Your Complete Service Partner',
//             subtitle:
//                 'Food • Healthcare • Jobs • Delivery • Shopping - All in One Platform',
//             imageUrl:
//                 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f',
//             primaryActionText: 'Get Started',
//             secondaryActionText: 'Explore Partners',
//             onPrimaryAction: () => context.go('/contact'),
//             onSecondaryAction: () => context.go('/vendors'),
//           ),

//           const SizedBox(height: 40),

//           // Modules Section
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: padding),
//             child: Column(
//               children: [
//                 SectionHeader(
//                   title: 'Integrated Modules',
//                   subtitle: 'Powered directly from the Get On Dial platform',
//                   centerAlign: isMobile,
//                 ),
//                 const SizedBox(height: 24),
//                 modulesAsync.when(
//                   data: (modules) {
//                     if (modules.isEmpty) {
//                       return Container(
//                         padding: const EdgeInsets.all(32),
//                         decoration: BoxDecoration(
//                           color: AppTheme.lightGrey,
//                           borderRadius: BorderRadius.circular(18),
//                         ),
//                         child: const Text(
//                           'Modules are on the way. Please check back soon.',
//                           textAlign: TextAlign.center,
//                         ),
//                       );
//                     }
//                     final display = modules.take(isMobile ? 3 : 6).toList();
//                     return Wrap(
//                       spacing: 20,
//                       runSpacing: 20,
//                       children:
//                           display.map((module) {
//                             return _ModuleCard(
//                               module: module,
//                               isMobile: isMobile,
//                             );
//                           }).toList(),
//                     );
//                   },
//                   loading:
//                       () => const Padding(
//                         padding: EdgeInsets.all(32),
//                         child: CircularProgressIndicator(),
//                       ),
//                   error:
//                       (error, _) => Container(
//                         padding: const EdgeInsets.all(24),
//                         decoration: BoxDecoration(
//                           color: AppTheme.lightGrey,
//                           borderRadius: BorderRadius.circular(18),
//                         ),
//                         child: Text(
//                           'Failed to load modules: $error',
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 32),

//           // Features Highlight
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: padding, vertical: 60),

//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SectionHeader(
//                   title: 'Why Choose Us?',
//                   subtitle: 'Experience excellence in every service we offer',
//                   centerAlign: true,
//                 ),
//                 const SizedBox(height: 50),

//                 // ✅ Wrap in LayoutBuilder to constrain and shrink properly
//                 LayoutBuilder(
//                   builder: (context, constraints) {
//                     return ConstrainedBox(
//                       constraints: BoxConstraints(
//                         maxWidth: constraints.maxWidth,
//                       ),
//                       child: _FeaturesGrid(
//                         isMobile: isMobile,
//                         isDesktop: isDesktop,
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 80),

//           // Statistics Section
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: padding, vertical: 60),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   AppTheme.brandRed,
//                   AppTheme.brandRed.withValues(alpha: 0.8),
//                 ],
//               ),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   'Trusted by Thousands',
//                   style: Theme.of(context).textTheme.displayMedium?.copyWith(
//                     color: Colors.white,
//                     fontSize: isMobile ? 28 : 36,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Join our growing community of satisfied customers',
//                   style: Theme.of(
//                     context,
//                   ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 48),
//                 Wrap(
//                   spacing: 40,
//                   runSpacing: 32,
//                   alignment: WrapAlignment.center,
//                   children: [
//                     _StatBox(
//                       value: 50000,
//                       suffix: '+',
//                       label: 'Happy Customers',
//                       icon: Icons.people,
//                       isMobile: isMobile,
//                     ),
//                     _StatBox(
//                       value: 1000,
//                       suffix: '+',
//                       label: 'Partner Businesses',
//                       icon: Icons.business,
//                       isMobile: isMobile,
//                     ),
//                     _StatBox(
//                       value: 100,
//                       suffix: '+',
//                       label: 'Cities Covered',
//                       icon: Icons.location_city,
//                       isMobile: isMobile,
//                     ),
//                     _StatBox(
//                       value: 99,
//                       suffix: '%',
//                       label: 'Customer Satisfaction',
//                       icon: Icons.sentiment_very_satisfied,
//                       isMobile: isMobile,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 80),

//           // Testimonials Section
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: padding),
//             child: Column(
//               children: [
//                 SectionHeader(
//                   title: 'What Our Customers Say',
//                   subtitle: 'Real experiences from real people',
//                   centerAlign: true,
//                 ),
//                 const SizedBox(height: 40),
//                 SizedBox(
//                   height: isMobile ? 340 : 300,
//                   child: LayoutBuilder(
//                     builder: (context, constraints) {
//                       final testimonials = _getDummyTestimonials();
//                       final cardWidth =
//                           isMobile
//                               ? constraints.maxWidth * 0.85
//                               : (constraints.maxWidth / (isDesktop ? 3 : 2)) -
//                                   16;
//                       return ListView.separated(
//                         scrollDirection: Axis.horizontal,
//                         physics: const BouncingScrollPhysics(),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: isMobile ? 8 : 0,
//                         ),
//                         itemCount: testimonials.length,
//                         separatorBuilder: (_, __) => const SizedBox(width: 16),
//                         itemBuilder: (context, index) {
//                           return SizedBox(
//                             width: cardWidth.clamp(260, 360),
//                             child: TestimonialCard(
//                               testimonial: testimonials[index],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 80),

//           PartnerLogoSlider(logoUrls: partnerLogos),
//           const SizedBox(height: 80),

//           // How It Works Section
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: padding, vertical: 60),
//             color: AppTheme.lightGrey,
//             child: Column(
//               children: [
//                 SectionHeader(
//                   title: 'How It Works',
//                   subtitle: 'Get started in 3 simple steps',
//                   centerAlign: true,
//                 ),
//                 const SizedBox(height: 48),
//                 _HowItWorksSection(isMobile: isMobile),
//               ],
//             ),
//           ),

//           const SizedBox(height: 80),

//           // App Features Section
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: padding),
//             child: Column(
//               children: [
//                 SectionHeader(
//                   title: 'Platform Features',
//                   subtitle: 'Everything you need in one app',
//                   centerAlign: true,
//                 ),
//                 const SizedBox(height: 40),
//                 _PlatformFeaturesGrid(isMobile: isMobile, isDesktop: isDesktop),
//               ],
//             ),
//           ),

//           const SizedBox(height: 64),

//           // App Download & Contact Info
//           Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: padding,
//               vertical: isMobile ? 40 : 64,
//             ),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [AppTheme.brandBlack, Colors.black],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(24),
//             ),
//             margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : padding),
//             child: Column(
//               children: [
//                 Text(
//                   'Download the GET ON DIAL App',
//                   style: Theme.of(context).textTheme.displayMedium?.copyWith(
//                     color: Colors.white,
//                     fontSize: isMobile ? 32 : 40,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 14),
//                 Text(
//                   'Stay connected with partners, track every order, and unlock exclusive offers on mobile.',
//                   style: Theme.of(
//                     context,
//                   ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 28),
//                 Wrap(
//                   spacing: 16,
//                   runSpacing: 16,
//                   alignment: WrapAlignment.center,
//                   children: [
//                     _AppStoreBadge(
//                       label: 'App Store',
//                       icon: Icons.apple,
//                       onTap: () => _launchUri('https://apps.apple.com/'),
//                     ),
//                     _AppStoreBadge(
//                       label: 'Play Store',
//                       icon: Icons.android,
//                       onTap: () => _launchUri('https://play.google.com/store'),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 32),
//                 Wrap(
//                   spacing: 32,
//                   runSpacing: 16,
//                   alignment: WrapAlignment.center,
//                   children: [
//                     _ContactChip(
//                       icon: Icons.phone,
//                       label: '+91 86888 82233',
//                       value: 'Call support',
//                       onTap: () => _launchUri('tel:+918688882233'),
//                     ),
//                     _ContactChip(
//                       icon: Icons.email,
//                       value: 'Email team',
//                       label: 'info@getondial.com',
//                       onTap: () => _launchUri('mailto:info@getondial.com'),
//                     ),
//                     _ContactChip(
//                       icon: Icons.location_on,
//                       value: 'Office address',
//                       label:
//                           '49-44-18/1, Sankuvanipalem, near N T School, Visakhapatnam, Andhra Pradesh',

//                       onTap: () => _launchUri('https://maps.google.com/'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 80),

//           // CTA Section
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: padding, vertical: 80),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Colors.black, AppTheme.brandBlack],
//               ),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   'Ready to Get Started?',
//                   style: Theme.of(context).textTheme.displayMedium?.copyWith(
//                     color: Colors.white,
//                     fontSize: isMobile ? 28 : 42,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Join thousands of satisfied customers and partners across India',
//                   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                     color: Colors.white70,
//                     fontSize: 18,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 40),
//                 Wrap(
//                   spacing: 16,
//                   runSpacing: 16,
//                   alignment: WrapAlignment.center,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () => context.go('/contact'),
//                       icon: const Icon(Icons.rocket_launch),
//                       label: const Text('Start Now'),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 32,
//                           vertical: 20,
//                         ),
//                       ),
//                     ),
//                     OutlinedButton.icon(
//                       onPressed: () => context.go('/vendors'),
//                       icon: const Icon(Icons.business),
//                       label: const Text('Become a Partner'),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: Colors.white,
//                         side: const BorderSide(color: Colors.white, width: 1.5),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 32,
//                           vertical: 20,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<TestimonialModel> _getDummyTestimonials() {
//     return [
//       TestimonialModel(
//         id: '1',
//         customerName: 'Priya Sharma',
//         customerRole: 'Business Owner',
//         customerAvatar: 'https://i.pravatar.cc/150?img=45',
//         testimonial: 'This platform has transformed how I run my business...',
//         rating: 5.0,
//         location: 'Mumbai, Maharashtra',
//       ),
//       TestimonialModel(
//         id: '2',
//         customerName: 'Rahul Patel',
//         customerRole: 'Restaurant Owner',
//         customerAvatar: 'https://i.pravatar.cc/150?img=33',
//         testimonial: 'Our food delivery orders have increased by 300%...',
//         rating: 5.0,
//         location: 'Ahmedabad, Gujarat',
//       ),
//       TestimonialModel(
//         id: '3',
//         customerName: 'Sneha Reddy',
//         customerRole: 'Regular Customer',
//         customerAvatar: 'https://i.pravatar.cc/150?img=28',
//         testimonial:
//             'I love the convenience of having everything in one place...',
//         rating: 4.5,
//         location: 'Hyderabad, Telangana',
//       ),
//     ];
//   }
// }

// // -------------------------- REUSED WIDGETS ---------------------------- //

// class _FeaturesGrid extends StatelessWidget {
//   final bool isMobile;
//   final bool isDesktop;
//   const _FeaturesGrid({required this.isMobile, required this.isDesktop});

//   @override
//   Widget build(BuildContext context) {
//     final features = [
//       _FeatureItem(
//         icon: Icons.speed,
//         title: 'Lightning Fast',
//         description: 'Get services delivered in record time',
//         isCompact: isMobile,
//       ),
//       _FeatureItem(
//         icon: Icons.verified_user,
//         title: '100% Verified',
//         description: 'All partners are thoroughly verified',
//         isCompact: isMobile,
//       ),
//       _FeatureItem(
//         icon: Icons.support_agent,
//         title: '24/7 Support',
//         description: 'Round-the-clock customer assistance',
//         isCompact: isMobile,
//       ),
//       _FeatureItem(
//         icon: Icons.security,
//         title: 'Secure Payments',
//         description: 'Bank-grade security for all transactions',
//         isCompact: isMobile,
//       ),
//     ];

//     return Wrap(
//       spacing: 24,
//       runSpacing: 24,
//       alignment: WrapAlignment.center,
//       children: List.generate(features.length, (index) {
//         final feature = features[index];
//         return _HoverCard(
//           width:
//               isMobile
//                   ? double.infinity
//                   : (isDesktop
//                       ? 260
//                       : MediaQuery.of(context).size.width / 2 - 32),
//           height: isMobile ? 160 : 200,
//           child: feature,
//         );
//       }),
//     );
//   }
// }

// class _ModuleCard extends StatelessWidget {
//   final ModuleModel module;
//   final bool isMobile;
//   const _ModuleCard({required this.module, required this.isMobile});

//   @override
//   Widget build(BuildContext context) {
//     final double width =
//         isMobile ? MediaQuery.of(context).size.width - 64 : 320.0;

//     return GestureDetector(
//       onTap: () => context.go('/vendors?moduleId=${module.id}'),
//       child: Container(
//         width: width,
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: AppTheme.lightGrey),
//           color: Colors.white,
//           boxShadow: PremiumTheme.cardShadow,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: AspectRatio(
//                 aspectRatio: 4 / 3,
//                 child: Image.network(
//                   module.imageUrl,
//                   fit: BoxFit.cover,
//                   errorBuilder:
//                       (_, __, ___) => Container(
//                         color: AppTheme.lightGrey,
//                         child: const Icon(Icons.layers, size: 48),
//                       ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 14),
//             Text(
//               module.name,
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               module.description,
//               maxLines: 3,
//               overflow: TextOverflow.ellipsis,
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: AppTheme.greyText,
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextButton.icon(
//               onPressed: () => context.go('/vendors?moduleId=${module.id}'),
//               icon: const Icon(Icons.store_mall_directory),
//               label: const Text('View Vendors'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _HoverCard extends StatefulWidget {
//   final double width;
//   final double height;
//   final Widget child;
//   const _HoverCard({
//     required this.width,
//     required this.height,
//     required this.child,
//   });

//   @override
//   State<_HoverCard> createState() => _HoverCardState();
// }

// class _HoverCardState extends State<_HoverCard> {
//   bool isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => isHovered = true),
//       onExit: (_) => setState(() => isHovered = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeOut,
//         transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
//         width: widget.width,
//         height: widget.height,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           gradient: LinearGradient(
//             colors: [Colors.white, AppTheme.brandRed.withOpacity(0.05)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(isHovered ? 0.15 : 0.08),
//               blurRadius: isHovered ? 14 : 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: widget.child,
//       ),
//     );
//   }
// }

// class _PlatformFeaturesGrid extends StatelessWidget {
//   final bool isMobile;
//   final bool isDesktop;
//   const _PlatformFeaturesGrid({
//     required this.isMobile,
//     required this.isDesktop,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final features = [
//       {
//         'icon': Icons.track_changes,
//         'title': 'Real-time Tracking',
//         'desc': 'Track your orders in real-time',
//       },
//       {
//         'icon': Icons.notifications_active,
//         'title': 'Smart Notifications',
//         'desc': 'Stay updated with instant alerts',
//       },
//       {
//         'icon': Icons.payment,
//         'title': 'Multiple Payment Options',
//         'desc': 'Pay your way - cards, UPI, wallet',
//       },
//       {
//         'icon': Icons.history,
//         'title': 'Order History',
//         'desc': 'Access your complete order history',
//       },
//       {
//         'icon': Icons.star_rate,
//         'title': 'Ratings & Reviews',
//         'desc': 'Make informed decisions',
//       },
//       {
//         'icon': Icons.local_offer,
//         'title': 'Exclusive Deals',
//         'desc': 'Save with special offers',
//       },
//     ];

//     return Wrap(
//       spacing: 20,
//       runSpacing: 20,
//       alignment: WrapAlignment.center,
//       children: List.generate(features.length, (index) {
//         final feature = features[index];
//         return _HoverCard(
//           width:
//               isMobile
//                   ? MediaQuery.of(context).size.width / 2 - 28
//                   : (isDesktop ? 220 : 240),
//           height: 220,
//           child: Padding(
//             padding: const EdgeInsets.all(18),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   feature['icon'] as IconData,
//                   size: 44,
//                   color: AppTheme.brandRed,
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   feature['title'] as String,
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   feature['desc'] as String,
//                   style: Theme.of(
//                     context,
//                   ).textTheme.bodySmall?.copyWith(color: Colors.black54),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }

// class _FeatureItem extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String description;
//   final bool isCompact;
//   const _FeatureItem({
//     required this.icon,
//     required this.title,
//     required this.description,
//     this.isCompact = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(10),
//       child:
//           isCompact
//               ? SizedBox(
//                 height: 300,
//                 child: Row(
//                   children: [
//                     _FeatureIcon(icon: icon, size: 36),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             title,
//                             style: Theme.of(context).textTheme.titleMedium
//                                 ?.copyWith(fontWeight: FontWeight.w700),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             description,
//                             style: Theme.of(context).textTheme.bodySmall,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//               : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   _FeatureIcon(icon: icon, size: 32),
//                   const SizedBox(height: 16),
//                   Text(
//                     title,
//                     style: Theme.of(context).textTheme.titleLarge,
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     description,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//     );
//   }
// }

// class _FeatureIcon extends StatelessWidget {
//   final IconData icon;
//   final double size;
//   const _FeatureIcon({required this.icon, required this.size});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(size * 0.5),
//       decoration: BoxDecoration(
//         color: AppTheme.brandRed.withValues(alpha: 0.1),
//         shape: BoxShape.circle,
//       ),
//       child: Icon(icon, size: size, color: AppTheme.brandRed),
//     );
//   }
// }

// // ------------------- Remaining widgets (unchanged) ------------------- //

// class _StatBox extends StatelessWidget {
//   final int value;
//   final String suffix;
//   final String label;
//   final IconData icon;
//   final bool isMobile;

//   const _StatBox({
//     required this.value,
//     required this.suffix,
//     required this.label,
//     required this.icon,
//     required this.isMobile,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Icon(icon, color: Colors.white, size: isMobile ? 32 : 48),
//         const SizedBox(height: 12),
//         AnimatedCounter(
//           end: value,
//           suffix: suffix,
//           style: Theme.of(context).textTheme.displayMedium?.copyWith(
//             color: Colors.white,
//             fontWeight: FontWeight.w700,
//             fontSize: isMobile ? 32 : 48,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//             color: Colors.white,
//             fontSize: isMobile ? 14 : 16,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
// }

// class _HowItWorksSection extends StatelessWidget {
//   final bool isMobile;
//   const _HowItWorksSection({required this.isMobile});

//   @override
//   Widget build(BuildContext context) {
//     return isMobile
//         ? Column(
//           children: [
//             _HowItWorksStep(
//               step: 1,
//               title: 'Sign Up',
//               description: 'Create your free account in seconds',
//               isMobile: true,
//             ),
//             const SizedBox(height: 24),
//             _HowItWorksStep(
//               step: 2,
//               title: 'Choose Service',
//               description: 'Browse and select from our services',
//               isMobile: true,
//             ),
//             const SizedBox(height: 24),
//             _HowItWorksStep(
//               step: 3,
//               title: 'Enjoy',
//               description: 'Sit back and enjoy seamless service',
//               isMobile: true,
//             ),
//           ],
//         )
//         : Row(
//           children: [
//             Expanded(
//               child: _HowItWorksStep(
//                 step: 1,
//                 title: 'Sign Up',
//                 description: 'Create your free account in seconds',
//                 isMobile: false,
//               ),
//             ),
//             const Icon(Icons.arrow_forward, color: AppTheme.brandRed, size: 32),
//             Expanded(
//               child: _HowItWorksStep(
//                 step: 2,
//                 title: 'Choose Service',
//                 description: 'Browse and select from our services',
//                 isMobile: false,
//               ),
//             ),
//             const Icon(Icons.arrow_forward, color: AppTheme.brandRed, size: 32),
//             Expanded(
//               child: _HowItWorksStep(
//                 step: 3,
//                 title: 'Enjoy',
//                 description: 'Sit back and enjoy seamless service',
//                 isMobile: false,
//               ),
//             ),
//           ],
//         );
//   }
// }

// class _HowItWorksStep extends StatelessWidget {
//   final int step;
//   final String title;
//   final String description;
//   final bool isMobile;
//   const _HowItWorksStep({
//     required this.step,
//     required this.title,
//     required this.description,
//     required this.isMobile,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: AppTheme.brandRed,
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Text(
//                 '$step',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 28,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             title,
//             style: Theme.of(context).textTheme.titleLarge,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             description,
//             style: Theme.of(context).textTheme.bodyMedium,
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _AppStoreBadge extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final VoidCallback onTap;
//   const _AppStoreBadge({
//     required this.label,
//     required this.icon,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//         decoration: BoxDecoration(
//           color: AppTheme.brandWhite,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: PremiumTheme.cardShadow,
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 22, color: AppTheme.brandBlack),
//             const SizedBox(width: 12),
//             Text(
//               label,
//               style: Theme.of(
//                 context,
//               ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ContactChip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final VoidCallback onTap;

//   const _ContactChip({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final maxChipWidth = MediaQuery.of(context).size.width * 0.7;

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: AppTheme.brandWhite.withValues(alpha: 0.08),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: AppTheme.brandWhite.withValues(alpha: 0.2)),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: AppTheme.brandWhite, size: 20),
//             const SizedBox(width: 10),
//             Flexible(
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(maxWidth: maxChipWidth),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       label,
//                       style: const TextStyle(color: Colors.white70, fontSize: 12),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Text(
//                       value,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// Future<void> _launchUri(String url) async {
//   final uri = Uri.parse(url);
//   if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//     debugPrint('Could not launch $url');
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/responsive/responsive_breakpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/api_provider.dart';
import '../../core/models/module_model.dart';
import '../../core/models/testimonial_model.dart';
import '../../core/util/global_keyboard_scroll_handler.dart';
import '../../shared/widgets/hero_section.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/featured_stores_slider.dart';
import '../../shared/widgets/animated_counter.dart';
import '../../shared/widgets/network_circle_avatar.dart';
import '../../shared/widgets/social_media_section.dart';

// === HOME MODULES GRID — hide parcel / transit service tiles ===
bool _moduleHiddenFromHomeGrid(ModuleModel m) {
  final n = m.name.toLowerCase();
  final t = m.moduleType.toLowerCase();
  return n.contains('parcel') ||
      n.contains('transit') ||
      t.contains('parcel') ||
      t.contains('transit');
}

class EnhancedHomePage extends ConsumerStatefulWidget {
  const EnhancedHomePage({super.key});

  @override
  ConsumerState<EnhancedHomePage> createState() => _EnhancedHomePageState();
}

class _EnhancedHomePageState extends ConsumerState<EnhancedHomePage> {
  final GlobalKey _featuredStoresKey = GlobalKey();
  final GlobalKey _modulesKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  static const double _scrollStep = 100.0; // Pixels to scroll per key press

  @override
  void initState() {
    super.initState();
    // Set up keyboard navigation handlers
    _setupKeyboardNavigation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Clean up keyboard handlers
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
      // For horizontal scrolling (if needed in future)
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
      // For horizontal scrolling (if needed in future)
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

  @override
  Widget build(BuildContext context) {
    final modulesAsync = ref.watch(modulesProvider);
    final padding = ResponsiveBreakpoints.getHorizontalPadding(context);
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final sectionSpacing = ResponsiveBreakpoints.getSectionSpacing(context);
    final maxWidth = ResponsiveBreakpoints.getMaxContentWidth(context);

    // Wrap in InteractiveViewer for mobile zoom functionality
    Widget content = PrimaryScrollController(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Premium Hero Section
          HeroSection(
            title: 'Your Complete Service Partner',
            subtitle:
                'Food • Healthcare • Jobs • Delivery • Shopping - All in One Platform',
            imageUrl:
                'https://images.unsplash.com/photo-1522202176988-66273c2fd55f',
            primaryActionText: 'Get Started',
            secondaryActionText: 'Explore Stores',
            onPrimaryAction: () => context.go('/contact'),
            onSecondaryAction: () => context.go('/vendors'),
          ),

          // Modules Section - Professional Grid Layout
          Container(
            key: _modulesKey,
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: sectionSpacing,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Integrated Modules',
                    subtitle: 'Powered directly from the Get On Dial platform',
                    centerAlign: isMobile,
                  ),
                  SizedBox(
                    height:
                        isMobile
                            ? 32
                            : isTablet
                            ? 40
                            : 56,
                  ),
                  modulesAsync.when(
                    data: (modules) {
                      if (modules.isEmpty) {
                        return _EmptyStateCard(
                          title: 'Modules Coming Soon',
                          description:
                              'Exciting new services are on the way...',
                        );
                      }
                      final displayCount = isMobile ? 3 : (isTablet ? 4 : 6);
                      final filtered = modules
                          .where((m) => !_moduleHiddenFromHomeGrid(m))
                          .toList();
                      final display = filtered.take(displayCount).toList();

                      // Use GridView for better control on different screen sizes
                      // return LayoutBuilder(
                      //   builder: (context, constraints) {
                      //     final crossAxisCount =
                      //         isMobile ? 1 : (isTablet ? 2 : 3);
                      //     final childAspectRatio =
                      //         isMobile ? 1.4 : (isTablet ? 0.85 : 0.8);
                      //     final spacing =
                      //         isMobile ? 10.0 : (isTablet ? 24.0 : 28.0);

                      //     return GridView.builder(
                      //       shrinkWrap: true,
                      //       physics: const NeverScrollableScrollPhysics(),
                      //       gridDelegate:
                      //           SliverGridDelegateWithFixedCrossAxisCount(
                      //             crossAxisCount: crossAxisCount,
                      //             childAspectRatio: childAspectRatio,
                      //             crossAxisSpacing: spacing,
                      //             mainAxisSpacing: spacing,
                      //           ),
                      //       itemCount: display.length,
                      //       itemBuilder: (context, index) {
                      //         final module = display[index];
                      //         final isLastModule = index == display.length - 1;
                      //         return _ModuleCard(
                      //           module: module,
                      //           isMobile: isMobile,
                      //           isLastModule: isLastModule,
                      //         );
                      //       },
                      //     );
                      //   },
                      // );
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final spacing =
                              isMobile ? 10.0 : (isTablet ? 24.0 : 28.0);

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),

                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 320,
                                  crossAxisSpacing: spacing,
                                  mainAxisSpacing: spacing,
                                  mainAxisExtent: isMobile ? 260 : 340,
                                ),

                            // gridDelegate:
                            //     SliverGridDelegateWithFixedCrossAxisCount(
                            //       crossAxisCount:
                            //           isMobile ? 1 : (isTablet ? 3 : 5),
                            //       crossAxisSpacing: spacing,
                            //       mainAxisSpacing: spacing,
                            //       mainAxisExtent: isMobile ? 260 : 340,
                            //     ),
                            itemCount: display.length,
                            itemBuilder: (context, index) {
                              final module = display[index];
                              return _ModuleCard(
                                module: module,
                                isMobile: isMobile,
                              );
                            },
                          );
                        },
                      );
                    },
                    loading:
                        () => Padding(
                          padding: EdgeInsets.all(isMobile ? 24 : 48),
                          child: const CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.brandRed,
                            ),
                          ),
                        ),
                    error:
                        (error, _) => _EmptyStateCard(
                          title: 'Unable to Load',
                          description: 'Please try again later',
                        ),
                  ),
                ],
              ),
            ),
          ),

          // Features Highlight - Premium Grid with Background
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: sectionSpacing,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[50]!, Colors.white, Colors.grey[50]!],
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  SectionHeader(
                    title: 'Why Choose Us?',
                    subtitle: 'Experience excellence in every service we offer',
                    centerAlign: true,
                  ),
                  SizedBox(
                    height:
                        isMobile
                            ? 40
                            : isTablet
                            ? 56
                            : 72,
                  ),
                  _FeaturesGrid(
                    isMobile: isMobile,
                    isTablet: isTablet,
                    isDesktop: isDesktop,
                    maxWidth: maxWidth,
                  ),
                ],
              ),
            ),
          ),

          // Statistics Section - Enhanced with Professional Layout
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: sectionSpacing,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.brandRed,
                  AppTheme.brandRed.withValues(alpha: 0.85),
                  AppTheme.brandBlack.withValues(alpha: 0.9),
                ],
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  Text(
                    'Trusted by Thousands',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontSize:
                          isMobile
                              ? 28
                              : isTablet
                              ? 36
                              : 48,
                      fontWeight: FontWeight.w800,
                      letterSpacing: isMobile ? -0.3 : -0.5,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 0,
                    ),
                    child: Text(
                      'Join our growing community of satisfied customers',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize:
                            isMobile
                                ? 13
                                : isTablet
                                ? 16
                                : 18,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height:
                        isMobile
                            ? 40
                            : isTablet
                            ? 56
                            : 72,
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive grid for stats
                      final statsPerRow = isMobile ? 2 : (isTablet ? 2 : 4);
                      final spacing =
                          isMobile ? 12.0 : (isTablet ? 24.0 : 32.0);

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: statsPerRow,
                          childAspectRatio: isMobile ? 1.4 : 1.0,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                        ),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          final stats = [
                            {
                              'value': 50000,
                              'suffix': '+',
                              'label': 'Happy Customers',
                              'icon': Icons.people_rounded,
                            },
                            {
                              'value': 1000,
                              'suffix': '+',
                              'label': 'Featured Stores',
                              'icon': Icons.business_rounded,
                            },
                            {
                              'value': 100,
                              'suffix': '+',
                              'label': 'Cities Covered',
                              'icon': Icons.location_city_rounded,
                            },
                            {
                              'value': 99,
                              'suffix': '%',
                              'label': 'Customer Satisfaction',
                              'icon': Icons.sentiment_very_satisfied_rounded,
                            },
                          ];
                          final stat = stats[index];
                          return _StatBox(
                            value: stat['value'] as int,
                            suffix: stat['suffix'] as String,
                            label: stat['label'] as String,
                            icon: stat['icon'] as IconData,
                            isMobile: isMobile,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: sectionSpacing),

          // Testimonials Section - Enhanced with Better Layout
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: sectionSpacing * 0.6,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  SectionHeader(
                    title: 'What Our Customers Say',
                    subtitle: 'Real experiences from real people',
                    centerAlign: true,
                  ),
                  SizedBox(
                    height:
                        isMobile
                            ? 32
                            : isTablet
                            ? 40
                            : 56,
                  ),
                  SizedBox(
                    height:
                        isMobile
                            ? 320
                            : isTablet
                            ? 360
                            : 340,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final testimonials = _getDummyTestimonials();
                        final cardsPerView = isMobile ? 1 : (isTablet ? 2 : 3);
                        final cardWidth =
                            (constraints.maxWidth / cardsPerView) -
                            (isMobile ? 0 : (isTablet ? 16 : 20));
                        final spacing =
                            isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);

                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? padding : 0,
                          ),
                          itemCount: testimonials.length,
                          separatorBuilder: (_, __) => SizedBox(width: spacing),
                          itemBuilder: (context, index) {
                            final maxCardWidth =
                                isMobile
                                    ? (MediaQuery.of(context).size.width -
                                            (padding * 2))
                                        .toDouble()
                                    : (isTablet ? 360.0 : 400.0);
                            return SizedBox(
                              width: cardWidth.clamp(
                                isMobile ? 260.0 : 300.0,
                                maxCardWidth,
                              ),
                              child: _PremiumTestimonialCard(
                                testimonial: testimonials[index],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: sectionSpacing),

          // Featured Stores Slider with Hero Animations (from all modules)
          Container(
            key: _featuredStoresKey,
            child: FeaturedStoresSlider(
              moduleId: null,
            ), // null = get from all modules
          ),
          SizedBox(height: sectionSpacing),

          // How It Works Section - Professional Layout
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: sectionSpacing,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[50]!, Colors.white, Colors.grey[50]!],
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  SectionHeader(
                    title: 'How It Works',
                    subtitle: 'Get started in 3 simple steps',
                    centerAlign: true,
                  ),
                  SizedBox(
                    height:
                        isMobile
                            ? 40
                            : isTablet
                            ? 56
                            : 72,
                  ),
                  _HowItWorksSection(
                    isMobile: isMobile,
                    isTablet: isTablet,
                    isDesktop: isDesktop,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: sectionSpacing),

          // Platform Features Section - Enhanced Grid
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: sectionSpacing,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  SectionHeader(
                    title: 'Platform Features',
                    subtitle: 'Everything you need in one app',
                    centerAlign: true,
                  ),
                  SizedBox(
                    height:
                        isMobile
                            ? 32
                            : isTablet
                            ? 48
                            : 64,
                  ),
                  _PlatformFeaturesGrid(
                    isMobile: isMobile,
                    isTablet: isTablet,
                    isDesktop: isDesktop,
                    maxWidth: maxWidth,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: sectionSpacing),

          // App Download Section - Enhanced with Better Spacing
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? padding : padding * 1.5,
              vertical:
                  isMobile
                      ? 48
                      : isTablet
                      ? 64
                      : 80,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: isMobile ? 0 : padding * 0.5,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.brandBlack,
                  AppTheme.brandBlack.withValues(alpha: 0.95),
                  AppTheme.brandRed.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(isMobile ? 24 : 32),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.brandRed.withValues(alpha: 0.25),
                  blurRadius: isMobile ? 30 : 40,
                  offset: Offset(0, isMobile ? 15 : 20),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 0),
                    child: Text(
                      'Download the GET ON DIAL App',
                      style: Theme.of(
                        context,
                      ).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontSize:
                            isMobile
                                ? 22
                                : isTablet
                                ? 36
                                : 44,
                        fontWeight: FontWeight.w800,
                        letterSpacing: isMobile ? -0.2 : -0.5,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: isMobile ? 10 : 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 0),
                    child: Text(
                      'Stay connected with partners, track every order, and unlock exclusive offers on mobile.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize:
                            isMobile
                                ? 12
                                : isTablet
                                ? 15
                                : 16,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height:
                        isMobile
                            ? 32
                            : isTablet
                            ? 40
                            : 48,
                  ),
                  Wrap(
                    spacing: isMobile ? 12 : 16,
                    runSpacing: isMobile ? 12 : 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _AppStoreBadge(
                        label: 'App Store',
                        icon: Icons.apple,
                        onTap:
                            () => _launchUri(
                              'https://apps.apple.com/in/app/get-on-dial/id6476094551',
                            ),
                        isMobile: isMobile,
                      ),
                      _AppStoreBadge(
                        label: 'Play Store',
                        icon: Icons.android,
                        onTap:
                            () => _launchUri(
                              'https://play.google.com/store/apps/details?id=com.getondial.app&pcampaignid=web_share',
                            ),
                        isMobile: isMobile,
                      ),
                    ],
                  ),
                  SizedBox(
                    height:
                        isMobile
                            ? 32
                            : isTablet
                            ? 40
                            : 48,
                  ),
                  Wrap(
                    spacing: isMobile ? 12.0 : (isTablet ? 16.0 : 20.0),
                    runSpacing: isMobile ? 12.0 : (isTablet ? 16.0 : 20.0),
                    alignment: WrapAlignment.center,
                    children: [
                      _ContactChip(
                        icon: Icons.phone_rounded,
                        label: 'Call support',
                        value: '+91 86888 82233',
                        onTap: () => _launchUri('tel:+918688882233'),
                        isMobile: isMobile,
                      ),
                      _ContactChip(
                        icon: Icons.email_rounded,
                        label: 'Email team',
                        value: 'info@getondial.com',
                        onTap: () => _launchUri('mailto:info@getondial.com'),
                        isMobile: isMobile,
                      ),
                      _ContactChip(
                        icon: Icons.location_on_rounded,
                        label: 'Office address',
                        value: 'Visakhapatnam, Andhra Pradesh',
                        onTap: () => _launchUri('https://maps.google.com/'),
                        isMobile: isMobile,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: sectionSpacing),

          // Premium CTA Section - Professional Layout
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: sectionSpacing,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.brandBlack,
                  AppTheme.brandBlack.withValues(alpha: 0.95),
                  AppTheme.brandRed.withValues(alpha: 0.2),
                ],
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 0,
                    ),
                    child: Text(
                      'Ready to Get Started?',
                      style: Theme.of(
                        context,
                      ).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontSize:
                            isMobile
                                ? 22
                                : isTablet
                                ? 36
                                : 48,
                        fontWeight: FontWeight.w800,
                        letterSpacing: isMobile ? -0.2 : -0.5,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: isMobile ? 10 : 16),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 0,
                    ),
                    child: Text(
                      'Join thousands of satisfied customers and partners across India',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize:
                            isMobile
                                ? 12
                                : isTablet
                                ? 16
                                : 18,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height:
                        isMobile
                            ? 32
                            : isTablet
                            ? 40
                            : 48,
                  ),
                  Wrap(
                    spacing: isMobile ? 16 : 20,
                    runSpacing: isMobile ? 16 : 20,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => context.go('/contact'),
                        icon: Icon(
                          Icons.rocket_launch_rounded,
                          size: isMobile ? 18 : 20,
                        ),
                        label: const Text('Start Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.brandRed,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 32 : 40,
                            vertical: isMobile ? 16 : 18,
                          ),
                          elevation: 8,
                          shadowColor: AppTheme.brandRed.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/vendors'),
                        icon: Icon(
                          Icons.business_rounded,
                          size: isMobile ? 18 : 20,
                        ),
                        label: const Text('Become a Partner'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 32 : 40,
                            vertical: isMobile ? 16 : 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: sectionSpacing),

          // Social Media Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: sectionSpacing * 0.75,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey[50]!,
                  Colors.white,
                ],
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: const SocialMediaSection(showTitle: true, horizontal: true),
            ),
          ),
        ],
      ),
      ),
    );

    // Wrap with InteractiveViewer for mobile zoom functionality
    if (isMobile) {
      return InteractiveViewer(minScale: 0.8, maxScale: 2.0, child: content);
    }

    return content;
  }

  List<TestimonialModel> _getDummyTestimonials() {
    return [
      TestimonialModel(
        id: '1',
        customerName: 'Priya Sharma',
        customerRole: 'Business Owner',
        customerAvatar: 'https://i.pravatar.cc/150?img=45',
        testimonial: 'This platform has transformed how I run my business...',
        rating: 5.0,
        location: 'Mumbai, Maharashtra',
      ),
      TestimonialModel(
        id: '2',
        customerName: 'Rahul Patel',
        customerRole: 'Restaurant Owner',
        customerAvatar: 'https://i.pravatar.cc/150?img=33',
        testimonial: 'Our food delivery orders have increased by 300%...',
        rating: 5.0,
        location: 'Ahmedabad, Gujarat',
      ),
      TestimonialModel(
        id: '3',
        customerName: 'Sneha Reddy',
        customerRole: 'Regular Customer',
        customerAvatar: 'https://i.pravatar.cc/150?img=28',
        testimonial:
            'I love the convenience of having everything in one place...',
        rating: 4.5,
        location: 'Hyderabad, Telangana',
      ),
    ];
  }
}

// ==================== ENHANCED WIDGETS ==================== //

String _initialsFromName(String name) {
  final parts =
      name
          .trim()
          .split(RegExp(r'\s+'))
          .where((segment) => segment.isNotEmpty)
          .toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) {
    final word = parts.first;
    return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

class _EmptyStateCard extends StatelessWidget {
  final String title;
  final String description;

  const _EmptyStateCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            size: 64,
            color: AppTheme.brandRed.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FeaturesGrid extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final double maxWidth;

  const _FeaturesGrid({
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final features = [
      _FeatureItem(
        icon: Icons.bolt,
        title: 'Lightning Fast',
        description: 'Get services delivered in record time',
        gradient: [Colors.amber[400]!, Colors.orange[600]!],
      ),
      _FeatureItem(
        icon: Icons.verified_user_rounded,
        title: '100% Verified',
        description: 'All partners are thoroughly verified',
        gradient: [Colors.green[400]!, Colors.teal[600]!],
      ),
      _FeatureItem(
        icon: Icons.headset_mic_rounded,
        title: '24/7 Support',
        description: 'Round-the-clock customer assistance',
        gradient: [Colors.blue[400]!, Colors.indigo[600]!],
      ),
      _FeatureItem(
        icon: Icons.shield_rounded,
        title: 'Secure Payments',
        description: 'Bank-grade security for all transactions',
        gradient: [Colors.red[400]!, Colors.pink[600]!],
      ),
    ];

    // Use GridView for better responsive control
    return
    //  LayoutBuilder(
    //   builder: (context, constraints) {
    //     final crossAxisCount = isMobile ? 2 : (isTablet ? 2 : 4);
    //     final spacing = isMobile ? 12.0 : (isTablet ? 20.0 : 24.0);
    //     final childAspectRatio = isMobile ? 0.95 : (isTablet ? 0.9 : 0.95);
    //     return GridView.builder(
    //       shrinkWrap: true,
    //       physics: const NeverScrollableScrollPhysics(),
    //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //         crossAxisCount: crossAxisCount,
    //         childAspectRatio: childAspectRatio,
    //         crossAxisSpacing: spacing,
    //         mainAxisSpacing: spacing,
    //       ),
    //       itemCount: features.length,
    //       itemBuilder: (context, index) {
    //         return _PremiumFeatureCard(
    //           feature: features[index],
    //           isMobile: isMobile,
    //           isTablet: isTablet,
    //           isDesktop: isDesktop,
    //         );
    //       },
    //     );
    //   },
    // );
    LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);
        final spacing = isMobile ? 10.0 : (isTablet ? 24.0 : 28.0);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,

            // 🔥 Allow dynamic + animated height
            mainAxisExtent: isMobile ? 260 : (isTablet ? 300 : 340),
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            return _PremiumFeatureCard(
              feature: features[index],
              isMobile: isMobile,
              isTablet: isTablet,
              isDesktop: isDesktop,
            );
          },
        );
      },
    );
  }
}

class _PremiumFeatureCard extends StatefulWidget {
  final _FeatureItem feature;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  const _PremiumFeatureCard({
    required this.feature,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  State<_PremiumFeatureCard> createState() => _PremiumFeatureCardState();
}

class _PremiumFeatureCardState extends State<_PremiumFeatureCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final iconSize = widget.isMobile ? 28.0 : (widget.isTablet ? 32.0 : 36.0);
    final iconContainerSize =
        widget.isMobile ? 60.0 : (widget.isTablet ? 65.0 : 70.0);
    final padding = widget.isMobile ? 20.0 : (widget.isTablet ? 24.0 : 28.0);
    final titleSize = widget.isMobile ? 16.0 : (widget.isTablet ? 17.0 : 18.0);
    final descSize = widget.isMobile ? 12.0 : (widget.isTablet ? 13.0 : 14.0);

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0, isHovered ? -8 : 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.isMobile ? 20 : 24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey[50]!],
          ),
          border: Border.all(
            color:
                isHovered
                    ? AppTheme.brandRed.withValues(alpha: 0.3)
                    : Colors.grey[200]!,
            width: isHovered ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isHovered
                      ? AppTheme.brandRed.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.06),
              blurRadius: isHovered ? 30 : 15,
              offset: Offset(0, isHovered ? 12 : 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.feature.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.feature.gradient[0].withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.feature.icon,
                  size: iconSize,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: widget.isMobile ? 10 : 20),
              Flexible(
                child: Text(
                  widget.feature.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: titleSize,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: widget.isMobile ? 6 : 10),
              Flexible(
                child: Text(
                  widget.feature.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: descSize,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}

// class _ModuleCard extends StatefulWidget {
//   final ModuleModel module;
//   final bool isMobile;
//   final bool isLastModule;

//   const _ModuleCard({
//     required this.module,
//     required this.isMobile,
//     this.isLastModule = false,
//   });

//   @override
//   State<_ModuleCard> createState() => _ModuleCardState();
// }

// class _ModuleCardState extends State<_ModuleCard> {
//   bool isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     final isTablet =
//         MediaQuery.of(context).size.width >= 600 &&
//         MediaQuery.of(context).size.width < 1024;
//     final padding = widget.isMobile ? 10.0 : (isTablet ? 18.0 : 20.0);
//     final borderRadius = widget.isMobile ? 14.0 : 24.0;
//     final imageRadius = widget.isMobile ? 10.0 : 18.0;
//     final titleSize = widget.isMobile ? 15.0 : (isTablet ? 18.0 : 20.0);
//     final descSize = widget.isMobile ? 12.0 : (isTablet ? 14.0 : 15.0);

//     return MouseRegion(
//       onEnter: (_) => setState(() => isHovered = true),
//       onExit: (_) => setState(() => isHovered = false),
//       child: GestureDetector(
//         onTap: () {
//           if (widget.isLastModule) {
//             context.go('/parcel-delivery');
//           } else {
//             context.go('/vendors?moduleId=${widget.module.id}');
//           }
//         },
//         child: SizedBox(
//           height: 200,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeOut,
//             padding: EdgeInsets.all(padding),
//             transform: Matrix4.identity()..translate(0, isHovered ? -10 : 0),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(borderRadius),
//               border: Border.all(
//                 color:
//                     isHovered
//                         ? AppTheme.brandRed.withValues(alpha: 0.4)
//                         : Colors.grey[200]!,
//                 width: isHovered ? 2.5 : 1.5,
//               ),
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Colors.white, Colors.grey[50]!],
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color:
//                       isHovered
//                           ? AppTheme.brandRed.withValues(alpha: 0.25)
//                           : Colors.black.withValues(alpha: 0.08),
//                   blurRadius: isHovered ? 35 : 15,
//                   offset: Offset(0, isHovered ? 15 : 5),
//                 ),
//               ],
//             ),
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.max,
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(imageRadius),
//                       child: AspectRatio(
//                         aspectRatio: widget.isMobile ? 7 / 4 : 4 / 3,
//                         child: Stack(
//                           fit: StackFit.passthrough,
//                           children: [
//                             // Image.network(
//                             //   widget.module.imageUrl,
//                             //   fit: BoxFit.fitHeight,
//                             //   errorBuilder:
//                             //       (_, __, ___) => Container(
//                             //         // color: Colors.grey[200],
//                             //         child: Icon(
//                             //           Icons.layers_rounded,
//                             //           size: widget.isMobile ? 32 : 56,
//                             //           color: Colors.grey[400],
//                             //         ),
//                             //       ),
//                             // ),
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: SizedBox(
//                                 height: widget.isMobile ? 60 : 80,
//                                 width: double.infinity,
//                                 child: Image.network(
//                                   widget.module.imageUrl,
//                                   fit: BoxFit.cover,
//                                   errorBuilder:
//                                       (_, __, ___) => Icon(
//                                         Icons.layers_rounded,
//                                         size: widget.isMobile ? 32 : 56,
//                                         color: Colors.grey[400],
//                                       ),
//                                 ),
//                               ),
//                             ),

//                             if (isHovered)
//                               Container(
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     begin: Alignment.topCenter,
//                                     end: Alignment.bottomCenter,
//                                     colors: [
//                                       AppTheme.brandRed.withValues(alpha: 0.1),
//                                       AppTheme.brandRed.withValues(alpha: 0.05),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     // SizedBox(height: widget.isMobile ? 3 : 6),
//                     Center(
//                       child: Text(
//                         widget.module.name,
//                         style: Theme.of(
//                           context,
//                         ).textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.w800,
//                           fontSize: titleSize,
//                           height: 1.0,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     Divider(
//                       height: widget.isMobile ? 12 : 20,
//                       color: Colors.grey[300],
//                     ),

//                     // SizedBox(height: widget.isMobile ? 6 : 6),
//                     // Expanded(
//                     //   child: Text(
//                     //     widget.module.description,
//                     //     maxLines: 2,
//                     //     overflow: TextOverflow.ellipsis,
//                     //     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     //       color: Colors.grey[600],
//                     //       fontSize: descSize,
//                     //       height: 1.1,
//                     //     ),
//                     //   ),
//                     // ),
//                     Center(
//                       child: Container(
//                         // width: double.infinity,
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               AppTheme.brandRed,
//                               AppTheme.brandRed.withValues(alpha: 0.85),
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(
//                             widget.isMobile ? 6 : 12,
//                           ),
//                           boxShadow:
//                               isHovered
//                                   ? [
//                                     BoxShadow(
//                                       color: AppTheme.brandRed.withValues(
//                                         alpha: 0.3,
//                                       ),
//                                       blurRadius: 12,
//                                       offset: const Offset(0, 4),
//                                     ),
//                                   ]
//                                   : null,
//                         ),
//                         child: TextButton.icon(
//                           onPressed: () {
//                             if (widget.isLastModule) {
//                               context.go('/parcel-delivery');
//                             } else {
//                               context.go(
//                                 '/vendors?moduleId=${widget.module.id}',
//                               );
//                             }
//                           },
//                           // icon: Icon(
//                           //   Icons.store_mall_directory_rounded,
//                           //   size: widget.isMobile ? 14 : 20,
//                           //   color: Colors.white,
//                           // ),
//                           label: Text(
//                             'View Vendors',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w600,
//                               fontSize: widget.isMobile ? 12 : 14,
//                             ),
//                           ),
//                           style: TextButton.styleFrom(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: widget.isMobile ? 10 : 16,
//                               vertical: widget.isMobile ? 8 : 12,
//                             ),
//                             minimumSize: Size(0, widget.isMobile ? 36 : 48),
//                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
class _ModuleCard extends StatefulWidget {
  final ModuleModel module;
  final bool isMobile;

  const _ModuleCard({
    required this.module,
    required this.isMobile,
  });

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;

    final padding = widget.isMobile ? 10.0 : (isTablet ? 18.0 : 20.0);
    final borderRadius = widget.isMobile ? 14.0 : 24.0;
    final imageHeight = widget.isMobile ? 120.0 : 160.0;
    final titleSize = widget.isMobile ? 15.0 : (isTablet ? 18.0 : 20.0);

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () {
          context.go('/vendors?moduleId=${widget.module.id}');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(padding),
          transform: Matrix4.identity()..translate(0, isHovered ? -10 : 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color:
                  isHovered
                      ? AppTheme.brandRed.withValues(alpha: 0.4)
                      : Colors.grey[200]!,
              width: isHovered ? 2.5 : 1.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey[50]!],
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isHovered
                        ? AppTheme.brandRed.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.08),
                blurRadius: isHovered ? 35 : 15,
                offset: Offset(0, isHovered ? 15 : 5),
              ),
            ],
          ),

          // 👇 This column will now size naturally without overflow
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: imageHeight,
                  // width: 400,
                  child: Image.network(
                    widget.module.imageUrl,
                    fit: BoxFit.fitHeight,
                    errorBuilder:
                        (_, __, ___) => Icon(
                          Icons.layers_rounded,
                          size: widget.isMobile ? 32 : 56,
                          color: Colors.grey[400],
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                widget.module.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: titleSize,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.brandRed,
                      AppTheme.brandRed.withValues(alpha: 0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(widget.isMobile ? 6 : 12),
                ),
                child: TextButton(
                  onPressed: () {
                    context.go('/vendors?moduleId=${widget.module.id}');
                  },
                  child: Text(
                    'View Vendors',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: widget.isMobile ? 12 : 14,
                    ),
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

class _PremiumTestimonialCard extends StatefulWidget {
  final TestimonialModel testimonial;

  const _PremiumTestimonialCard({required this.testimonial});

  @override
  State<_PremiumTestimonialCard> createState() =>
      _PremiumTestimonialCardState();
}

class _PremiumTestimonialCardState extends State<_PremiumTestimonialCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final initials = _initialsFromName(widget.testimonial.customerName);
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0, isHovered ? -12 : 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey[50]!],
          ),
          border: Border.all(
            color:
                isHovered
                    ? AppTheme.brandRed.withValues(alpha: 0.3)
                    : Colors.grey[200]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isHovered
                      ? AppTheme.brandRed.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.06),
              blurRadius: isHovered ? 30 : 12,
              offset: Offset(0, isHovered ? 16 : 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width < 600 ? 20 : 28,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rating Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < widget.testimonial.rating.toInt()
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: AppTheme.brandRed,
                    size: MediaQuery.of(context).size.width < 600 ? 16 : 20,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width < 600 ? 8 : 12,
              ),
              // Testimonial Text
              Flexible(
                child: Text(
                  widget.testimonial.testimonial,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width < 600 ? 13 : 15,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width < 600 ? 12 : 20,
              ),
              // Customer Info
              Row(
                children: [
                  NetworkCircleAvatar(
                    imageUrl: widget.testimonial.customerAvatar,
                    radius: MediaQuery.of(context).size.width < 600 ? 18 : 24,
                    backgroundColor: Colors.grey.shade200,
                    fallback:
                        initials.isNotEmpty
                            ? Text(
                              initials,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize:
                                    MediaQuery.of(context).size.width < 600
                                        ? 12
                                        : 14,
                              ),
                            )
                            : Icon(
                              Icons.person_outline,
                              size:
                                  MediaQuery.of(context).size.width < 600
                                      ? 18
                                      : 24,
                            ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width < 600 ? 12 : 16,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.testimonial.customerName,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize:
                                MediaQuery.of(context).size.width < 600
                                    ? 12
                                    : 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.width < 600 ? 2 : 4,
                        ),
                        Text(
                          '${widget.testimonial.customerRole} • ${widget.testimonial.location}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                            fontSize:
                                MediaQuery.of(context).size.width < 600
                                    ? 10
                                    : 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final int value;
  final String suffix;
  final String label;
  final IconData icon;
  final bool isMobile;

  const _StatBox({
    required this.value,
    required this.suffix,
    required this.label,
    required this.icon,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 10 : 20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: isMobile ? 1.0 : 1.5,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: isMobile ? 24 : 48),
        ),
        SizedBox(height: isMobile ? 10 : 20),
        AnimatedCounter(
          end: value,
          suffix: suffix,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: isMobile ? 24 : 52,
            letterSpacing: isMobile ? -0.4 : -1,
            height: 1.0,
          ),
        ),
        SizedBox(height: isMobile ? 6 : 12),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontSize: isMobile ? 12 : 16,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  const _HowItWorksSection({
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          _HowItWorksStep(
            step: 1,
            title: 'Sign Up',
            description: 'Create your free account in seconds',
            isMobile: true,
          ),
          SizedBox(height: isMobile ? 24 : 28),
          Center(
            child: Icon(
              Icons.arrow_downward_rounded,
              color: AppTheme.brandRed,
              size: isMobile ? 28 : 32,
            ),
          ),
          SizedBox(height: isMobile ? 24 : 28),
          _HowItWorksStep(
            step: 2,
            title: 'Choose Service',
            description: 'Browse and select from our services',
            isMobile: true,
          ),
          SizedBox(height: isMobile ? 24 : 28),
          Center(
            child: Icon(
              Icons.arrow_downward_rounded,
              color: AppTheme.brandRed,
              size: isMobile ? 28 : 32,
            ),
          ),
          SizedBox(height: isMobile ? 24 : 28),
          _HowItWorksStep(
            step: 3,
            title: 'Enjoy',
            description: 'Sit back and enjoy seamless service',
            isMobile: true,
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _HowItWorksStep(
              step: 1,
              title: 'Sign Up',
              description: 'Create your free account in seconds',
              isMobile: false,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 20),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: AppTheme.brandRed,
              size: isTablet ? 32 : 36,
            ),
          ),
          Expanded(
            child: _HowItWorksStep(
              step: 2,
              title: 'Choose Service',
              description: 'Browse and select from our services',
              isMobile: false,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 20),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: AppTheme.brandRed,
              size: isTablet ? 32 : 36,
            ),
          ),
          Expanded(
            child: _HowItWorksStep(
              step: 3,
              title: 'Enjoy',
              description: 'Sit back and enjoy seamless service',
              isMobile: false,
            ),
          ),
        ],
      );
    }
  }
}

class _HowItWorksStep extends StatefulWidget {
  final int step;
  final String title;
  final String description;
  final bool isMobile;

  const _HowItWorksStep({
    required this.step,
    required this.title,
    required this.description,
    required this.isMobile,
  });

  @override
  State<_HowItWorksStep> createState() => _HowItWorksStepState();
}

class _HowItWorksStepState extends State<_HowItWorksStep> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;
    final padding = widget.isMobile ? 16.0 : (isTablet ? 24.0 : 28.0);
    final borderRadius = widget.isMobile ? 18.0 : 24.0;
    final circleSize = widget.isMobile ? 50.0 : (isTablet ? 65.0 : 70.0);
    final stepFontSize = widget.isMobile ? 24.0 : (isTablet ? 30.0 : 32.0);
    final titleSize = widget.isMobile ? 14.0 : (isTablet ? 17.0 : 18.0);
    final descSize = widget.isMobile ? 12.0 : (isTablet ? 14.0 : 15.0);

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0, isHovered ? -8 : 0),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey[50]!],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color:
                isHovered
                    ? AppTheme.brandRed.withValues(alpha: 0.3)
                    : Colors.grey[200]!,
            width: isHovered ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isHovered
                      ? AppTheme.brandRed.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.06),
              blurRadius: isHovered ? 25 : 12,
              offset: Offset(0, isHovered ? 12 : 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.brandRed,
                    AppTheme.brandRed.withValues(alpha: 0.8),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.brandRed.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${widget.step}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: stepFontSize,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SizedBox(height: widget.isMobile ? 12 : 20),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: titleSize,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: widget.isMobile ? 6 : 10),
            Flexible(
              child: Text(
                widget.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontSize: descSize,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformFeaturesGrid extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final double maxWidth;

  const _PlatformFeaturesGrid({
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.track_changes_rounded,
        'title': 'Real-time Tracking',
        'desc': 'Track your orders in real-time',
        'color': Colors.blue,
      },
      {
        'icon': Icons.notifications_active_rounded,
        'title': 'Smart Notifications',
        'desc': 'Stay updated with instant alerts',
        'color': Colors.purple,
      },
      {
        'icon': Icons.payment_rounded,
        'title': 'Multiple Payment Options',
        'desc': 'Pay your way - cards, UPI, wallet',
        'color': Colors.green,
      },
      {
        'icon': Icons.history_rounded,
        'title': 'Order History',
        'desc': 'Access your complete order history',
        'color': Colors.orange,
      },
      {
        'icon': Icons.star_rate_rounded,
        'title': 'Ratings & Reviews',
        'desc': 'Make informed decisions',
        'color': Colors.amber,
      },
      {
        'icon': Icons.local_offer_rounded,
        'title': 'Exclusive Deals',
        'desc': 'Save with special offers',
        'color': Colors.pink,
      },
    ];

    // Use GridView for better responsive control
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 3);
        final spacing = isMobile ? 12.0 : (isTablet ? 20.0 : 24.0);
        final childAspectRatio = isMobile ? 0.95 : (isTablet ? 0.9 : 0.95);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return _PlatformFeatureCard(
              feature: feature,
              isMobile: isMobile,
              isTablet: isTablet,
              isDesktop: isDesktop,
            );
          },
        );
      },
    );
  }
}

class _PlatformFeatureCard extends StatefulWidget {
  final Map<String, dynamic> feature;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  const _PlatformFeatureCard({
    required this.feature,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  State<_PlatformFeatureCard> createState() => _PlatformFeatureCardState();
}

class _PlatformFeatureCardState extends State<_PlatformFeatureCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final iconSize = widget.isMobile ? 24.0 : (widget.isTablet ? 30.0 : 32.0);
    final iconContainerSize =
        widget.isMobile ? 50.0 : (widget.isTablet ? 60.0 : 64.0);
    final padding = widget.isMobile ? 14.0 : (widget.isTablet ? 20.0 : 24.0);
    final titleSize = widget.isMobile ? 13.0 : (widget.isTablet ? 15.0 : 16.0);
    final descSize = widget.isMobile ? 10.0 : (widget.isTablet ? 12.0 : 13.0);

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0, isHovered ? -8 : 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.isMobile ? 20 : 24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey[50]!],
          ),
          border: Border.all(
            color:
                isHovered
                    ? (widget.feature['color'] as Color).withValues(alpha: 0.3)
                    : Colors.grey[200]!,
            width: isHovered ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isHovered
                      ? (widget.feature['color'] as Color).withValues(
                        alpha: 0.15,
                      )
                      : Colors.black.withValues(alpha: 0.06),
              blurRadius: isHovered ? 25 : 12,
              offset: Offset(0, isHovered ? 12 : 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (widget.feature['color'] as Color).withValues(alpha: 0.2),
                      (widget.feature['color'] as Color).withValues(
                        alpha: 0.05,
                      ),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.feature['icon'] as IconData,
                  size: iconSize,
                  color: widget.feature['color'] as Color,
                ),
              ),
              SizedBox(height: widget.isMobile ? 10 : 16),
              Flexible(
                child: Text(
                  widget.feature['title'] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: titleSize,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: widget.isMobile ? 5 : 8),
              Flexible(
                child: Text(
                  widget.feature['desc'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: descSize,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppStoreBadge extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isMobile;

  const _AppStoreBadge({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isMobile,
  });

  @override
  State<_AppStoreBadge> createState() => _AppStoreBadgeState();
}

class _AppStoreBadgeState extends State<_AppStoreBadge> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final padding =
        widget.isMobile
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 14)
            : const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    final iconSize = widget.isMobile ? 20.0 : 24.0;
    final fontSize = widget.isMobile ? 14.0 : 16.0;
    final borderRadius = widget.isMobile ? 14.0 : 16.0;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isHovered ? 0.15 : 0.1),
                blurRadius: isHovered ? 20 : 10,
                offset: Offset(0, isHovered ? 8 : 4),
              ),
            ],
            border: Border.all(
              color:
                  isHovered
                      ? AppTheme.brandRed.withValues(alpha: 0.3)
                      : Colors.grey[200]!,
              width: isHovered ? 2 : 1.5,
            ),
          ),
          transform: Matrix4.identity()..translate(0, isHovered ? -4 : 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: iconSize, color: AppTheme.brandBlack),
              SizedBox(width: widget.isMobile ? 12 : 14),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                  color: AppTheme.brandBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isMobile;

  const _ContactChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    required this.isMobile,
  });

  @override
  State<_ContactChip> createState() => _ContactChipState();
}

class _ContactChipState extends State<_ContactChip> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final maxChipWidth =
        widget.isMobile
            ? MediaQuery.of(context).size.width * 0.85
            : MediaQuery.of(context).size.width * 0.75;
    final padding =
        widget.isMobile
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
    final iconSize = widget.isMobile ? 20.0 : 22.0;
    final labelSize = widget.isMobile ? 11.0 : 12.0;
    final valueSize = widget.isMobile ? 12.0 : 13.0;
    final borderRadius = widget.isMobile ? 14.0 : 16.0;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: isHovered ? 0.12 : 0.08),
                Colors.white.withValues(alpha: isHovered ? 0.08 : 0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: isHovered ? 0.3 : 0.2),
              width: isHovered ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isHovered ? 0.2 : 0.1),
                blurRadius: isHovered ? 20 : 10,
                offset: Offset(0, isHovered ? 8 : 2),
              ),
            ],
          ),
          transform: Matrix4.identity()..translate(0, isHovered ? -4 : 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: iconSize),
              SizedBox(width: widget.isMobile ? 10 : 12),
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxChipWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: labelSize,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: widget.isMobile ? 1 : 2),
                      Text(
                        widget.value,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: valueSize,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

Future<void> _launchUri(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    debugPrint('Could not launch $url');
  }
}
