import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/achievement.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/services/icon_registry.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final progress = state.progress;
    final reg = IconRegistry.instance;
    final progIcons = reg.section('Progress Screen');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 8,
              ),
              child: Text(
                'Progress',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          // ── Stats cards ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: progIcons['Current Streak'] ?? Icons.whatshot,
                          value: '${progress.currentStreak}',
                          label: 'Current Streak',
                          sublabel: 'days',
                          accent: const Color(0xFFF97316),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon:
                              progIcons['Longest Streak'] ?? Icons.trending_up,
                          value: '${progress.longestStreak}',
                          label: 'Longest Streak',
                          sublabel: 'days',
                          accent: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: progIcons['Sessions'] ?? Icons.self_improvement,
                          value: '${progress.totalSessions}',
                          label: 'Sessions',
                          sublabel: 'total',
                          accent: AppColors.violet500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon: progIcons['Repetitions'] ?? Icons.all_inclusive,
                          value: _formatReps(progress.totalRepetitions),
                          label: 'Repetitions',
                          sublabel: 'total',
                          accent: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Member since
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0x0A8B5CF6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          progIcons['Practicing since'] ?? Icons.event,
                          size: 20,
                          color: AppColors.violet400,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Practicing since',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.textMuted)),
                            Text(
                              _formatDate(progress.memberSince),
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Achievements ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Achievements',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemCount: kAchievements.length,
              itemBuilder: (_, i) {
                final ach = kAchievements[i];
                final unlocked =
                    progress.unlockedAchievements.any((ua) => ua.id == ach.id);
                return _AchievementCard(achievement: ach, unlocked: unlocked);
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _formatReps(int reps) {
    if (reps >= 1000000) return '${(reps / 1000000).toStringAsFixed(1)}M';
    if (reps >= 1000) return '${(reps / 1000).toStringAsFixed(1)}k';
    return '$reps';
  }

  static String _formatDate(DateTime dt) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dt.month]} ${dt.day}, ${dt.year}';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String sublabel;
  final Color accent;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.sublabel,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x0A8B5CF6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: accent),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
              const SizedBox(width: 4),
              Text(sublabel,
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          Text(label,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;

  const _AchievementCard({required this.achievement, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final lockedIcon =
        IconRegistry.instance.icon('Other', 'Locked achievement') ??
            Icons.lock_outline;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked ? const Color(0x148B5CF6) : const Color(0x058B5CF6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked ? AppColors.border : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            unlocked ? achievement.icon : lockedIcon,
            size: 28,
            color: unlocked ? AppColors.violet400 : AppColors.textMuted,
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: unlocked ? AppColors.textPrimary : AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Expanded(
            child: Text(
              achievement.description,
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          _RarityBadge(rarity: achievement.rarity),
        ],
      ),
    );
  }
}

class _RarityBadge extends StatelessWidget {
  final AchievementRarity rarity;
  const _RarityBadge({required this.rarity});

  @override
  Widget build(BuildContext context) {
    if (rarity == AchievementRarity.divine) {
      return const _DivineBadge();
    }
    final (color, label) = switch (rarity) {
      AchievementRarity.common => (const Color(0xFFFFD700), 'Common'),
      AchievementRarity.uncommon => (const Color(0xFF4ADE80), 'Uncommon'),
      AchievementRarity.rare => (const Color(0xFF60A5FA), 'Rare'),
      AchievementRarity.superRare => (const Color(0xFF22D3EE), 'Super Rare'),
      AchievementRarity.epic => (const Color(0xFFA78BFA), 'Epic'),
      AchievementRarity.heroic => (const Color(0xFFE879F9), 'Heroic'),
      AchievementRarity.exotic => (const Color(0xFFFB923C), 'Exotic'),
      AchievementRarity.mythic => (const Color(0xFFEF4444), 'Mythic'),
      AchievementRarity.legendary => (const Color(0xFFFBBF24), 'Legendary'),
      AchievementRarity.divine => (const Color(0xFFFFFFFF), 'Divine'),
    };
    return Text(label,
        style:
            TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500));
  }
}

class _DivineBadge extends StatefulWidget {
  const _DivineBadge();

  @override
  State<_DivineBadge> createState() => _DivineBadgeState();
}

class _DivineBadgeState extends State<_DivineBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Cycles through the 9 tiers in order (common → legendary), then loops
  static const _colors = [
    Color(0xFFFFD700), // common    — yellow
    Color(0xFF4ADE80), // uncommon  — green
    Color(0xFF60A5FA), // rare      — blue
    Color(0xFF22D3EE), // super rare — cyan
    Color(0xFFA78BFA), // epic      — purple
    Color(0xFFE879F9), // heroic    — magenta
    Color(0xFFFB923C), // exotic    — orange
    Color(0xFFEF4444), // mythic    — red
    Color(0xFFFBBF24), // legendary — gold
    Color(0xFFFFD700), // back to common (loop)
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value * (_colors.length - 1);
        final i = t.floor().clamp(0, _colors.length - 2);
        final color = Color.lerp(_colors[i], _colors[i + 1], t - i)!;
        return Text(
          'Divine',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        );
      },
    );
  }
}
