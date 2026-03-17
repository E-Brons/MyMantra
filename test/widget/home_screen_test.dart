import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymantra/src/app/router.dart';
import 'helpers.dart';

void main() {
  group('MyPracticeScreen', () {
    testWidgets('shows empty state when no mantras have been added',
        (tester) async {
      await pumpApp(tester);
      expect(find.text('No mantras to practice yet'), findsOneWidget);
    });

    testWidgets('seeded mantra appears in the practice list', (tester) async {
      await pumpApp(tester);
      seedMantra(tester, title: 'Om Mani Padme Hum', text: 'ༀ');
      await tester.pumpAndSettle();
      expect(find.text('Om Mani Padme Hum'), findsOneWidget);
    });

    testWidgets('tapping a mantra card starts a session', (tester) async {
      await pumpApp(tester);
      seedMantra(tester, title: 'Om Mani Padme Hum', text: 'ༀ');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Om Mani Padme Hum'));
      await tester.pumpAndSettle();
      // SessionScreen shows the repetition counter
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('settings icon opens SettingsScreen', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('LibraryScreen', () {
    testWidgets('+ button navigates to CreateMantraScreen', (tester) async {
      await pumpApp(tester);
      appRouter.go('/library');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('New Mantra'), findsOneWidget);
    });
  });
}
