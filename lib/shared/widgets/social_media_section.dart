import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:line_icons/line_icons.dart';
import '../../core/theme/premium_theme.dart';

class SocialMediaSection extends StatelessWidget {
  final bool showTitle;
  final bool compact;
  final bool horizontal;

  const SocialMediaSection({
    super.key,
    this.showTitle = true,
    this.compact = false,
    this.horizontal = true,
  });

  static const String facebookUrl =
      'https://www.facebook.com/getondial99?rdid=VuH4VQC2ZlvSWBiP&share_url=https%3A%2F%2Fwww.facebook.com%2Fshare%2F1CkNnff4xp%2F#';
  static const String instagramUrl =
      'https://www.instagram.com/accounts/login/?next=%2Fgetondial%2F&source=omni_redirect';
  static const String pinterestUrl = 'https://in.pinterest.com/getondial';
  static const String linkedInUrl = 'https://www.linkedin.com/in/get-on-dial-132a71128/';
  static const String twitterUrl = 'https://x.com/getondialapp';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    if (compact) {
      return _buildCompactLayout(context, isMobile);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTitle) ...[
          Text(
            'Follow Us',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: PremiumTheme.darkBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stay connected with us on social media',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
        if (horizontal)
          _buildHorizontalLayout(context, isMobile)
        else
          _buildVerticalLayout(context, isMobile),
      ],
    );
  }

  Widget _buildHorizontalLayout(BuildContext context, bool isMobile) {
    return Wrap(
      spacing: isMobile ? 12 : 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: _buildSocialButtons(context, isMobile),
    );
  }

  Widget _buildVerticalLayout(BuildContext context, bool isMobile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _buildSocialButtons(context, isMobile)
          .map((btn) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(width: double.infinity, child: btn),
              ))
          .toList(),
    );
  }

  Widget _buildCompactLayout(BuildContext context, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: _buildSocialButtons(context, isMobile, isCompact: true),
    );
  }

  List<Widget> _buildSocialButtons(BuildContext context, bool isMobile, {bool isCompact = false}) {
    final socialLinks = [
      _SocialLinkData(
        icon: LineIcons.facebook,
        label: 'Facebook',
        url: facebookUrl,
        color: const Color(0xFF1877F2),
      ),
      _SocialLinkData(
        icon: LineIcons.instagram,
        label: 'Instagram',
        url: instagramUrl,
        color: const Color(0xFF515BD4),
        gradientColors: const [
          Color(0xFFFEDA77),
          Color(0xFFF58529),
          Color(0xFFDD2A7B),
          Color(0xFF8134AF),
          Color(0xFF515BD4),
        ],
        iconColor: Colors.white,
      ),
      _SocialLinkData(
        icon: LineIcons.pinterest,
        label: 'Pinterest',
        url: pinterestUrl,
        color: const Color(0xFFBD081C),
      ),
      _SocialLinkData(
        icon: LineIcons.linkedin,
        label: 'LinkedIn',
        url: linkedInUrl,
        color: const Color(0xFF0077B5),
      ),
      _SocialLinkData(
        icon: LineIcons.twitter,
        label: 'Twitter',
        url: twitterUrl,
        color: const Color(0xFF1DA1F2),
      ),
    ];

    return socialLinks.map((data) {
      if (isCompact) {
        return _CompactSocialButton(
          icon: data.icon,
          tooltip: data.label,
          url: data.url,
          color: data.color,
          gradientColors: data.gradientColors,
          iconColor: data.iconColor,
        );
      }
      return _EnhancedSocialButton(
        icon: data.icon,
        label: data.label,
        url: data.url,
        color: data.color,
        gradientColors: data.gradientColors,
        iconColor: data.iconColor,
        isMobile: isMobile,
      );
    }).toList();
  }
}

class _SocialLinkData {
  final IconData icon;
  final String label;
  final String url;
  final Color color;
  final List<Color>? gradientColors;
  final Color? iconColor;

  const _SocialLinkData({
    required this.icon,
    required this.label,
    required this.url,
    required this.color,
    this.gradientColors,
    this.iconColor,
  });
}

class _EnhancedSocialButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String url;
  final Color color;
  final List<Color>? gradientColors;
  final Color? iconColor;
  final bool isMobile;

  const _EnhancedSocialButton({
    required this.icon,
    required this.label,
    required this.url,
    required this.color,
    this.gradientColors,
    this.iconColor,
    required this.isMobile,
  });

  @override
  State<_EnhancedSocialButton> createState() => _EnhancedSocialButtonState();
}

class _EnhancedSocialButtonState extends State<_EnhancedSocialButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  Future<void> _launchUrl() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: _launchUrl,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isMobile ? 20 : 24,
            vertical: widget.isMobile ? 14 : 16,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isHovered
                  ? [
                      widget.color.withOpacity(0.15),
                      widget.color.withOpacity(0.08),
                    ]
                  : [
                      Colors.white,
                      Colors.grey[50]!,
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withOpacity(0.5)
                  : widget.color.withOpacity(0.2),
              width: _isHovered ? 2 : 1.5,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.gradientColors != null
                      ? Colors.white.withOpacity(0.2)
                      : widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.iconColor ?? widget.color,
                  size: widget.isMobile ? 20 : 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.isMobile ? 14 : 15,
                  fontWeight: FontWeight.w600,
                  color: widget.gradientColors != null ? Colors.white : (_isHovered ? widget.color : Colors.grey[800]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactSocialButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final String url;
  final Color color;
  final List<Color>? gradientColors;
  final Color? iconColor;

  const _CompactSocialButton({
    required this.icon,
    required this.tooltip,
    required this.url,
    required this.color,
    this.gradientColors,
    this.iconColor,
  });

  @override
  State<_CompactSocialButton> createState() => _CompactSocialButtonState();
}

class _CompactSocialButtonState extends State<_CompactSocialButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  Future<void> _launchUrl() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: _launchUrl,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: widget.gradientColors != null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.gradientColors!,
                    )
                  : null,
              color: widget.gradientColors == null
                  ? (_isHovered
                      ? widget.color.withOpacity(0.15)
                      : widget.color.withOpacity(0.08))
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.gradientColors == null
                    ? (_isHovered
                        ? widget.color.withOpacity(0.4)
                        : widget.color.withOpacity(0.2))
                    : Colors.transparent,
                width: widget.gradientColors == null ? (_isHovered ? 2 : 1.5) : 0,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              widget.icon,
              color: widget.iconColor ?? widget.color,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

