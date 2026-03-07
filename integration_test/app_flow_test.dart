import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mymantra/src/app/app.dart';
import 'package:mymantra/src/app/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ──────────────────────────────────────────────────────────────────────────────
// End-to-end app flows — runs on Linux desktop in CI (ubuntu-latest + xvfb).
// Each test starts with a clean SharedPreferences state and navigates the real
// compiled app using the same interactions a user would perform.
// ──────────────────────────────────────────────────────────────────────────────

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

  // ── TC-I-1: Full session flow ──────────────────────────────────────────────

  testWidgets(
      'full flow: home → detail → start session → Done → celebration → back to detail',
      (tester) async {
    await launchApp(tester);

    // Home shows seed mantras
    expect(find.text('Om Mani Padme Hum'), findsOneWidget);

    // Navigate to MantraDetail
    await tester.tap(find.text('Om Mani Padme Hum'));
    await tester.pumpAndSettle();
    expect(find.text('Start Session'), findsOneWidget);

    // Start session
    await tester.tap(find.text('Start Session'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);

    // Tap Done immediately (0 reps, partial)
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Session Complete'), findsOneWidget);

    // Continue back to MantraDetail
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Start Session'), findsOneWidget);
  });

  // ── TC-I-2: Session with tap → Discard ────────────────────────────────────

  testWidgets(
      'session: tap once → X → Discard exits cleanly to MantraDetail',
      (tester) async {
    await launchApp(tester);

    await tester.tap(find.text('Om Mani Padme Hum'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Session'));
    await tester.pumpAndSettle();

    // Tap once
    await tester.tap(find.text('0'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);

    // Exit via X button
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(find.text('Exit Session?'), findsOneWidget);

    // Discard
    await tester.tap(find.text('Discard & Exit'));
    await tester.pumpAndSettle();
    expect(find.text('Start Session'), findsOneWidget);
  });

  // ── TC-I-3: Session with tap → Save as partial ────────────────────────────

  testWidgets(
      'session: tap once → X → Save records a partial session',
      (tester) async {
    await launchApp(tester);

    await tester.tap(find.text('Om Mani Padme Hum'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Session'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('0'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    // Save & Exit → celebration overlay (partial session still triggers it)
    await tester.tap(find.text('Save & Exit'));
    await tester.pumpAndSettle();
    expect(find.text('Session Complete'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Recent sessions section on MantraDetail now shows the partial entry
    expect(find.text('1/108 reps'), findsOneWidget);
  });

  // ── TC-I-4: MantraDetail back arrow returns to home ────────────────────────

  testWidgets(
      'MantraDetail back arrow navigates back to HomeScreen (BUG-001 regression)',
      (tester) async {
    await launchApp(tester);

    await tester.tap(find.text('Om Mani Padme Hum'));
    await tester.pumpAndSettle();
    expect(find.text('Start Session'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('MyMantra'), findsOneWidget);
    expect(find.text('Start Session'), findsNothing);
  });
}
