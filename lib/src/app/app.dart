import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_provider.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class MyMantraApp extends ConsumerWidget {
  const MyMantraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appProvider);
    final isDark = appState.settings.effectiveTheme == AppThemeMode.dark ||
        (appState.settings.effectiveTheme == AppThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);

    return MaterialApp.router(
      title: 'MyMantra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
