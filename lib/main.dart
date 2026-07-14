import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/premium_theme.dart';
import 'features/home/scrollbehavior.dart';
import 'core/providers/api_provider.dart';

void main() {
  // Using default hash-based URL strategy for better compatibility with shared links
  // This allows URLs like https://getondial.com/#/store?id=347
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(appInitProvider, (_, __) {});

    return MaterialApp.router(
      title: 'GET ON DIAL - Multi-Service Platform',
      debugShowCheckedModeBanner: false,
      theme: PremiumTheme.theme,
      scrollBehavior: WebScrollBehavior(),
      routerConfig: appRouter,
    );
  }
}
