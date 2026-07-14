import 'package:flutter/material.dart';
import '../../core/theme/premium_theme.dart';
import '../../core/responsive/responsive_breakpoints.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool centerAlign;
  
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.centerAlign = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final titleStyle = isMobile
        ? Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            )
        : Theme.of(context).textTheme.displaySmall?.copyWith(
              letterSpacing: -1,
            );
    return Column(
      crossAxisAlignment: centerAlign ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: centerAlign ? Alignment.center : Alignment.centerLeft,
          child: Container(
            width: 48,
            height: 4,
            decoration: const BoxDecoration(
              gradient: PremiumTheme.redGradient,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: titleStyle,
          textAlign: centerAlign ? TextAlign.center : TextAlign.left,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: PremiumTheme.mediumGrey,
              fontSize: isMobile ? 14 : null,
              height: 1.6,
            ),
            textAlign: centerAlign ? TextAlign.center : TextAlign.left,
          ),
        ],
      ],
    );
  }
}
