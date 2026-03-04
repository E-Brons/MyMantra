export interface AchievementDef {
  id: string;
  title: string;
  description: string;
  emoji: string;
  type: 'session' | 'streak' | 'volume' | 'time' | 'milestone';
  condition: {
    metric: 'sessions' | 'streak' | 'totalReps' | 'hour' | 'mantraFirst';
    value: number;
    before?: boolean; // for time-based: before this hour
  };
  rarity: 'common' | 'rare' | 'epic' | 'legendary';
  color: string;
  bgColor: string;
}

export const ACHIEVEMENTS: AchievementDef[] = [
  {
    id: 'ACH-001',
    title: 'First Steps',
    description: 'Complete your very first practice session.',
    emoji: '🌱',
    type: 'session',
    condition: { metric: 'sessions', value: 1 },
    rarity: 'common',
    color: 'text-emerald-400',
    bgColor: 'bg-emerald-900/30',
  },
  {
    id: 'ACH-002',
    title: 'Dedicated',
    description: 'Maintain a 3-day practice streak.',
    emoji: '🔥',
    type: 'streak',
    condition: { metric: 'streak', value: 3 },
    rarity: 'common',
    color: 'text-orange-400',
    bgColor: 'bg-orange-900/30',
  },
  {
    id: 'ACH-003',
    title: 'Committed',
    description: 'Maintain a 7-day practice streak.',
    emoji: '⭐',
    type: 'streak',
    condition: { metric: 'streak', value: 7 },
    rarity: 'rare',
    color: 'text-yellow-400',
    bgColor: 'bg-yellow-900/30',
  },
  {
    id: 'ACH-004',
    title: 'Devoted',
    description: 'Maintain a 30-day practice streak.',
    emoji: '💜',
    type: 'streak',
    condition: { metric: 'streak', value: 30 },
    rarity: 'epic',
    color: 'text-violet-400',
    bgColor: 'bg-violet-900/30',
  },
  {
    id: 'ACH-005',
    title: 'Unwavering',
    description: 'Maintain a 60-day practice streak.',
    emoji: '💎',
    type: 'streak',
    condition: { metric: 'streak', value: 60 },
    rarity: 'epic',
    color: 'text-cyan-400',
    bgColor: 'bg-cyan-900/30',
  },
  {
    id: 'ACH-006',
    title: 'Transcendent',
    description: 'Maintain a 180-day practice streak.',
    emoji: '🌙',
    type: 'streak',
    condition: { metric: 'streak', value: 180 },
    rarity: 'legendary',
    color: 'text-indigo-400',
    bgColor: 'bg-indigo-900/30',
  },
  {
    id: 'ACH-007',
    title: 'Enlightened',
    description: 'Maintain a 365-day practice streak.',
    emoji: '☀️',
    type: 'streak',
    condition: { metric: 'streak', value: 365 },
    rarity: 'legendary',
    color: 'text-amber-400',
    bgColor: 'bg-amber-900/30',
  },
  {
    id: 'ACH-008',
    title: 'Novice',
    description: 'Complete 1,000 total repetitions.',
    emoji: '🙏',
    type: 'volume',
    condition: { metric: 'totalReps', value: 1000 },
    rarity: 'common',
    color: 'text-blue-400',
    bgColor: 'bg-blue-900/30',
  },
  {
    id: 'ACH-009',
    title: 'Adept',
    description: 'Complete 5,000 total repetitions.',
    emoji: '📿',
    type: 'volume',
    condition: { metric: 'totalReps', value: 5000 },
    rarity: 'rare',
    color: 'text-purple-400',
    bgColor: 'bg-purple-900/30',
  },
  {
    id: 'ACH-010',
    title: 'Master',
    description: 'Complete 10,000 total repetitions.',
    emoji: '🏆',
    type: 'volume',
    condition: { metric: 'totalReps', value: 10000 },
    rarity: 'epic',
    color: 'text-rose-400',
    bgColor: 'bg-rose-900/30',
  },
  {
    id: 'ACH-011',
    title: 'Guru',
    description: 'Complete 100,000 total repetitions.',
    emoji: '✨',
    type: 'volume',
    condition: { metric: 'totalReps', value: 100000 },
    rarity: 'legendary',
    color: 'text-yellow-300',
    bgColor: 'bg-yellow-900/30',
  },
  {
    id: 'ACH-012',
    title: 'Early Bird',
    description: 'Complete a practice session before 7:00 AM.',
    emoji: '🌅',
    type: 'time',
    condition: { metric: 'hour', value: 7, before: true },
    rarity: 'rare',
    color: 'text-orange-300',
    bgColor: 'bg-orange-900/30',
  },
  {
    id: 'ACH-013',
    title: 'Night Owl',
    description: 'Complete a practice session after 10:00 PM.',
    emoji: '🦉',
    type: 'time',
    condition: { metric: 'hour', value: 22, before: false },
    rarity: 'rare',
    color: 'text-slate-400',
    bgColor: 'bg-slate-900/30',
  },
  {
    id: 'ACH-014',
    title: 'Centurion',
    description: 'Complete 100 practice sessions.',
    emoji: '💯',
    type: 'milestone',
    condition: { metric: 'sessions', value: 100 },
    rarity: 'epic',
    color: 'text-teal-400',
    bgColor: 'bg-teal-900/30',
  },
];

export const RARITY_LABELS: Record<string, string> = {
  common: 'Common',
  rare: 'Rare',
  epic: 'Epic',
  legendary: 'Legendary',
};

export const RARITY_COLORS: Record<string, string> = {
  common: 'text-slate-400',
  rare: 'text-blue-400',
  epic: 'text-purple-400',
  legendary: 'text-amber-400',
};
