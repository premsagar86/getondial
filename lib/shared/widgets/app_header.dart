import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/responsive/responsive_breakpoints.dart';
import '../../core/theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  final bool showCTA;

  const AppHeader({super.key, this.showCTA = true});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final padding = ResponsiveBreakpoints.getHorizontalPadding(context);
    final navItems = <_NavItem>[
      _NavItem(label: 'Home', onTap: () => context.go('/')),
      _NavItem(label: 'Vendors', onTap: () => context.go('/vendors')),
      _NavItem(label: 'About', onTap: () => context.go('/about')),
      _NavItem(label: 'Contact', onTap: () => context.go('/contact')),
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: isMobile ? 16 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.brandRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.travel_explore, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'GET ON DIAL',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Spacer(),
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => _MobileNav(items: navItems, showCTA: showCTA),
                );
              },
            )
          else
            Row(
              children: navItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextButton(
                    onPressed: item.onTap,
                    child: Text(item.label),
                  ),
                );
              }).toList(),
            ),
          if (!isMobile && showCTA)
            ElevatedButton(
              onPressed: () => context.go('/contact'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brandRed),
              child: const Text('Book a Demo'),
            ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String label;
  final VoidCallback onTap;
  _NavItem({required this.label, required this.onTap});
}

class _MobileNav extends StatelessWidget {
  final List<_NavItem> items;
  final bool showCTA;
  const _MobileNav({required this.items, this.showCTA = true});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...items.map((item) => ListTile(
                  title: Text(item.label),
                  onTap: () {
                    Navigator.of(context).pop();
                    item.onTap();
                  },
                )),
            if (showCTA) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    GoRouter.of(context).go('/contact');
                  },
                  child: const Text('Book a Demo'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
