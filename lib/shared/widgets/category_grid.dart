import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/api_provider.dart';
import '../../core/theme/premium_theme.dart';
import '../../core/models/category_model.dart';

class CategoryGrid extends ConsumerWidget {
  final int? moduleId;
  final String title;
  final bool isMobile;

  const CategoryGrid({
    super.key,
    required this.moduleId,
    required this.title,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider(moduleId));

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 48 : 72,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 28 : 40,
              fontWeight: FontWeight.w800,
              color: PremiumTheme.darkBlack,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Browse categories tailored to this service',
            style: TextStyle(
              color: PremiumTheme.mediumGrey,
            ),
          ),
          const SizedBox(height: 32),
          categoriesAsync.when(
            data: (cats) {
              if (cats.isEmpty) {
                return Text('No categories available',
                    style: TextStyle(color: PremiumTheme.mediumGrey));
              }
              final crossAxisCount = isMobile ? 2 : 4;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cats.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final c = cats[index];
                  return _CategoryTile(cat: c, isMobile: isMobile);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Failed to load categories: $e'),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatefulWidget {
  final CategoryModel cat;
  final bool isMobile;
  const _CategoryTile({required this.cat, required this.isMobile});

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final c = widget.cat;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, _hover ? -6.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _hover ? PremiumTheme.hoverShadow : PremiumTheme.cardShadow,
          border: Border.all(
            color: _hover
                ? PremiumTheme.primaryRed.withValues(alpha: 0.3)
                : PremiumTheme.lightGrey,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.go('/categories/${c.id}'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: PremiumTheme.lightGrey,
                      child: Image.network(
                        c.image,
                        fit: BoxFit.cover,
                        cacheWidth: 300,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(Icons.category,
                              color: PremiumTheme.mediumGrey),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  c.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: PremiumTheme.darkBlack,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _meta(c),
                  style: TextStyle(fontSize: 12, color: PremiumTheme.mediumGrey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _meta(CategoryModel c) {
    final children = c.childes.length;
    final products = c.productsCount;
    if (children > 0 && products > 0) return '$children sub • $products items';
    if (children > 0) return '$children subcategories';
    if (products > 0) return '$products items';
    return 'Category';
  }
}

