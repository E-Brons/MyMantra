import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymantra/src/app/router.dart';
import 'package:mymantra/src/core/providers/app_provider.dart';
import 'helpers.dart';

// ──────────────────────────────────────────────────────────────────────────────
// BUG-001 regression: MantraDetail back arrow was a no-op on macOS when
// context.pop() had no history (fixed: canPop() guard + context.go('/library')
// fallback).
//
// BUG-002 regression: Android hardware back in SessionScreen bypassed the
// session suspend logic (fixed: PopScope wraps SessionScreen).
//
// NOTE: Android *hardware* back is platform-specific and can only be regression-
// tested on a real Android device or emulator. The tests below cover the same
// code paths through the Flutter test framework's handlePopRoute() call, which
// exercises PopScope.onPopInvokedWithResult identically on all platforms.
// ──────────────────────────────────────────────────────────────────────────────

void main() {
  group('Back navigation regressions', () {
    // BUG-001 ─────────────────────────────────────────────────────────────────

    testWidgets('MantraDetail back arrow navigates back (BUG-001)',
        (tester) async {
      await pumpApp(tester);
      final id = seedMantra(tester);
      // Push so that canPop() == true and context.pop() is used.
      appRouter.push('/mantras/$id');
      await tester.pumpAndSettle();
      expect(find.text('Start Session'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // MantraDetail is gone
      expect(find.text('Start Session'), findsNothing);
    });

    // BUG-002 ─────────────────────────────────────────────────────────────────

    testWidgets(
        'session back button with count > 0 suspends session (BUG-002 UI path)',
        (tester) async {
      final id = await pumpSession(tester);
      await tester.tap(find.text('0')); // count → 1
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // Suspended session exists — not a bare pop
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      final hasSuspended = container
          .read(appProvider)
          .sessions
          .any((s) => s.mantraId == id && !s.completed);
      expect(hasSuspended, isTrue);
    });

    testWidgets(
        'platform back event with count > 0 suspends via PopScope (BUG-002 PopScope path)',
        (tester) async {
      final id = await pumpSession(tester);
      await tester.tap(find.text('0')); // count → 1
      await tester.pumpAndSettle();

      // handlePopRoute() is the same event Android hardware back fires.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      final hasSuspended = container
          .read(appProvider)
          .sessions
          .any((s) => s.mantraId == id && !s.completed);
      expect(hasSuspended, isTrue);
    });

    testWidgets(
        'platform back event with count = 0 exits without suspending',
        (tester) async {
      final id = await pumpSession(tester);
      // count is still 0 — back should exit immediately without a session record
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      final hasSuspended = container
          .read(appProvider)
          .sessions
          .any((s) => s.mantraId == id && !s.completed);
      expect(hasSuspended, isFalse);
    });
  });
}
