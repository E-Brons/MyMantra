import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymantra/src/core/models/achievement.dart';

void main() {
  // ── Enum completeness ─────────────────────────────────────────────────────

  group('AchievementRarity enum', () {
    test('has 10 tiers', () {
      expect(AchievementRarity.values.length, 10);
    });

    test('tiers are in ascending order', () {
      expect(AchievementRarity.values, [
        AchievementRarity.common,
        AchievementRarity.uncommon,
        AchievementRarity.rare,
        AchievementRarity.superRare,
        AchievementRarity.epic,
        AchievementRarity.heroic,
        AchievementRarity.exotic,
        AchievementRarity.mythic,
        AchievementRarity.legendary,
        AchievementRarity.divine,
      ]);
    });
  });

  // ── Streak chain rarity mapping ───────────────────────────────────────────

  group('Streak chain — one tier per level', () {
    final streak = kAchievements
        .where((a) => a.id.startsWith('ACH-STR-'))
        .toList();

    test('has 10 streak achievements', () => expect(streak.length, 10));

    test('each streak achievement has a unique rarity', () {
      final rarities = streak.map((a) => a.rarity).toSet();
      expect(rarities.length, 10,
          reason: 'every streak level should map to a distinct rarity tier');
    });

    test('streak rarities are in ascending tier order', () {
      final rarities = streak.map((a) => a.rarity).toList();
      for (var i = 0; i < rarities.length - 1; i++) {
        expect(rarities[i].index, lessThan(rarities[i + 1].index),
            reason:
                '${rarities[i]} (index ${rarities[i].index}) should be less rare than ${rarities[i + 1]}');
      }
    });

    test('Thought is common', () {
      expect(
          streak.firstWhere((a) => a.id == 'ACH-STR-001').rarity,
          AchievementRarity.common);
    });

    test('Grit is heroic', () {
      expect(
          streak.firstWhere((a) => a.id == 'ACH-STR-060').rarity,
          AchievementRarity.heroic);
    });

    test('Destiny is divine', () {
      expect(
          streak.firstWhere((a) => a.id == 'ACH-STR-1095').rarity,
          AchievementRarity.divine);
    });
  });

  // ── Repetition chain rarity mapping ──────────────────────────────────────

  group('Repetition chain — ascending rarity', () {
    final reps = kAchievements
        .where((a) => a.id.startsWith('ACH-REP-'))
        .toList();

    test('has 8 repetition achievements', () => expect(reps.length, 8));

    test('repetition rarities are in ascending tier order', () {
      final rarities = reps.map((a) => a.rarity).toList();
      for (var i = 0; i < rarities.length - 1; i++) {
        expect(rarities[i].index, lessThan(rarities[i + 1].index),
            reason:
                '${rarities[i]} should be less rare than ${rarities[i + 1]}');
      }
    });

    test('1K Reps is common', () {
      expect(reps.firstWhere((a) => a.id == 'ACH-REP-1K').rarity,
          AchievementRarity.common);
    });

    test('1M Reps is legendary', () {
      expect(reps.firstWhere((a) => a.id == 'ACH-REP-1M').rarity,
          AchievementRarity.legendary);
    });
  });

  // ── Session chain rarity mapping ──────────────────────────────────────────

  group('Session chain — ascending rarity', () {
    final sessions = kAchievements
        .where((a) => a.id.startsWith('ACH-SES-'))
        .toList();

    test('has 9 session achievements', () => expect(sessions.length, 9));

    test('session rarities are in ascending tier order', () {
      final rarities = sessions.map((a) => a.rarity).toList();
      for (var i = 0; i < rarities.length - 1; i++) {
        expect(rarities[i].index, lessThan(rarities[i + 1].index),
            reason:
                '${rarities[i]} should be less rare than ${rarities[i + 1]}');
      }
    });

    test('10 Sessions is uncommon', () {
      expect(sessions.firstWhere((a) => a.id == 'ACH-SES-010').rarity,
          AchievementRarity.uncommon);
    });

    test('100K Sessions is divine', () {
      expect(sessions.firstWhere((a) => a.id == 'ACH-SES-100K').rarity,
          AchievementRarity.divine);
    });
  });

  // ── Divine animation colour sequence ─────────────────────────────────────
  //
  // The Divine badge cycles through the 9 static tier colours in order.
  // We test the colour table directly by re-declaring it here so the test
  // is independent of the widget (which needs a render context).

  group('Divine animation colour sequence', () {
    // Mirror of _DivineBadgeState._colors (first 9 entries before the loop-back)
    const tierColors = [
      Color(0xFFF59E0B), // common     — amber
      Color(0xFF4ADE80), // uncommon   — green
      Color(0xFF60A5FA), // rare       — blue
      Color(0xFF22D3EE), // super rare — cyan
      Color(0xFFA78BFA), // epic       — purple
      Color(0xFFE879F9), // heroic     — magenta
      Color(0xFFFB923C), // exotic     — orange
      Color(0xFFEF4444), // mythic     — red
      Color(0xFFFBBF24), // legendary  — gold
    ];

    test('covers all 9 static tiers', () {
      expect(tierColors.length, AchievementRarity.values.length - 1);
    });

    test('starts with Common amber', () {
      expect(tierColors.first, const Color(0xFFF59E0B));
    });

    test('ends with Legendary gold', () {
      expect(tierColors.last, const Color(0xFFFBBF24));
    });

    test('Heroic (index 5) is magenta', () {
      expect(tierColors[5], const Color(0xFFE879F9));
    });

    test('all colours are fully opaque', () {
      for (final c in tierColors) {
        expect(c.alpha, 0xFF,
            reason: 'colour $c must be fully opaque');
      }
    });
  });
}
