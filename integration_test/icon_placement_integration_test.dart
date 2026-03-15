import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mymantra/src/app/app.dart';
import 'package:mymantra/src/app/router.dart';
import 'package:mymantra/src/core/services/icon_registry.dart';
import 'package:mymantra/src/core/services/theme_registry.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Takes a screenshot when running via [flutter drive]; silently skips when
  /// running via [flutter test] where the screenshot channel is unavailable.
  Future<void> tryTakeScreenshot(String name) async {
    try {
      await binding.takeScreenshot(name);
    } on MissingPluginException {
      // No-op: screenshot capture requires flutter drive (a host-side driver).
      // The icon-placement assertions above still run and are validated.
    }
  }

  setUp(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  Future<void> launchApp(WidgetTester tester) async {
    // Integration tests pump the app directly, so initialize registries that
    // are normally loaded in main().
    await Future.wait([
      IconRegistry.instance.init(),
      ThemeRegistry.instance.init(),
    ]);
    await tester.pumpWidget(const ProviderScope(child: MyMantraApp()));
    await tester.pumpAndSettle();
    appRouter.go('/');
    await tester.pumpAndSettle();
  }

  testWidgets('captures screenshots for host-side icon placement validation',
      (tester) async {
    await launchApp(tester);

    // Verify all bottom-nav icons are rendered on launch.
    // The Home tab is active, so it shows Icons.home (activeIcon); the rest
    // show their outlined (inactive) variants.
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }

    // — Library screen ————————————————————————————————————————————————————
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Mantra Library'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome), findsWidgets); // 'All' category chip
    await tryTakeScreenshot('mantra_library');

    // — Progress screen ———————————————————————————————————————————————————
    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();
    // 'Progress' appears in both the nav-bar label and the screen heading.
    expect(find.text('Progress'), findsWidgets);
    expect(find.byIcon(Icons.whatshot), findsWidgets);
    expect(find.byIcon(Icons.trending_up), findsWidgets);
    expect(find.byIcon(Icons.self_improvement), findsWidgets);
    expect(find.byIcon(Icons.all_inclusive), findsWidgets);
    expect(find.byIcon(Icons.event), findsWidgets);
    await tryTakeScreenshot('progress');

    // — Session complete ——————————————————————————————————————————————————
    // Home tab is inactive here, so its inactive icon (Icons.home_outlined)
    // is the one visible in the nav bar.
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Om Mani Padme Hum'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Session'));
    await tester.pumpAndSettle();

    if (find.text('Set your target').evaluate().isNotEmpty) {
      await tester.tap(find.text('Your default'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Session Complete'), findsOneWidget);
    expect(find.byIcon(Icons.thumb_up), findsWidgets);
    await tryTakeScreenshot('session_complete');
  });
}
