import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../navigation/premium_web_navigation.dart';
import '../../features/home/home_page.dart';
import '../../features/about/about_page.dart';
import '../../features/vendors/vendors_page.dart';
import '../../features/vendors/vendor_detail_page.dart';
import '../../features/contact/contact_page.dart';
import '../../features/cart/cart_page.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/categories/category_detail_page.dart';
import '../../features/debug/debug_panel_page.dart';
import '../../features/parcel/parcel_delivery_page.dart';
import '../../features/search/search_page.dart';
import '../util/global_keyboard_scroll_handler.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  // observers: [KeyboardScrollNavigatorObserver()],
  routes: [
    // Auth routes (outside shell route)
    GoRoute(
      path: '/login',
      pageBuilder:
          (context, state) => const NoTransitionPage(child: GlobalKeyboardScrollWrapper(child: LoginScreen())),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder:
          (context, state) => const NoTransitionPage(child: GlobalKeyboardScrollWrapper(child: SignUpScreen())),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return PremiumAdaptiveScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder:
              (context, state) => const NoTransitionPage(child: HomePage()),
        ),
        GoRoute(
          path: '/about',
          pageBuilder:
              (context, state) => const NoTransitionPage(child: AboutPage()),
        ),
        GoRoute(
          path: '/vendors',
          pageBuilder: (context, state) {
            final mid =
                int.tryParse(state.uri.queryParameters['moduleId'] ?? '');
            return NoTransitionPage(child: VendorsPage(moduleId: mid));
          },
        ),

        // GoRoute(
        //   path: '/vendors',
        //   pageBuilder: (context, state) {
        //     final q = state.uri.queryParameters['moduleId'];
        //     final mid = q != null ? int.tryParse(q) : null;
        //     return NoTransitionPage(child: VendorsPage(moduleId: mid));
        //   },
        //   routes: [
        //     GoRoute(
        //       path: ':vendorId',
        //       builder: (context, state) {
        //         final vendorId = state.pathParameters['vendorId']!;
        //         return VendorDetailPage(vendorId: vendorId);
        //       },
        //     ),
        //   ],
        // ),
        GoRoute(
          path: '/contact',
          pageBuilder:
              (context, state) => const NoTransitionPage(child: ContactPage()),
        ),
        GoRoute(
          path: '/debug',
          pageBuilder:
              (context, state) =>
                  const NoTransitionPage(child: DebugPanelPage()),
        ),
        GoRoute(
          path: '/categories/:id',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return NoTransitionPage(child: CategoryDetailPage(categoryId: id));
          },
        ),
        GoRoute(
          path: '/parcel-delivery',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ParcelDeliveryPage()),
        ),
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SearchPage()),
        ),
        GoRoute(
          path: '/cart',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: CartPage()),
        ),
        // Store route with hash-based URL format: /#/store?id=xxx
        GoRoute(
          path: '/store',
          redirect: (context, state) {
            // If moduleId is present but no vendor ID, redirect to vendors page
            final q = state.uri.queryParameters['moduleId'];
            final vendorId = state.uri.queryParameters['id'] ?? '';
            if (q != null && q.isNotEmpty && vendorId.isEmpty) {
              debugPrint('Redirecting /store to vendors page with moduleId: $q');
              return '/vendors?moduleId=$q';
            }
            return null; // Continue to normal route
          },
          pageBuilder: (context, state) {
            final vendorId = state.uri.queryParameters['id'] ?? '';
            final q = state.uri.queryParameters['moduleId'];
            final mid = q != null ? int.tryParse(q) : null;
            debugPrint('Store route - ID: $vendorId, ModuleId: $mid');
            if (vendorId.isEmpty) {
              // Redirect to home if no ID provided
              return NoTransitionPage(child: HomePage());
            }
            return NoTransitionPage(
              child: VendorDetailPage(vendorId: vendorId, moduleId: mid),
            );
          },
        ),
      ],
    ),
    // Vendor Detail (outside shell route for full screen)
    // Handle both /vendor/:id and /vendor/:id/:slug formats
    // Route with slug (for shared links like /vendor/398/new-mini-kaveri-tiffins-and-meals)
    GoRoute(
      path: '/vendor/:id/:slug',
      builder: (context, state) {
        final vendorId = state.pathParameters['id']!;
        final slug = state.pathParameters['slug'] ?? ''; // Capture slug but ignore for logic
        final q = state.uri.queryParameters['moduleId'];
        final mid = q != null ? int.tryParse(q) : null;
        debugPrint('Vendor route with slug - ID: $vendorId, Slug: $slug, ModuleId: $mid');
        return VendorDetailPage(vendorId: vendorId, moduleId: mid);
      },
    ),
    // Route without slug (direct links like /vendor/398)
    GoRoute(
      path: '/vendor/:id',
      builder: (context, state) {
        final vendorId = state.pathParameters['id']!;
        final q = state.uri.queryParameters['moduleId'];
        final mid = q != null ? int.tryParse(q) : null;
        debugPrint('Vendor route without slug - ID: $vendorId, ModuleId: $mid');
        return VendorDetailPage(vendorId: vendorId, moduleId: mid);
      },
    ),
  ],
  errorBuilder:
      (context, state) {
        // Debug: Print the failed URL
        debugPrint('404 Error - Failed URL: ${state.uri}');
        debugPrint('404 Error - Path: ${state.uri.path}');
        debugPrint('404 Error - Path Parameters: ${state.pathParameters}');
        
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  '404 - Page Not Found',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Path: ${state.uri.path}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        );
      },
);
