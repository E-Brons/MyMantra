import 'package:flutter_test/flutter_test.dart';
import 'package:mymantra/src/core/models/mantra.dart';
import 'package:mymantra/src/core/models/settings.dart';

void main() {
  // ── Defaults ──────────────────────────────────────────────────────────────

  group('Settings — defaults', () {
    final d = Settings.defaults();

    test('theme is dark', () => expect(d.theme, AppThemeMode.dark));
    test('notificationsEnabled is true', () => expect(d.notificationsEnabled, isTrue));
    test('vibrationEnabled is true', () => expect(d.vibrationEnabled, isTrue));
    test('defaultRepetitions is 108', () => expect(d.defaultRepetitions, 108));
    test('defaultRepetitionCycle is session', () =>
        expect(d.defaultRepetitionCycle, RepetitionCycle.session));
    test('limitClickRate is true', () => expect(d.limitClickRate, isTrue));
    test('fontSize is medium', () => expect(d.fontSize, 'medium'));
  });

  // ── Round-trip ────────────────────────────────────────────────────────────

  group('Settings — toJson / fromJson round-trip', () {
    test('defaults survive round-trip', () {
      final s = Settings.fromJson(Settings.defaults().toJson());
      expect(s.theme, AppThemeMode.dark);
      expect(s.defaultRepetitions, 108);
      expect(s.defaultRepetitionCycle, RepetitionCycle.session);
      expect(s.limitClickRate, isTrue);
      expect(s.fontSize, 'medium');
    });

    test('limitClickRate=false survives round-trip', () {
      final s = Settings.defaults().copyWith(limitClickRate: false);
      expect(Settings.fromJson(s.toJson()).limitClickRate, isFalse);
    });

    test('daily cycle survives round-trip', () {
      final s = Settings.defaults().copyWith(defaultRepetitionCycle: RepetitionCycle.daily);
      expect(Settings.fromJson(s.toJson()).defaultRepetitionCycle, RepetitionCycle.daily);
    });

    test('weekly cycle survives round-trip', () {
      final s = Settings.defaults().copyWith(defaultRepetitionCycle: RepetitionCycle.weekly);
      expect(Settings.fromJson(s.toJson()).defaultRepetitionCycle, RepetitionCycle.weekly);
    });
  });

  // ── Backward compatibility ────────────────────────────────────────────────

  group('Settings — old JSON without new fields falls back to defaults', () {
    test('missing limitClickRate defaults to true', () {
      final json = Settings.defaults().toJson()..remove('limitClickRate');
      expect(Settings.fromJson(json).limitClickRate, isTrue);
    });

    test('missing defaultRepetitionCycle defaults to session', () {
      final json = Settings.defaults().toJson()..remove('defaultRepetitionCycle');
      expect(Settings.fromJson(json).defaultRepetitionCycle, RepetitionCycle.session);
    });
  });

  // ── copyWith ──────────────────────────────────────────────────────────────

  group('Settings — copyWith', () {
    test('only changed field differs', () {
      final updated = Settings.defaults().copyWith(limitClickRate: false);
      expect(updated.limitClickRate, isFalse);
      expect(updated.defaultRepetitions, 108); // unchanged
    });

    test('changing defaultRepetitionCycle leaves limitClickRate unchanged', () {
      final updated = Settings.defaults().copyWith(defaultRepetitionCycle: RepetitionCycle.weekly);
      expect(updated.defaultRepetitionCycle, RepetitionCycle.weekly);
      expect(updated.limitClickRate, isTrue); // unchanged
    });
  });
}
