import 'package:flutter_test/flutter_test.dart';
import 'package:mymantra/src/core/models/achievement.dart';
import 'package:mymantra/src/core/services/icon_registry.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await IconRegistry.instance.init();
  });

  group('visibleAchievements', () {
    test('shows chain heads plus always-visible achievements for a new user', () {
      final visible = visibleAchievements({});

      expect(
        visible.map((a) => a.id),
        orderedEquals([
          'ACH-STR-001',
          'ACH-REP-1K',
          'ACH-SES-100',
          'ACH-SPL-CREATE',
        ]),
      );
    });

    test('reveals the next streak achievement after the predecessor is unlocked', () {
      final visible = visibleAchievements({'ACH-STR-001'});

      expect(visible.any((a) => a.id == 'ACH-STR-001'), isTrue);
      expect(visible.any((a) => a.id == 'ACH-STR-003'), isTrue);
      expect(visible.any((a) => a.id == 'ACH-STR-007'), isFalse);
    });

    test('reveals only one teaser ahead in progressive chains', () {
      final visible = visibleAchievements({
        'ACH-STR-001',
        'ACH-STR-003',
        'ACH-REP-1K',
      });

      expect(visible.any((a) => a.id == 'ACH-STR-007'), isTrue);
      expect(visible.any((a) => a.id == 'ACH-STR-014'), isFalse);
      expect(visible.any((a) => a.id == 'ACH-REP-5K'), isTrue);
      expect(visible.any((a) => a.id == 'ACH-REP-10K'), isFalse);
    });

    test('shows all items in a progressive group once the chain is complete', () {
      final unlocked = kAchievements
          .where((a) => a.id.startsWith('ACH-SES-'))
          .map((a) => a.id)
          .toSet();

      final visible = visibleAchievements(unlocked);
      final sessionIds = visible
          .where((a) => a.id.startsWith('ACH-SES-'))
          .map((a) => a.id)
          .toList();

      expect(sessionIds.length, 8);
      expect(sessionIds.last, 'ACH-SES-100K');
    });

    test('never-visible groups stay hidden until earned', () {
      final visible = visibleAchievements({});

      expect(visible.any((a) => a.id == 'ACH-TIME-EARLY'), isFalse);
      expect(visible.any((a) => a.id == 'ACH-PLT-ANDROID'), isFalse);
    });

    test('never-visible achievements appear once earned', () {
      final visible = visibleAchievements({
        'ACH-TIME-EARLY',
        'ACH-PLT-ANDROID',
      });

      expect(visible.any((a) => a.id == 'ACH-TIME-EARLY'), isTrue);
      expect(visible.any((a) => a.id == 'ACH-PLT-ANDROID'), isTrue);
      expect(visible.any((a) => a.id == 'ACH-TIME-NIGHT'), isFalse);
      expect(visible.any((a) => a.id == 'ACH-PLT-IOS'), isFalse);
    });

    test('always-visible achievements are shown even when locked', () {
      final visible = visibleAchievements({});

      expect(visible.any((a) => a.id == 'ACH-SPL-CREATE'), isTrue);
    });
  });
}