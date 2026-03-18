import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mymantra/src/app/app.dart';
import 'package:mymantra/src/app/router.dart';
import 'package:mymantra/src/core/providers/app_provider.dart';
import 'package:mymantra/src/core/services/icon_registry.dart';
import 'package:mymantra/src/core/services/theme_registry.dart';
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

  /// Boots the app, navigates to /mypractice, and seeds 'Om Mani Padme Hum'.
  /// Returns the seeded mantra's id for tests that need it.
  Future<String> launchApp(WidgetTester tester) async {
    await Future.wait([
      IconRegistry.instance.init(),
      ThemeRegistry.instance.init(),
    ]);
    await tester.pumpWidget(const ProviderScope(child: MyMantraApp()));
    await tester.pumpAndSettle();
    appRouter.go('/mypractice');
    await tester.pumpAndSettle();
    // Seed the test mantra directly via Riverpod — no UI form required.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    final mantra = container.read(appProvider.notifier).createMantra(
      title: 'Om Mani Padme Hum',
      text: 'ༀ མ་ཎི་པདྨེ་ཧཱུྃ',
      targetRepetitions: 108,
    );
    await tester.pumpAndSettle();
    return mantra.id;
  }

  // ── TC-I-1: Full session flow ──────────────────────────────────────────────

  testWidgets(
      'full flow: mypractice → session → Done → celebration → back to mypractice',
      (tester) async {
    await launchApp(tester);

    // MyPractice shows the seeded mantra.
    expect(find.text('Om Mani Padme Hum'), findsOneWidget);

    // Tap the mantra card — goes directly to SessionScreen.
    await tester.tap(find.text('Om Mani Padme Hum'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);

    // Tap Done → celebration overlay.
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Session Complete'), findsOneWidget);

    // Tap overlay to dismiss → navigates back to /mypractice.
    await tester.tap(find.text('Session Complete'));
    await tester.pumpAndSettle();
    expect(find.text('Om Mani Padme Hum'), findsOneWidget);
  });

  // ── TC-I-2: Session back arrow suspends when reps > 0 ─────────────────────

  testWidgets('session: tap once → back arrow → session is suspended',
      (tester) async {
    await launchApp(tester);

    await tester.tap(find.text('Om Mani Padme Hum'));
    await tester.pumpAndSettle();

    // Tap the rep counter once.
    await tester.tap(find.text('0'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);

    // Exit via back arrow → suspends and returns to MyPractice.
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();
    expect(find.text('Om Mani Padme Hum'), findsOneWidget);

    // Tapping the mantra again shows the "Session in progress" resume dialog.
    await tester.tap(find.text('Om Mani Padme Hum'));
    await tester.pump();
    expect(find.text('Session in progress'), findsOneWidget);
  });

  // ── TC-I-3: Session records partial reps when Done is tapped ───────────────

  testWidgets('session: tap once → Done → records a partial session',
      (tester) async {
    final mantraId = await launchApp(tester);

    await tester.tap(find.text('Om Mani Padme Hum'));
    await tester.pumpAndSettle();

    // Tap the rep counter once.
    await tester.tap(find.text('0'));
    await tester.pumpAndSettle();

    // Tap Done → celebration overlay.
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Session Complete'), findsOneWidget);

    // Dismiss celebration overlay → back to MyPractice.
    await tester.tap(find.text('Session Complete'));
    await tester.pumpAndSettle();

    // Navigate to MantraDetail to verify the partial session was recorded.
    appRouter.go('/mantras/$mantraId');
    await tester.pumpAndSettle();
    expect(find.text('1/108 reps'), findsOneWidget);
  });

  // ── TC-I-4: MantraDetail back arrow returns to previous screen ─────────────

  testWidgets(
      'MantraDetail back arrow navigates back to MyPractice (BUG-001 regression)',
      (tester) async {
    final mantraId = await launchApp(tester);

    // Push MantraDetail onto the navigation stack from MyPractice.
    appRouter.push('/mantras/$mantraId');
    await tester.pumpAndSettle();
    expect(find.text('Start Session'), findsOneWidget);

    // Tap back arrow → pops back to MyPractice.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Om Mani Padme Hum'), findsOneWidget);
    expect(find.text('Start Session'), findsNothing);
  });

  // ── TC-I-5: Icons render as Material Icon widgets ──

  testWidgets('progress screen uses Material Icon widgets', (tester) async {
    await launchApp(tester);

    // Navigate to the Progress screen via bottom nav.
    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();

    // Stat cards use Material Icon widgets resolved from icons.yml.
    expect(find.byIcon(Icons.whatshot), findsOneWidget);

    // Locked achievements use lock_outline icon.
    expect(find.byIcon(Icons.lock_outline), findsWidgets);
  });
}
