import 'package:flutter_test/flutter_test.dart';
import 'package:mymantra/src/core/models/mantra.dart';
import 'package:mymantra/src/features/library/data/library_mantra.dart';

LibraryMantra _base({int? recommendedRepetitions, RepetitionCycle? recommendedCycle}) =>
    LibraryMantra(
      id: 'lib-001',
      name: 'Om Mani Padme Hum',
      english: 'Praise to the Jewel in the Lotus',
      original: 'ॐ मणिपद्मे हूँ',
      transliteration: 'oṃ maṇipadme hūṃ',
      background: 'A Tibetan Buddhist mantra.',
      benefits: 'Promotes compassion and inner peace.',
      tags: const ['buddhist', 'tibetan'],
      tradition: 'Tibetan Buddhism',
      category: 'mantra',
      difficulty: 'beginner',
      recommendedRepetitions: recommendedRepetitions,
      recommendedCycle: recommendedCycle,
      translations: const {'en': 'Praise to the Jewel in the Lotus'},
    );

void main() {
  group('LibraryMantra — recommendedRepetitions', () {
    test('null when not provided', () {
      expect(_base().recommendedRepetitions, isNull);
    });

    test('value survives round-trip', () {
      final m = LibraryMantra.fromJson(_base(recommendedRepetitions: 108).toJson());
      expect(m.recommendedRepetitions, 108);
    });

    test('null survives round-trip', () {
      final m = LibraryMantra.fromJson(_base().toJson());
      expect(m.recommendedRepetitions, isNull);
    });
  });

  group('LibraryMantra — recommendedCycle', () {
    test('null when not provided', () {
      expect(_base().recommendedCycle, isNull);
    });

    test('session cycle survives round-trip', () {
      final m = LibraryMantra.fromJson(
          _base(recommendedCycle: RepetitionCycle.session).toJson());
      expect(m.recommendedCycle, RepetitionCycle.session);
    });

    test('daily cycle survives round-trip', () {
      final m = LibraryMantra.fromJson(
          _base(recommendedCycle: RepetitionCycle.daily).toJson());
      expect(m.recommendedCycle, RepetitionCycle.daily);
    });

    test('weekly cycle survives round-trip', () {
      final m = LibraryMantra.fromJson(
          _base(recommendedCycle: RepetitionCycle.weekly).toJson());
      expect(m.recommendedCycle, RepetitionCycle.weekly);
    });

    test('null survives round-trip', () {
      final m = LibraryMantra.fromJson(_base().toJson());
      expect(m.recommendedCycle, isNull);
    });

    test('missing recommendedCycle key in JSON yields null', () {
      final json = _base(recommendedCycle: RepetitionCycle.daily).toJson()
        ..remove('recommendedCycle');
      expect(LibraryMantra.fromJson(json).recommendedCycle, isNull);
    });
  });

  group('LibraryMantra — full round-trip', () {
    test('all fields including recs survive toJson / fromJson', () {
      final original = _base(recommendedRepetitions: 108, recommendedCycle: RepetitionCycle.daily);
      final rt = LibraryMantra.fromJson(original.toJson());
      expect(rt.id, original.id);
      expect(rt.name, original.name);
      expect(rt.recommendedRepetitions, 108);
      expect(rt.recommendedCycle, RepetitionCycle.daily);
    });
  });
}
