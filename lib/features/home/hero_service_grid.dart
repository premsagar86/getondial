import 'package:flutter/material.dart';

/// 1. The Parent Widget: Displays the Swiggy/Zomato style items
class HeroServiceGrid extends StatelessWidget {
  const HeroServiceGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Standard items found in major delivery apps like Swiggy and Zomato
    final List<Map<String, dynamic>> services = [
      {
        'label': 'Food Delivery',
        'icon': Icons.lunch_dining, // Burger/Food icon
        'action': () => debugPrint('Navigating to Food Delivery...'),
      },
      {
        'label': 'Instamart / Grocery',
        'icon': Icons.shopping_basket, // Basket icon
        'action': () => debugPrint('Navigating to Grocery...'),
      },
      {
        'label': 'Dining / Out',
        'icon': Icons.restaurant, // Fork and knife icon
        'action': () => debugPrint('Navigating to Dine-In...'),
      },
      {
        'label': 'Genie / Packages',
        'icon': Icons.local_shipping, // Delivery truck icon
        'action': () => debugPrint('Navigating to Packages...'),
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: services.map((service) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: _HeroActionButton(
                icon: service['icon'] as IconData,
                label: service['label'] as String,
                onPressed: service['action'] as VoidCallback,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 2. The Reusable Button Widget
class _HeroActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _HeroActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<_HeroActionButton> createState() => _HeroActionButtonState();
}

class _HeroActionButtonState extends State<_HeroActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Using MouseRegion for web/desktop hover effects (since this is a Flutter Web app)
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.1 : 0.04),
                blurRadius: _isHovered ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
            // Adding a subtle border that changes on hover
            border: Border.all(
              color: _isHovered ? Colors.red.shade200 : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container with a soft background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 28,
                  color: Colors.red.shade700, // Using the primary red from your design system
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  height: 1.2,
                  color: Color(0xFF0B0B0B), // Brand Black
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}