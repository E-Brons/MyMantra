import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymantra/src/app/app.dart';
import 'package:mymantra/src/app/router.dart';
import 'package:mymantra/src/core/providers/app_provider.dart';
import 'package:mymantra/src/core/services/icon_registry.dart';
import 'package:mymantra/src/core/services/theme_registry.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Boots the full app with empty storage and navigates to /mypractice,
/// bypassing the welcome screen. Call this at the start of every widget test.
Future<void> pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await Future.wait([
    IconRegistry.instance.init(),
    ThemeRegistry.instance.init(),
  ]);
  await tester.pumpWidget(const ProviderScope(child: MyMantraApp()));
  await tester.pumpAndSettle();
  // Bypass welcome screen — navigate directly to the main shell.
  appRouter.go('/mypractice');
  await tester.pumpAndSettle();
}

/// Injects a test mantra into the provider and returns its id.
String seedMantra(
  WidgetTester tester, {
  String title = 'Om Mani Padme Hum',
  String text = 'ༀ མ་ཎི་པདྨེ་ཧཱུྃ',
  int targetRepetitions = 108,
}) {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  );
  final mantra = container.read(appProvider.notifier).createMantra(
        title: title,
        text: text,
        targetRepetitions: targetRepetitions,
      );
  return mantra.id;
}

/// Pumps the app, seeds a test mantra, and navigates to its SessionScreen.
/// Returns the mantra id so tests can query the provider directly.
Future<String> pumpSession(WidgetTester tester) async {
  await pumpApp(tester);
  final id = seedMantra(tester);
  appRouter.go('/mantras/$id/session');
  await tester.pumpAndSettle();
  return id;
}
