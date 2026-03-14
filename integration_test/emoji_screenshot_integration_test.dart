import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mymantra/src/app/app.dart';
import 'package:mymantra/src/app/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  Future<void> launchApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyMantraApp()));
    await tester.pumpAndSettle();
    appRouter.go('/');
    await tester.pumpAndSettle();
  }

  testWidgets('captures screenshots for host-side emoji validation',
      (tester) async {
    await launchApp(tester);

    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Mantra Library'), findsOneWidget);
    await binding.takeScreenshot('mantra_library');

    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets);
    await binding.takeScreenshot('progress');

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
    await binding.takeScreenshot('session_complete');
  });
}
