import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/responsive/responsive_breakpoints.dart';
import '../../core/theme/premium_theme.dart';
import '../../shared/layout/premium_section.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/social_media_section.dart';
import '../../core/util/global_keyboard_scroll_handler.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final ScrollController _scrollController = ScrollController();
  static const double _scrollStep = 100.0;

  @override
  void initState() {
    super.initState();
    _setupKeyboardNavigation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
    final padding = ResponsiveBreakpoints.getHorizontalPadding(context);
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    return PrimaryScrollController(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
        children: [
          _buildHero(context, padding, isMobile),
          PremiumSection(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 900 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Who We Are',
                    subtitle: 'Transforming local commerce through technology',
                    centerAlign: false,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'We are a technology-driven local services company connecting people to everything they need — from daily essentials to healthcare and career opportunities. Our mission is to simplify local commerce, empower small vendors, and make life effortless.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Founded with a vision to bridge the gap between local businesses and modern consumers, we leverage cutting-edge technology to create seamless experiences that benefit both service providers and users.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          PremiumSection(
            backgroundColor: PremiumTheme.lightGrey,
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 1 : (isDesktop ? 3 : 2),
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: isMobile ? 3 : 1.4,
              children: const [
                _ValueCard(
                  icon: Icons.speed,
                  title: 'Fast & Reliable',
                  description: 'Quick service delivery with unmatched reliability',
                ),
                _ValueCard(
                  icon: Icons.verified_user,
                  title: 'Trusted Partners',
                  description: 'All vendors are verified and certified',
                ),
                _ValueCard(
                  icon: Icons.support_agent,
                  title: '24/7 Support',
                  description: 'Round-the-clock customer assistance',
                ),
                _ValueCard(
                  icon: Icons.local_offer,
                  title: 'Best Prices',
                  description: 'Competitive pricing across all services',
                ),
                _ValueCard(
                  icon: Icons.location_on,
                  title: 'Local Focus',
                  description: 'Supporting local businesses and communities',
                ),
                _ValueCard(
                  icon: Icons.smartphone,
                  title: 'Easy to Use',
                  description: 'User-friendly platform for all age groups',
                ),
              ],
            ),
          ),
          PremiumSection(
            backgroundGradient: PremiumTheme.redGradient,
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 32,
                  runSpacing: 24,
                  children: [
                    _StatItem(
                      value: '10,000+',
                      label: 'Active Users',
                      isMobile: isMobile,
                    ),
                    _StatItem(
                      value: '500+',
                      label: 'Featured Stores',
                      isMobile: isMobile,
                    ),
                    _StatItem(
                      value: '50+',
                      label: 'Cities',
                      isMobile: isMobile,
                    ),
                    _StatItem(
                      value: '99%',
                      label: 'Satisfaction',
                      isMobile: isMobile,
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Text(
                  'Download Our Mobile App',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Get the best experience on mobile',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse('https://apps.apple.com/in/app/get-on-dial/id6476094551');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.apple),
                      label: const Text('App Store'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: PremiumTheme.primaryRed,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 24 : 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse('https://play.google.com/store/apps/details?id=com.getondial.app&pcampaignid=web_share');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.android),
                      label: const Text('Google Play'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: PremiumTheme.primaryRed,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 24 : 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PremiumSection(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: 48,
              ),
              child: const SocialMediaSection(showTitle: true, horizontal: true),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

Widget _buildHero(BuildContext context, double padding, bool isMobile) {
  final highlights = [
    'Pan-India reach',
    'Local-first operations',
    'Trusted by enterprises',
  ];

  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      image: const DecorationImage(
        image: NetworkImage('https://images.unsplash.com/photo-1504384308090-c894fdcc538d'),
        fit: BoxFit.cover,
      ),
      color: PremiumTheme.darkBlack,
    ),
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isMobile ? 80 : 140,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.black.withValues(alpha: 0.4),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveBreakpoints.getMaxContentWidth(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About Us',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontSize: isMobile ? 42 : 60,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Connecting India to everything — food, healthcare, jobs, logistics, and commerce.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: highlights.map(_AboutBadge.new).toList(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _AboutBadge extends StatelessWidget {
  final String label;

  const _AboutBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  
  const _ValueCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40,
              color: PremiumTheme.primaryRed,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool isMobile;
  
  const _StatItem({
    required this.value,
    required this.label,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: isMobile ? 24 : 48,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontSize: isMobile ? 12 : 16,
          ),
        ),
      ],
    );
  }
}
