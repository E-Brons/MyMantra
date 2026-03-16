import 'package:flutter/material.dart';
import '../services/icon_registry.dart';

enum AchievementRarity { common, uncommon, rare, superRare, epic, heroic, exotic, mythic, legendary, divine }

enum AchievementMetric { sessions, streak, totalReps, hour, platform }

class Achievement {
  final String id;
  final String title;
  final String description;

  /// Key into the "Achievement Badges" section of icons.yml.
  /// The icon is resolved at runtime via [IconRegistry].
  final String iconKey;

  final AchievementMetric metric;
  final int value;
  final bool? before; // for hour-based: before this hour
  final String? platformId; // for platform-based achievements
  final AchievementRarity rarity;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.metric,
    required this.value,
    this.before,
    this.platformId,
    required this.rarity,
  });

  /// Resolved icon from icons.yml → "Achievements" section (keyed by [id]).
  /// Falls back to a question-mark icon if the key is missing from the YML.
  IconData get icon =>
      IconRegistry.instance.icon('Achievements', id) ??
      Icons.help_outline;
}
/// Returns the subset of [kAchievements] that should be displayed to the user.
///
/// Visibility rules per group (sourced from `icons.yml` via [IconRegistry]):
/// - **always** — all items in the group are always shown.
/// - **progressive** — shows only unlocked items plus the immediate next item
///   in the chain (the "teaser"). If the user has nothing unlocked in a
///   progressive group, only the very first item is shown (as the teaser).
/// - **never** — items are hidden until earned; only unlocked items appear.
///
/// [unlockedIds] is the set of achievement [Achievement.id] values the user
/// has already earned.
List<Achievement> visibleAchievements(Set<String> unlockedIds) {
  final byId = {for (final a in kAchievements) a.id: a};
  final result = <Achievement>[];

  for (final group in IconRegistry.instance.achievementGroups) {
    switch (group.visibility) {
      case 'always':
        for (final entry in group.items) {
          final a = byId[entry.id];
          if (a != null) result.add(a);
        }

      case 'progressive':
        bool addedTeaser = false;
        for (int i = 0; i < group.items.length; i++) {
          final entry = group.items[i];
          final a = byId[entry.id];
          if (a == null) continue;
          if (unlockedIds.contains(entry.id)) {
            result.add(a);
            addedTeaser = false; // unlock clears the pending teaser flag
          } else if (!addedTeaser) {
            // First locked item after the unlocked run → show as teaser.
            result.add(a);
            addedTeaser = true;
            break; // remaining chain items stay hidden
          }
        }

      case 'never':
        for (final entry in group.items) {
          if (unlockedIds.contains(entry.id)) {
            final a = byId[entry.id];
            if (a != null) result.add(a);
          }
        }
    }
  }

  return result;
}


const List<Achievement> kAchievements = [
  // ── Streak achievements ──────────────────────────────────────────────────
  Achievement(
    id: 'ACH-STR-001', title: 'Thought',
    description: 'Complete your very first practice session.',
    iconKey: 'Thought (1 session)', metric: AchievementMetric.sessions, value: 1,
    rarity: AchievementRarity.common,
  ),
  Achievement(
    id: 'ACH-STR-003', title: 'Action',
    description: 'Maintain a 3-day practice streak.',
    iconKey: 'Action (3-day streak)', metric: AchievementMetric.streak, value: 3,
    rarity: AchievementRarity.uncommon,
  ),
  Achievement(
    id: 'ACH-STR-007', title: 'Routine',
    description: 'Maintain a 7-day practice streak.',
    iconKey: 'Routine (7-day streak)', metric: AchievementMetric.streak, value: 7,
    rarity: AchievementRarity.rare,
  ),
  Achievement(
    id: 'ACH-STR-014', title: 'Discipline',
    description: 'Maintain a 14-day practice streak.',
    iconKey: 'Discipline (14-day streak)', metric: AchievementMetric.streak, value: 14,
    rarity: AchievementRarity.superRare,
  ),
  Achievement(
    id: 'ACH-STR-030', title: 'Habit',
    description: 'Maintain a 30-day practice streak.',
    iconKey: 'Habit (30-day streak)', metric: AchievementMetric.streak, value: 30,
    rarity: AchievementRarity.epic,
  ),
  Achievement(
    id: 'ACH-STR-060', title: 'Grit',
    description: 'Maintain a 60-day practice streak.',
    iconKey: 'Grit (60-day streak)', metric: AchievementMetric.streak, value: 60,
    rarity: AchievementRarity.heroic,
  ),
  Achievement(
    id: 'ACH-STR-090', title: 'Resolve',
    description: 'Maintain a 90-day practice streak.',
    iconKey: 'Resolve (90 days)', metric: AchievementMetric.streak, value: 90,
    rarity: AchievementRarity.exotic,
  ),
  Achievement(
    id: 'ACH-STR-180', title: 'Persistence',
    description: 'Maintain a 180-day practice streak.',
    iconKey: 'Persistence (180 days)', metric: AchievementMetric.streak, value: 180,
    rarity: AchievementRarity.mythic,
  ),
  Achievement(
    id: 'ACH-STR-365', title: 'Character',
    description: 'Maintain a 365-day practice streak.',
    iconKey: 'Character (365 days)', metric: AchievementMetric.streak, value: 365,
    rarity: AchievementRarity.legendary,
  ),
  Achievement(
    id: 'ACH-STR-1095', title: 'Destiny',
    description: 'Maintain a 3-year practice streak.',
    iconKey: 'Destiny (3 Years)', metric: AchievementMetric.streak, value: 1095,
    rarity: AchievementRarity.divine,
  ),

  // ── Repetition achievements ──────────────────────────────────────────────
  Achievement(
    id: 'ACH-REP-1K', title: '1K Repetitions',
    description: 'Complete 1,000 total repetitions.',
    iconKey: '1K Repititions', metric: AchievementMetric.totalReps, value: 1000,
    rarity: AchievementRarity.common,
  ),
  Achievement(
    id: 'ACH-REP-5K', title: '5K Repetitions',
    description: 'Complete 5,000 total repetitions.',
    iconKey: '5K Repititions', metric: AchievementMetric.totalReps, value: 5000,
    rarity: AchievementRarity.uncommon,
  ),
  Achievement(
    id: 'ACH-REP-10K', title: '10K Repetitions',
    description: 'Complete 10,000 total repetitions.',
    iconKey: '10K Repititions', metric: AchievementMetric.totalReps, value: 10000,
    rarity: AchievementRarity.rare,
  ),
  Achievement(
    id: 'ACH-REP-50K', title: '50K Repetitions',
    description: 'Complete 50,000 total repetitions.',
    iconKey: '50K Repititions', metric: AchievementMetric.totalReps, value: 50000,
    rarity: AchievementRarity.superRare,
  ),
  Achievement(
    id: 'ACH-REP-100K', title: '100K Repetitions',
    description: 'Complete 100,000 total repetitions.',
    iconKey: '100K Repititions', metric: AchievementMetric.totalReps, value: 100000,
    rarity: AchievementRarity.epic,
  ),
  Achievement(
    id: 'ACH-REP-250K', title: '250K Repetitions',
    description: 'Complete 250,000 total repetitions.',
    iconKey: '250K Repititions', metric: AchievementMetric.totalReps, value: 250000,
    rarity: AchievementRarity.exotic,
  ),
  Achievement(
    id: 'ACH-REP-500K', title: '500K Repetitions',
    description: 'Complete 500,000 total repetitions.',
    iconKey: '500K Repititions', metric: AchievementMetric.totalReps, value: 500000,
    rarity: AchievementRarity.mythic,
  ),
  Achievement(
    id: 'ACH-REP-1M', title: '1M Repetitions',
    description: 'Complete 1,000,000 total repetitions.',
    iconKey: '1M Repititions', metric: AchievementMetric.totalReps, value: 1000000,
    rarity: AchievementRarity.legendary,
  ),

  // ── Time-of-day achievements ─────────────────────────────────────────────
  Achievement(
    id: 'ACH-TIME-EARLY', title: 'Early Bird',
    description: 'Complete a practice session between 4 AM and 7 AM.',
    iconKey: 'Early Bird (4am-7am)', metric: AchievementMetric.hour, value: 7, before: true,
    rarity: AchievementRarity.uncommon,
  ),
  Achievement(
    id: 'ACH-TIME-NIGHT', title: 'Night Owl',
    description: 'Complete a practice session after 10 PM.',
    iconKey: 'Night Owl (after 10pm)', metric: AchievementMetric.hour, value: 22, before: false,
    rarity: AchievementRarity.uncommon,
  ),

  // ── Session count achievements ───────────────────────────────────────────
  Achievement(
    id: 'ACH-SES-010', title: '10 Sessions',
    description: 'Complete 10 practice sessions.',
    iconKey: '10 sessions', metric: AchievementMetric.sessions, value: 10,
    rarity: AchievementRarity.uncommon,
  ),
  Achievement(
    id: 'ACH-SES-100', title: '100 Sessions',
    description: 'Complete 100 practice sessions.',
    iconKey: '100 sessions', metric: AchievementMetric.sessions, value: 100,
    rarity: AchievementRarity.rare,
  ),
  Achievement(
    id: 'ACH-SES-250', title: '250 Sessions',
    description: 'Complete 250 practice sessions.',
    iconKey: '250 sessions', metric: AchievementMetric.sessions, value: 250,
    rarity: AchievementRarity.superRare,
  ),
  Achievement(
    id: 'ACH-SES-500', title: '500 Sessions',
    description: 'Complete 500 practice sessions.',
    iconKey: '500 sessions', metric: AchievementMetric.sessions, value: 500,
    rarity: AchievementRarity.epic,
  ),
  Achievement(
    id: 'ACH-SES-1K', title: '1K Sessions',
    description: 'Complete 1,000 practice sessions.',
    iconKey: '1K sessions', metric: AchievementMetric.sessions, value: 1000,
    rarity: AchievementRarity.heroic,
  ),
  Achievement(
    id: 'ACH-SES-2K', title: '2K Sessions',
    description: 'Complete 2,000 practice sessions.',
    iconKey: '2K sessions', metric: AchievementMetric.sessions, value: 2000,
    rarity: AchievementRarity.exotic,
  ),
  Achievement(
    id: 'ACH-SES-10K', title: '10K Sessions',
    description: 'Complete 10,000 practice sessions.',
    iconKey: '10K sessions', metric: AchievementMetric.sessions, value: 10000,
    rarity: AchievementRarity.mythic,
  ),
  Achievement(
    id: 'ACH-SES-50K', title: '50K Sessions',
    description: 'Complete 50,000 practice sessions.',
    iconKey: '50K sessions', metric: AchievementMetric.sessions, value: 50000,
    rarity: AchievementRarity.legendary,
  ),
  Achievement(
    id: 'ACH-SES-100K', title: '100K Sessions',
    description: 'Complete 100,000 practice sessions.',
    iconKey: '100K sessions', metric: AchievementMetric.sessions, value: 100000,
    rarity: AchievementRarity.divine,
  ),

  // ── Platform achievements ────────────────────────────────────────────────
  Achievement(
    id: 'ACH-PLT-ANDROID', title: 'Android',
    description: 'Practice on Android.',
    iconKey: 'Android', metric: AchievementMetric.platform, value: 1,
    platformId: 'android',
    rarity: AchievementRarity.uncommon,
  ),
  Achievement(
    id: 'ACH-PLT-IOS', title: 'iOS',
    description: 'Practice on iOS.',
    iconKey: 'iOS', metric: AchievementMetric.platform, value: 1,
    platformId: 'ios',
    rarity: AchievementRarity.uncommon,
  ),
  Achievement(
    id: 'ACH-PLT-MAC', title: 'Mac',
    description: 'Practice on macOS.',
    iconKey: 'Mac', metric: AchievementMetric.platform, value: 1,
    platformId: 'macos',
    rarity: AchievementRarity.exotic,
  ),
  Achievement(
    id: 'ACH-PLT-LINUX', title: 'Linux',
    description: 'Practice on Linux.',
    iconKey: 'Linux', metric: AchievementMetric.platform, value: 1,
    platformId: 'linux',
    rarity: AchievementRarity.exotic,
  ),
  Achievement(
    id: 'ACH-PLT-WEB', title: 'Web',
    description: 'Practice on the web.',
    iconKey: 'Web', metric: AchievementMetric.platform, value: 1,
    platformId: 'web',
    rarity: AchievementRarity.rare,
  ),

  // ── Special achievements ─────────────────────────────────────────────────
  Achievement(
    id: 'ACH-SPL-CREATE', title: 'Creator',
    description: 'Create your own mantra.',
    iconKey: 'Creator', metric: AchievementMetric.sessions, value: 0,
    rarity: AchievementRarity.uncommon,
  ),
];
