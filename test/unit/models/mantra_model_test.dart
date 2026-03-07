import 'package:flutter_test/flutter_test.dart';
import 'package:mymantra/src/core/models/mantra.dart';

void main() {
  // ── Reminder ──────────────────────────────────────────────────────────────

  group('Reminder', () {
    test('toJson / fromJson round-trip preserves all fields', () {
      const r = Reminder(id: 'r-001', time: '07:30', days: [1, 3, 5], enabled: true);
      final rt = Reminder.fromJson(r.toJson());
      expect(rt.id, r.id);
      expect(rt.time, r.time);
      expect(rt.days, r.days);
      expect(rt.enabled, r.enabled);
    });

    test('disabled reminder serialises enabled=false correctly', () {
      const r = Reminder(id: 'r-002', time: '22:00', days: [0, 6], enabled: false);
      expect(Reminder.fromJson(r.toJson()).enabled, isFalse);
    });

    test('all seven days survive round-trip', () {
      const r = Reminder(id: 'r-003', time: '12:00', days: [0, 1, 2, 3, 4, 5, 6], enabled: true);
      expect(Reminder.fromJson(r.toJson()).days, [0, 1, 2, 3, 4, 5, 6]);
    });

    test('copyWith only changes specified fields', () {
      const r = Reminder(id: 'r-004', time: '08:00', days: [1], enabled: true);
      final updated = r.copyWith(enabled: false);
      expect(updated.enabled, isFalse);
      expect(updated.time, '08:00'); // unchanged
      expect(updated.id, 'r-004');   // unchanged
    });
  });

  // ── Mantra ────────────────────────────────────────────────────────────────

  group('Mantra — serialisation', () {
    final base = Mantra(
      id: 'test-1',
      title: 'Om Mani Padme Hum',
      text: 'ॐ मणिपद्मे हूँ',
      transliteration: 'oṃ maṇipadme hūṃ',
      translation: 'Praise to the Jewel in the Lotus',
      targetRepetitions: 108,
      isCustom: false,
      tradition: 'Tibetan Buddhism',
      reminders: const [],
      createdAt: DateTime(2026, 1, 15, 8, 0),
      updatedAt: DateTime(2026, 1, 15, 9, 0),
    );

    test('all fields survive toJson / fromJson round-trip', () {
      final m = Mantra.fromJson(base.toJson());
      expect(m.id, base.id);
      expect(m.title, base.title);
      expect(m.text, base.text);
      expect(m.transliteration, base.transliteration);
      expect(m.translation, base.translation);
      expect(m.targetRepetitions, base.targetRepetitions);
      expect(m.isCustom, base.isCustom);
      expect(m.tradition, base.tradition);
      expect(m.createdAt, base.createdAt);
      expect(m.updatedAt, base.updatedAt);
    });

    test('Devanagari (Sanskrit) text survives round-trip', () {
      expect(Mantra.fromJson(base.toJson()).text, 'ॐ मणिपद्मे हूँ');
    });

    test('Hebrew text survives round-trip', () {
      final m = Mantra(
        id: 'heb-1', title: 'Shema', text: 'שְׁמַע יִשְׂרָאֵל',
        targetRepetitions: 108, isCustom: true,
        reminders: const [],
        createdAt: DateTime(2026, 1, 1), updatedAt: DateTime(2026, 1, 1),
      );
      expect(Mantra.fromJson(m.toJson()).text, 'שְׁמַע יִשְׂרָאֵל');
    });

    test('Arabic text survives round-trip', () {
      final m = Mantra(
        id: 'ara-1', title: 'Bismillah', text: 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
        targetRepetitions: 108, isCustom: true,
        reminders: const [],
        createdAt: DateTime(2026, 1, 1), updatedAt: DateTime(2026, 1, 1),
      );
      expect(Mantra.fromJson(m.toJson()).text, 'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ');
    });

    test('Tibetan script survives round-trip', () {
      final m = Mantra(
        id: 'tib-1', title: 'Om Mani', text: 'ཨོཾ་མ་ཎི་པ་དྨེ་ཧཱུྃ',
        targetRepetitions: 108, isCustom: false,
        reminders: const [],
        createdAt: DateTime(2026, 1, 1), updatedAt: DateTime(2026, 1, 1),
      );
      expect(Mantra.fromJson(m.toJson()).text, 'ཨོཾ་མ་ཎི་པ་དྨེ་ཧཱུྃ');
    });

    test('all optional fields can be null', () {
      final m = Mantra(
        id: 'null-1', title: 'Simple', text: 'Om',
        targetRepetitions: 1, isCustom: true,
        reminders: const [],
        createdAt: DateTime(2026, 1, 1), updatedAt: DateTime(2026, 1, 1),
      );
      final rt = Mantra.fromJson(m.toJson());
      expect(rt.transliteration, isNull);
      expect(rt.translation, isNull);
      expect(rt.tradition, isNull);
    });

    test('two reminders survive round-trip intact', () {
      final m = base.copyWith(reminders: [
        const Reminder(id: 'r-1', time: '06:00', days: [1, 2, 3, 4, 5], enabled: true),
        const Reminder(id: 'r-2', time: '20:00', days: [0, 6], enabled: false),
      ]);
      final rt = Mantra.fromJson(m.toJson());
      expect(rt.reminders.length, 2);
      expect(rt.reminders.first.time, '06:00');
      expect(rt.reminders.last.enabled, isFalse);
    });
  });

  group('Mantra — copyWith', () {
    final base = Mantra(
      id: 'cw-1', title: 'Original', text: 'Om',
      targetRepetitions: 108, isCustom: true,
      reminders: const [],
      createdAt: DateTime(2026, 1, 1), updatedAt: DateTime(2026, 1, 1),
    );

    test('only the specified field changes', () {
      final updated = base.copyWith(title: 'New Title');
      expect(updated.title, 'New Title');
      expect(updated.text, base.text);
      expect(updated.id, base.id);
    });

    test('updating targetRepetitions does not touch title', () {
      final updated = base.copyWith(targetRepetitions: 27);
      expect(updated.targetRepetitions, 27);
      expect(updated.title, 'Original');
    });
  });
}
