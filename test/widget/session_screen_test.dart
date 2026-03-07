import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
