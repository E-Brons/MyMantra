import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymantra/src/app/app.dart';
import 'package:mymantra/src/app/router.dart';
import 'package:mymantra/src/core/services/icon_registry.dart';
import 'package:mymantra/src/core/services/theme_registry.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Boots the full app with empty storage (seed data only) and returns to home.
/// Call this at the start of every widget test.
Future<void> pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await Future.wait([
    IconRegistry.instance.init(),
    ThemeRegistry.instance.init(),
  ]);
  await tester.pumpWidget(const ProviderScope(child: MyMantraApp()));
  await tester.pumpAndSettle();
  // appRouter is a module-level singleton — reset it to home between tests.
  appRouter.go('/');
  await tester.pumpAndSettle();
}

/// Pumps the app, taps the first seed mantra, starts a session, and
/// stops at the target sheet (no target selected yet).
/// Use this for tests that exercise the target sheet itself.
Future<void> pumpSessionRaw(WidgetTester tester) async {
  await pumpApp(tester);
  await tester.tap(find.text('Om Mani Padme Hum'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Start Session'));
  await tester.pumpAndSettle();
}

/// Pumps the app, taps the first seed mantra, starts a session, and
/// selects "Mantra's target" on the target sheet.
/// Leaves the tester on the SessionScreen with a target already selected.
Future<void> pumpSession(WidgetTester tester) async {
  await pumpSessionRaw(tester);
  await tester.tap(find.text("Mantra's target"));
  await tester.pumpAndSettle();
}
