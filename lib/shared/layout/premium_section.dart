import 'package:flutter/material.dart';
import '../../core/responsive/responsive_breakpoints.dart';
import '../../core/theme/premium_theme.dart';

/// Centers page content with consistent horizontal padding,
/// max-width constraints, and optional background treatments.
class PremiumSection extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final bool constrainWidth;
  final double? maxWidth;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final DecorationImage? backgroundImage;

  const PremiumSection({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.backgroundGradient,
    this.constrainWidth = true,
    this.maxWidth,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveBreakpoints.getHorizontalPadding(context);
    final verticalPadding = ResponsiveBreakpoints.getSectionSpacing(context) * 0.65;
    final contentPadding = padding ??
        EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        );

    Widget content = Padding(
      padding: contentPadding,
      child: child,
    );

    if (constrainWidth) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? ResponsiveBreakpoints.getMaxContentWidth(context),
          ),
          child: content,
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? PremiumTheme.pureWhite,
        gradient: backgroundGradient,
        borderRadius: borderRadius,
        border: border,
        boxShadow: boxShadow,
        image: backgroundImage,
      ),
      child: content,
    );
  }
}
