import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/premium_theme.dart';
import '../../core/responsive/responsive_breakpoints.dart';

/// Enhanced Hero Section with Animated Circle Background Pattern
class HeroSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final String primaryActionText;
  final String secondaryActionText;

  const HeroSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.primaryActionText = 'Get Started',
    this.secondaryActionText = 'Learn More',
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final padding = ResponsiveBreakpoints.getHorizontalPadding(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isMobile ? 520 : 700),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumTheme.darkBlack,
            PremiumTheme.darkBlack.withValues(alpha: 0.95),
            PremiumTheme.primaryRed.withValues(alpha: 0.1),
          ],
        ),
        image: DecorationImage(
          image: ResizeImage(NetworkImage(widget.imageUrl), width: 1200),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.7),
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Animated Circle Background Pattern
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _CirclePatternPainter(_controller.value),
                );
              },
            ),
          ),

          // Glass Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: isMobile ? 60 : 100,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 14 : 20,
                    vertical: isMobile ? 8 : 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PremiumTheme.primaryRed.withValues(alpha: 0.2),
                        PremiumTheme.gradientEnd.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: PremiumTheme.primaryRed.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        color: PremiumTheme.primaryRed,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'TRUSTED MULTI-SERVICE PLATFORM',
                        style: TextStyle(
                          color: PremiumTheme.pureWhite,
                          fontSize: isMobile ? 10 : 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isMobile ? 24 : 48),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final showBadgeInline = constraints.maxWidth >= 900;
                    final heading = ShaderMask(
                      shaderCallback:
                          (bounds) => LinearGradient(
                            colors: [
                              PremiumTheme.pureWhite,
                              PremiumTheme.primaryRed,
                              PremiumTheme.pureWhite,
                            ],
                          ).createShader(bounds),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: isMobile ? 34 : 72,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2.0,
                          height: 1.1,
                          color: PremiumTheme.pureWhite,
                        ),
                      ),
                    );

                    if (showBadgeInline) {
                      return /* Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: heading),
                          const SizedBox(width: 24),
                          Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: const GBCBadge(),
                          ),
                        ],
                      ); */ Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: heading),
                          const SizedBox(width: 24),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              GBCBadge(),
                              SizedBox(
                                height: 10,
                              ), // Increase or decrease this value
                            ],
                          ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        heading,
                        const SizedBox(height: 16),
                        const GBCBadge(),
                      ],
                    );
                  },
                ),

                SizedBox(height: isMobile ? 16 : 28),

                // Rich Subtitle
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 24,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.5,
                    height: 1.5,
                    color: PremiumTheme.pureWhite.withValues(alpha: 0.95),
                  ),
                ),

                SizedBox(height: isMobile ? 24 : 48),

                // Stats Row
                if (!isMobile) _buildStatsRow(),

                SizedBox(height: isMobile ? 28 : 56),

                // CTA Buttons
                Wrap(
                  spacing: isMobile ? 12 : 16,
                  runSpacing: 12,
                  children: [
                    _PremiumButton(
                      text: widget.primaryActionText,
                      isPrimary: true,
                      onPressed: widget.onPrimaryAction ?? () {},
                    ),
                    _PremiumButton(
                      text: widget.secondaryActionText,
                      isPrimary: false,
                      onPressed: widget.onSecondaryAction ?? () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatItem(icon: Icons.restaurant_menu, value: '5+', label: 'Services'),
        const SizedBox(width: 40),
        _StatItem(icon: Icons.people, value: '50K+', label: 'Users'),
        const SizedBox(width: 40),
        _StatItem(icon: Icons.store, value: '500+', label: 'Partners'),
        const SizedBox(width: 40),
        _StatItem(icon: Icons.star, value: '4.9', label: 'Rating'),
      ],
    );
  }
}

/// Animated Circle Pattern Painter
class _CirclePatternPainter extends CustomPainter {
  final double animation;

  _CirclePatternPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Multiple expanding circles from different points
    final centers = [
      Offset(size.width * 0.8, size.height * 0.3),
      Offset(size.width * 0.2, size.height * 0.7),
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.3, size.height * 0.5),
    ];

    for (var centerIndex = 0; centerIndex < centers.length; centerIndex++) {
      final center = centers[centerIndex];
      final baseRadius = size.width * 0.15;

      for (var i = 0; i < 6; i++) {
        final progress = (animation + i * 0.2) % 1.0;
        final radius = baseRadius * (1 + progress * 2);

        paint.color = PremiumTheme.primaryRed.withValues(
          alpha: (0.15 - progress * 0.1).clamp(0.0, 0.15),
        );

        canvas.drawCircle(center, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_CirclePatternPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

/// Premium Button Widget
class _PremiumButton extends StatefulWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _PremiumButton({
    required this.text,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: widget.isPrimary ? PremiumTheme.redGradient : null,
          color: widget.isPrimary ? null : Colors.transparent,
          borderRadius: PremiumTheme.mediumRadius,
          border:
              widget.isPrimary
                  ? null
                  : Border.all(color: PremiumTheme.pureWhite, width: 2),
          boxShadow:
              widget.isPrimary && _isHovered
                  ? [
                    BoxShadow(
                      color: PremiumTheme.primaryRed.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                  : null,
        ),
        transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: PremiumTheme.pureWhite,
          ),
        ),
      ),
    );
  }
}

/// Stat Item Widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: PremiumTheme.primaryRed, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: PremiumTheme.pureWhite,
                letterSpacing: -1.0,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: PremiumTheme.pureWhite.withValues(alpha: 0.7),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class GBCBadge extends StatelessWidget {
  const GBCBadge({super.key});

  static const _url = 'https://www.getondial.com/';

  Future<void> _openUrl() async {
    final uri = Uri.parse(_url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return _GBCBadgeHoverable(onTap: _openUrl);
  }
}

class _GBCBadgeHoverable extends StatefulWidget {
  final VoidCallback onTap;

  const _GBCBadgeHoverable({required this.onTap});

  @override
  State<_GBCBadgeHoverable> createState() => _GBCBadgeHoverableState();
}

class _GBCBadgeHoverableState extends State<_GBCBadgeHoverable> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: ' GBC ALLIANCE',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: Matrix4.diagonal3Values(
            _isHovered ? 1.05 : 1.0,
            _isHovered ? 1.05 : 1.0,
            1.0,
          ),
          constraints: const BoxConstraints(minWidth: 160, minHeight: 60),
          decoration: BoxDecoration(
            color: PremiumTheme.darkBlack.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: PremiumTheme.primaryRed, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF000000,
                ).withValues(alpha: _isHovered ? 0.25 : 0.16),
                blurRadius: _isHovered ? 22 : 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              splashFactory: InkRipple.splashFactory,
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 13,
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    children: [
                      TextSpan(
                        text: 'G',
                        style: TextStyle(color: PremiumTheme.primaryRed),
                      ),
                      TextSpan(
                        text: 'B',
                        style: TextStyle(color: PremiumTheme.primaryRed),
                      ),
                      TextSpan(
                        text: 'C',
                        style: TextStyle(color: PremiumTheme.primaryRed),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
