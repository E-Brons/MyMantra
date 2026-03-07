import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers.dart';

void main() {
  group('SessionScreen — target sheet', () {
    testWidgets('target sheet is shown before a target is selected', (tester) async {
      await pumpSessionRaw(tester);
      expect(find.text('Set your target'), findsOneWidget);
      expect(find.text('Your default'), findsOneWidget);
      expect(find.text("Mantra's target"), findsOneWidget);
      expect(find.text('Custom\u2026'), findsOneWidget);
    });

    testWidgets('selecting Your default dismisses sheet and starts session', (tester) async {
      await pumpSessionRaw(tester);
      await tester.tap(find.text('Your default'));
      await tester.pumpAndSettle();
      expect(find.text('Set your target'), findsNothing);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets("selecting Mantra's target dismisses sheet and starts session", (tester) async {
      await pumpSessionRaw(tester);
      await tester.tap(find.text("Mantra's target"));
      await tester.pumpAndSettle();
      expect(find.text('Set your target'), findsNothing);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('Cancel exits to mantra detail screen', (tester) async {
      await pumpSessionRaw(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Start Session'), findsOneWidget);
    });

    testWidgets('Custom\u2026 opens the custom target dialog', (tester) async {
      await pumpSessionRaw(tester);
      await tester.tap(find.text('Custom\u2026'));
      await tester.pumpAndSettle();
      expect(find.text('Custom target'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });
  });

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

    testWidgets('X button with count = 0 exits without showing exit sheet', (tester) async {
      await pumpSession(tester);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Exit Session?'), findsNothing);
      expect(find.text('Start Session'), findsOneWidget);
    });

    testWidgets('X button with count > 0 shows exit confirmation sheet', (tester) async {
      await pumpSession(tester);
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(find.text('Exit Session?'), findsOneWidget);
      expect(find.text('Save & Exit'), findsOneWidget);
      expect(find.text('Discard & Exit'), findsOneWidget);
    });

    testWidgets('Discard & Exit returns to MantraDetailScreen', (tester) async {
      await pumpSession(tester);
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await tester.tap(find.text('Discard & Exit'));
      await tester.pumpAndSettle();
      expect(find.text('Start Session'), findsOneWidget);
    });

    testWidgets('Continue Session hides exit sheet and keeps counter', (tester) async {
      await pumpSession(tester);
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await tester.tap(find.text('Continue Session'));
      await tester.pump();
      expect(find.text('Exit Session?'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Done button with 0 reps triggers celebration overlay', (tester) async {
      await pumpSession(tester);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Session Complete'), findsOneWidget);
    });
  });

  group('SessionScreen — tap rate limiter', () {
    testWidgets('two rapid taps only count once when limitClickRate is on', (tester) async {
      await pumpSession(tester);
      // Tap twice in immediate succession — second tap should be dropped.
      await tester.tap(find.text('0'));
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('tap after 1 s is accepted when limitClickRate is on', (tester) async {
      await pumpSession(tester);
      await tester.tap(find.text('0'));
      await tester.pump();
      // Advance real time by pumping a 1-second duration so DateTime.now() moves.
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('1'));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
    });
  });
}
