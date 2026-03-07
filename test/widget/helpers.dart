import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymantra/src/app/app.dart';
import 'package:mymantra/src/app/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Boots the full app with empty storage (seed data only) and returns to home.
/// Call this at the start of every widget test.
Future<void> pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(const ProviderScope(child: MyMantraApp()));
  await tester.pumpAndSettle();
  // appRouter is a module-level singleton — reset it to home between tests.
  appRouter.go('/');
  await tester.pumpAndSettle();
}

/// Pumps the app, taps the first seed mantra, and starts a session.
/// Leaves the tester on the SessionScreen.
Future<void> pumpSession(WidgetTester tester) async {
  await pumpApp(tester);
  await tester.tap(find.text('Om Mani Padme Hum'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Start Session'));
  await tester.pumpAndSettle();
}
