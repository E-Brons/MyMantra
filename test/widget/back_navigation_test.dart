import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers.dart';

// ──────────────────────────────────────────────────────────────────────────────
// BUG-001 regression: MantraDetail back arrow was a no-op on macOS when
// context.pop() had no history (fixed: canPop() guard + context.go('/') fallback).
//
// BUG-002 regression: Android hardware back in SessionScreen bypassed the
// "Exit session?" dialog (fixed: PopScope wraps SessionScreen).
//
// NOTE: Android *hardware* back is platform-specific and can only be regression-
// tested on a real Android device or emulator.  The tests below cover the same
// code paths through the Flutter test framework's handlePopRoute() call, which
// exercises PopScope.onPopInvokedWithResult identically on all platforms.
// ──────────────────────────────────────────────────────────────────────────────

void main() {
  group('Back navigation regressions', () {
    // BUG-001 ─────────────────────────────────────────────────────────────────

    testWidgets(
        'MantraDetail back arrow navigates home (BUG-001)',
        (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Om Mani Padme Hum'));
      await tester.pumpAndSettle();
      expect(find.text('Start Session'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('MyMantra'), findsOneWidget);
      expect(find.text('Start Session'), findsNothing);
    });

    // BUG-002 ─────────────────────────────────────────────────────────────────

    testWidgets(
        'session X button with count > 0 shows exit sheet, not bare pop (BUG-002 UI path)',
        (tester) async {
      await pumpSession(tester);
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(find.text('Exit Session?'), findsOneWidget);
      expect(find.text('Start Session'), findsNothing); // not popped
    });

    testWidgets(
        'platform back event with count > 0 shows exit sheet via PopScope (BUG-002 PopScope path)',
        (tester) async {
      await pumpSession(tester);
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();

      // handlePopRoute() is the same event that Android hardware back fires.
      // PopScope(canPop: false) intercepts it and calls _handleExit().
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Exit Session?'), findsOneWidget);
    });

    testWidgets(
        'platform back event with count = 0 pops session without exit sheet',
        (tester) async {
      await pumpSession(tester);
      // count is still 0 — back should exit immediately
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Exit Session?'), findsNothing);
      expect(find.text('Start Session'), findsOneWidget);
    });
  });
}
