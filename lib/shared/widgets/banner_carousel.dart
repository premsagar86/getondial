import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/providers/api_provider.dart';
import '../../core/models/banner_model.dart';

class BannerCarousel extends ConsumerStatefulWidget {
  final bool featured;
  const BannerCarousel({super.key, this.featured = true});

  @override
  ConsumerState<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends ConsumerState<BannerCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  int _index = 0;
  Timer? _timer;
  int _itemCount = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients || _itemCount <= 1) return;
      final next = (_index + 1) % _itemCount;
      try {
        _controller.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncBanners = ref.watch(featuredBannersProvider);
    return asyncBanners.when(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        // update count used by timer; no setState needed
        _itemCount = list.length;
        return Column(
          children: [
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _controller,
                itemCount: list.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _BannerCard(banner: list[i]),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(list.length.clamp(0, 8), (i) {
                final active = i == _index % list.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 14 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? Colors.redAccent : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(100),
                  ),
                );
              }),
            ),
          ],
        );
      },
      loading: () => const _BannerSkeleton(),
      error: (e, _) => const _BannerSkeleton(showMessage: true),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final BannerModel banner;
  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context, banner),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: banner.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 800,
                memCacheHeight: 360,
                placeholder: (context, url) => Container(color: Colors.grey.shade200),
                errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    banner.type.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, BannerModel b) {
    final t = b.type.toLowerCase();
    if (t.contains('store') || t.contains('vendor')) {
      final id = b.data.isNotEmpty ? b.data : '';
      if (id.isNotEmpty) {
        context.go('/vendor/$id');
        return;
      }
    }
    // Extend for items/links if needed
  }
}

class _BannerSkeleton extends StatelessWidget {
  final bool showMessage;
  const _BannerSkeleton({this.showMessage = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: 2,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade300, Colors.grey.shade200],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (showMessage)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Banners will be right back',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
