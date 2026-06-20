import 'package:demo4/core/routing/app_router.dart';
import 'package:demo4/core/theme/app_theme.dart';
import 'package:demo4/features/settings/presentation/providers/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CraftEdgeApp extends ConsumerWidget {
  const CraftEdgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'CraftEdge HRMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      routerConfig: ref.watch(appRouterProvider),
      supportedLocales: const [Locale('en'), Locale('hi')],
    );
  }
}
