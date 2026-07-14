import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Circle avatar that loads a network image but falls back to a provided widget
/// (e.g. initials) when the download errors or the URL is empty.
class NetworkCircleAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final Widget fallback;
  final Color backgroundColor;

  const NetworkCircleAvatar({
    super.key,
    required this.imageUrl,
    required this.radius,
    required this.fallback,
    this.backgroundColor = const Color(0xFFE5E7EB),
  });

  /// Helper function to fix CORS issues for web by using a proxy
  String _fixCorsUrl(String url) {
    if (kIsWeb && url.contains('pravatar.cc')) {
      // Use a CORS proxy for pravatar.cc images on web
      return 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: _wrapFallback(),
      );
    }
    
    final fixedUrl = _fixCorsUrl(trimmed);
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: ClipOval(
        child: Image.network(
          fixedUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          headers: kIsWeb ? {'Access-Control-Allow-Origin': '*'} : null,
          errorBuilder: (_, __, ___) => _wrapFallback(),
        ),
      ),
    );
  }

  Widget _wrapFallback() {
    return SizedBox.expand(
      child: Center(child: fallback),
    );
  }
}
