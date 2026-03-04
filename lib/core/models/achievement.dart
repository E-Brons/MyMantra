enum AchievementRarity { common, rare, epic, legendary }

enum AchievementMetric { sessions, streak, totalReps, hour }

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementMetric metric;
  final int value;
  final bool? before; // for hour-based: before this hour
  final AchievementRarity rarity;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.metric,
    required this.value,
    this.before,
    required this.rarity,
  });
}

const List<Achievement> kAchievements = [
  Achievement(
    id: 'ACH-001', title: 'First Steps',
    description: 'Complete your very first practice session.',
    emoji: '🌱', metric: AchievementMetric.sessions, value: 1,
    rarity: AchievementRarity.common,
  ),
  Achievement(
    id: 'ACH-002', title: 'Dedicated',
    description: 'Maintain a 3-day practice streak.',
    emoji: '🔥', metric: AchievementMetric.streak, value: 3,
    rarity: AchievementRarity.common,
  ),
  Achievement(
    id: 'ACH-003', title: 'Committed',
    description: 'Maintain a 7-day practice streak.',
    emoji: '⭐', metric: AchievementMetric.streak, value: 7,
    rarity: AchievementRarity.rare,
  ),
  Achievement(
    id: 'ACH-004', title: 'Devoted',
    description: 'Maintain a 30-day practice streak.',
    emoji: '💜', metric: AchievementMetric.streak, value: 30,
    rarity: AchievementRarity.epic,
  ),
  Achievement(
    id: 'ACH-005', title: 'Unwavering',
    description: 'Maintain a 60-day practice streak.',
    emoji: '💎', metric: AchievementMetric.streak, value: 60,
    rarity: AchievementRarity.epic,
  ),
  Achievement(
    id: 'ACH-006', title: 'Transcendent',
    description: 'Maintain a 180-day practice streak.',
    emoji: '🌙', metric: AchievementMetric.streak, value: 180,
    rarity: AchievementRarity.legendary,
  ),
  Achievement(
    id: 'ACH-007', title: 'Enlightened',
    description: 'Maintain a 365-day practice streak.',
    emoji: '☀️', metric: AchievementMetric.streak, value: 365,
    rarity: AchievementRarity.legendary,
  ),
  Achievement(
    id: 'ACH-008', title: 'Novice',
    description: 'Complete 1,000 total repetitions.',
    emoji: '🙏', metric: AchievementMetric.totalReps, value: 1000,
    rarity: AchievementRarity.common,
  ),
  Achievement(
    id: 'ACH-009', title: 'Adept',
    description: 'Complete 5,000 total repetitions.',
    emoji: '📿', metric: AchievementMetric.totalReps, value: 5000,
    rarity: AchievementRarity.rare,
  ),
  Achievement(
    id: 'ACH-010', title: 'Master',
    description: 'Complete 10,000 total repetitions.',
    emoji: '🏆', metric: AchievementMetric.totalReps, value: 10000,
    rarity: AchievementRarity.epic,
  ),
  Achievement(
    id: 'ACH-011', title: 'Guru',
    description: 'Complete 100,000 total repetitions.',
    emoji: '✨', metric: AchievementMetric.totalReps, value: 100000,
    rarity: AchievementRarity.legendary,
  ),
  Achievement(
    id: 'ACH-012', title: 'Early Bird',
    description: 'Complete a practice session before 7:00 AM.',
    emoji: '🌅', metric: AchievementMetric.hour, value: 7, before: true,
    rarity: AchievementRarity.rare,
  ),
  Achievement(
    id: 'ACH-013', title: 'Night Owl',
    description: 'Complete a practice session after 10:00 PM.',
    emoji: '🦉', metric: AchievementMetric.hour, value: 22, before: false,
    rarity: AchievementRarity.rare,
  ),
  Achievement(
    id: 'ACH-014', title: 'Centurion',
    description: 'Complete 100 practice sessions.',
    emoji: '💯', metric: AchievementMetric.sessions, value: 100,
    rarity: AchievementRarity.epic,
  ),
];
