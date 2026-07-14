import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../responsive/responsive_breakpoints.dart';

class NavigationItem {
  final String label;
  final IconData icon;
  final String route;
  
  const NavigationItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

class AppNavigation {
  static const List<NavigationItem> items = [
    NavigationItem(label: 'Home', icon: Icons.home, route: '/'),
    NavigationItem(label: 'About', icon: Icons.info, route: '/about'),
    NavigationItem(label: 'Partners', icon: Icons.business, route: '/vendors'),
    NavigationItem(label: 'Contact', icon: Icons.contact_mail, route: '/contact'),
  ];
  
  static int getCurrentIndex(String location) {
    for (int i = 0; i < items.length; i++) {
      if (items[i].route == location) {
        return i;
      }
    }
    return 0;
  }
}

class AdaptiveScaffold extends StatelessWidget {
  final Widget child;
  
  const AdaptiveScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);
    final currentLocation = GoRouterState.of(context).uri.path;
    final currentIndex = AppNavigation.getCurrentIndex(currentLocation);

    if (isMobile) {
      return _MobileScaffold(
        currentIndex: currentIndex,
        currentLocation: currentLocation,
        child: child,
      );
    } else if (isTablet) {
      return _TabletScaffold(
        currentIndex: currentIndex,
        currentLocation: currentLocation,
        child: child,
      );
    } else {
      return _DesktopScaffold(
        currentIndex: currentIndex,
        currentLocation: currentLocation,
        child: child,
      );
    }
  }
}

// Mobile: Bottom Navigation
class _MobileScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final String currentLocation;
  
  const _MobileScaffold({
    required this.child,
    required this.currentIndex,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GET ON DIAL'),
        centerTitle: true,
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          context.go(AppNavigation.items[index].route);
        },
        items: AppNavigation.items.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

// Tablet: Drawer Navigation
class _TabletScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final String currentLocation;
  
  const _TabletScaffold({
    required this.child,
    required this.currentIndex,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GET ON DIAL '),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppTheme.brandRed,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.business,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'GET ON DIAL',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Connecting Everything',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            ...AppNavigation.items.map((item) {
              final isSelected = item.route == currentLocation;
              return ListTile(
                leading: Icon(
                  item.icon,
                  color: isSelected ? AppTheme.brandRed : AppTheme.greyText,
                ),
                title: Text(
                  item.label,
                  style: TextStyle(
                    color: isSelected ? AppTheme.brandRed : AppTheme.brandBlack,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                selected: isSelected,
                selectedTileColor: AppTheme.brandRed.withValues(alpha: 0.1),
                onTap: () {
                  context.go(item.route);
                  Navigator.of(context).pop(); // Close drawer
                },
              );
            }),
          ],
        ),
      ),
      body: child,
    );
  }
}

// Desktop: Navigation Rail
class _DesktopScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final String currentLocation;
  
  const _DesktopScaffold({
    required this.child,
    required this.currentIndex,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              context.go(AppNavigation.items[index].route);
            },
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.brandRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'GOD\nBPS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            destinations: AppNavigation.items.map((item) {
              return NavigationRailDestination(
                icon: Icon(item.icon),
                label: Text(item.label),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
