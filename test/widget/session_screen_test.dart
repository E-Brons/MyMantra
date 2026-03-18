import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymantra/src/core/providers/app_provider.dart';
import 'helpers.dart';

void main() {
  group('SessionScreen', () {
    testWidgets('shows mantra title and counter starting at 0', (tester) async {
      await pumpSession(tester);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Om Mani Padme Hum'), findsOneWidget);
    });

    testWidgets('tapping the screen increments the counter', (tester) async {
      await pumpSession(tester);
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('back button with count = 0 exits without suspending',
        (tester) async {
      final id = await pumpSession(tester);
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // Navigated away from session screen
      expect(find.text('0'), findsNothing);

      // No suspended session created
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      final hasSuspended = container
          .read(appProvider)
          .sessions
          .any((s) => s.mantraId == id && !s.completed);
      expect(hasSuspended, isFalse);
    });

    testWidgets('back button with count > 0 suspends the session',
        (tester) async {
      final id = await pumpSession(tester);
      await tester.tap(find.text('0')); // count → 1
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // A suspended (incomplete) session now exists in the provider
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      final hasSuspended = container
          .read(appProvider)
          .sessions
          .any((s) => s.mantraId == id && !s.completed);
      expect(hasSuspended, isTrue);
    });

    testWidgets('Done button triggers celebration overlay', (tester) async {
      await pumpSession(tester);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Session Complete'), findsOneWidget);
    });
  });

  group('SessionScreen — tap rate limiter', () {
    testWidgets('two rapid taps only count once when limitClickRate is on',
        (tester) async {
      await pumpSession(tester);
      // Second tap within 1 s should be dropped.
      await tester.tap(find.text('0'));
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('tap after 1 s is accepted when limitClickRate is on',
        (tester) async {
      await pumpSession(tester);
      await tester.tap(find.text('0'));
      await tester.pump();
      // runAsync lets real time pass so the 1 s guard expires.
      await tester
          .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 1100)));
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
    });
  });
}
