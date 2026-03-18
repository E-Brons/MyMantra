import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymantra/src/core/models/mantra.dart';
import 'package:mymantra/src/core/providers/app_provider.dart';
import 'helpers.dart';

void main() {
  group('SettingsScreen — Practice section', () {
    testWidgets('Default cycle dropdown is visible', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Default cycle'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Default cycle'), findsOneWidget);
      // Default value is Session
      expect(find.text('Session'), findsWidgets);
    });

    testWidgets('Limit tap rate toggle is visible and on by default',
        (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Limit tap rate'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Limit tap rate'), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      expect(container.read(appProvider).settings.limitClickRate, isTrue);
    });

    testWidgets('toggling Limit tap rate updates the setting', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );

      await tester.scrollUntilVisible(
        find.text('Limit tap rate'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Limit tap rate'));
      await tester.pumpAndSettle();

      // Find the Switch that is a sibling in the same Row as 'Limit tap rate'.
      final limitTapRateSwitch = find.descendant(
        of: find.ancestor(
          of: find.text('Limit tap rate'),
          matching: find.byType(Row),
        ).first,
        matching: find.byType(Switch),
      );
      await tester.tap(limitTapRateSwitch);
      await tester.pumpAndSettle();

      expect(container.read(appProvider).settings.limitClickRate, isFalse);
    });

    testWidgets('Default cycle persists when changed to Daily', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );

      // Scroll until the Default cycle label is visible, then pick Daily chip.
      await tester.scrollUntilVisible(
        find.text('Daily'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Daily'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();

      expect(
        container.read(appProvider).settings.defaultRepetitionCycle,
        RepetitionCycle.daily,
      );
    });
  });
}
