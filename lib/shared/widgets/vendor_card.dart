import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/premium_theme.dart';
import '../../core/models/vendor_model.dart';

class VendorCard extends StatefulWidget {
  final VendorModel vendor;
  final VoidCallback? onTap;
  final int? moduleId; // Add moduleId to pass to detail page

  const VendorCard({super.key, required this.vendor, this.onTap, this.moduleId});

  @override
  State<VendorCard> createState() => _VendorCardState();
}

class _VendorCardState extends State<VendorCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final displayCategories =
        widget.vendor.categories.take(isMobile ? 2 : 4).toList();

    return RepaintBoundary(
      child: MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
        decoration: BoxDecoration(
          color: PremiumTheme.pureWhite,
          borderRadius: PremiumTheme.largeRadius,
          border: Border.all(
            color:
                _isHovered ? PremiumTheme.primaryRed : PremiumTheme.lightGrey,
            width: _isHovered ? 2 : 1,
          ),
          boxShadow:
              _isHovered ? PremiumTheme.hoverShadow : PremiumTheme.cardShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: PremiumTheme.largeRadius,
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 8 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Opacity(
                          opacity: 0.2,
                          child: Container(
                            width: isMobile ? 64 : 88,
                            height: isMobile ? 64 : 88,
                            decoration: BoxDecoration(
                              gradient: PremiumTheme.redGradient,
                              borderRadius: BorderRadius.circular(
                                isMobile ? 32 : 44,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                isMobile ? 30 : 42,
                              ),
                              child: Image.network(
                                widget.vendor.logoUrl,
                                width: isMobile ? 68 : 92,
                                height: isMobile ? 68 : 92,
                                fit: BoxFit.cover,
                                cacheWidth: 184,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: isMobile ? 68 : 92,
                                    height: isMobile ? 68 : 92,
                                    decoration: BoxDecoration(
                                      color: PremiumTheme.primaryRed,
                                      borderRadius: BorderRadius.circular(
                                        isMobile ? 34 : 46,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        widget.vendor.name.isNotEmpty
                                            ? widget.vendor.name[0]
                                                .toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isMobile ? 20 : 32,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 4 : 8),
                  Center(
                    child: Text(
                      widget.vendor.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: isMobile ? 12 : 16,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: isMobile ? 3 : 5),
                  Divider(
                    color: PremiumTheme.lightGrey,
                    thickness: 1,
                    height: 1,
                  ),
                  SizedBox(height: isMobile ? 4 : 8),
                  Center(
                    child: Text(
                      widget.vendor.shortDescription,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PremiumTheme.mediumGrey,
                        fontSize: isMobile ? 11 : 12,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (displayCategories.isNotEmpty) ...[
                    SizedBox(height: isMobile ? 2 : 4),
                    Wrap(
                      spacing: isMobile ? 2 : 4,
                      runSpacing: isMobile ? 2 : 4,
                      alignment: WrapAlignment.center,
                      children:
                          displayCategories.map((category) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 5 : 8,
                                vertical: isMobile ? 1 : 3,
                              ),
                              decoration: BoxDecoration(
                                color: PremiumTheme.primaryRed.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(
                                  isMobile ? 6 : 10,
                                ),
                              ),
                              child: Text(
                                category,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: PremiumTheme.primaryRed,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isMobile ? 9 : 12,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                  SizedBox(height: isMobile ? 2 : 4),
                  Divider(
                    color: PremiumTheme.lightGrey,
                    thickness: 1,
                    height: 1,
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: isMobile ? 12 : 18,
                          color: PremiumTheme.deepRed,
                        ),
                        SizedBox(width: isMobile ? 3 : 5),
                        Flexible(
                          child: Text(
                            widget.vendor.location,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: PremiumTheme.mediumGrey,
                              fontSize: isMobile ? 10 : 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 6 : 8),
                  Center(
                    child: OutlinedButton(
                      onPressed:
                          widget.onTap ??
                          () {
                            // Fallback navigation if onTap is null
                            final moduleIdParam = widget.moduleId != null 
                                ? '?moduleId=${widget.moduleId}' 
                                : '';
                            context.push('/vendor/${widget.vendor.id}$moduleIdParam');
                          },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 6 : 10,
                          horizontal: isMobile ? 8 : 16,
                        ),
                        minimumSize: Size(0, isMobile ? 28 : 40),
                        side: BorderSide(
                          color:
                              _isHovered
                                  ? PremiumTheme.primaryRed
                                  : PremiumTheme.darkBlack,
                          width: isMobile ? 1.2 : 1.6,
                        ),
                        foregroundColor:
                            _isHovered
                                ? PremiumTheme.primaryRed
                                : PremiumTheme.darkBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            isMobile ? 8 : 10,
                          ),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}
