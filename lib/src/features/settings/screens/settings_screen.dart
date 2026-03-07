import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/settings.dart';
import '../../../core/providers/app_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final settings = state.settings;
    final notifier = ref.read(appProvider.notifier);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20, right: 20, bottom: 8,
              ),
              child: const Text(
                'Settings',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Appearance ───────────────────────────────────────────
                const _SectionHeader('Appearance'),
                _SettingCard(
                  children: [
                    _SettingRow(
                      icon: Icons.palette_outlined,
                      label: 'Theme',
                      child: DropdownButton<AppThemeMode>(
                        value: settings.theme,
                        dropdownColor: AppColors.bgSurface,
                        underline: const SizedBox.shrink(),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        onChanged: (v) => notifier.updateSettings(settings.copyWith(theme: v)),
                        items: const [
                          DropdownMenuItem(value: AppThemeMode.dark, child: Text('Dark')),
                          DropdownMenuItem(value: AppThemeMode.light, child: Text('Light')),
                          DropdownMenuItem(value: AppThemeMode.system, child: Text('System')),
                        ],
                      ),
                    ),
                    _Divider(),
                    _SettingRow(
                      icon: Icons.text_fields,
                      label: 'Font size',
                      child: DropdownButton<String>(
                        value: settings.fontSize,
                        dropdownColor: AppColors.bgSurface,
                        underline: const SizedBox.shrink(),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        onChanged: (v) =>
                            notifier.updateSettings(settings.copyWith(fontSize: v)),
                        items: const [
                          DropdownMenuItem(value: 'small', child: Text('Small')),
                          DropdownMenuItem(value: 'medium', child: Text('Medium')),
                          DropdownMenuItem(value: 'large', child: Text('Large')),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── Practice ─────────────────────────────────────────────
                const _SectionHeader('Practice'),
                _SettingCard(
                  children: [
                    _SettingRow(
                      icon: Icons.vibration,
                      label: 'Haptic feedback',
                      child: Switch(
                        value: settings.vibrationEnabled,
                        onChanged: (v) =>
                            notifier.updateSettings(settings.copyWith(vibrationEnabled: v)),
                        activeThumbColor: AppColors.violet500,
                      ),
                    ),
                    _Divider(),
                    _SettingRow(
                      icon: Icons.repeat,
                      label: 'Default repetitions',
                      child: DropdownButton<int>(
                        value: settings.defaultRepetitions,
                        dropdownColor: AppColors.bgSurface,
                        underline: const SizedBox.shrink(),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        onChanged: (v) =>
                            notifier.updateSettings(settings.copyWith(defaultRepetitions: v)),
                        items: const [
                          DropdownMenuItem(value: 27, child: Text('27')),
                          DropdownMenuItem(value: 54, child: Text('54')),
                          DropdownMenuItem(value: 108, child: Text('108')),
                          DropdownMenuItem(value: 216, child: Text('216')),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── Notifications ─────────────────────────────────────────
                const _SectionHeader('Notifications'),
                _SettingCard(
                  children: [
                    _SettingRow(
                      icon: Icons.notifications_outlined,
                      label: 'Enable notifications',
                      child: Switch(
                        value: settings.notificationsEnabled,
                        onChanged: (v) =>
                            notifier.updateSettings(settings.copyWith(notificationsEnabled: v)),
                        activeThumbColor: AppColors.violet500,
                      ),
                    ),
                  ],
                ),

                // ── About ─────────────────────────────────────────────────
                const _SectionHeader('About'),
                _SettingCard(
                  children: [
                    const _InfoRow(label: 'App', value: 'MyMantra'),
                    _Divider(),
                    const _InfoRow(label: 'Version', value: '1.0.0'),
                    _Divider(),
                    const _InfoRow(label: 'Philosophy', value: 'Practice, No Attachment'),
                    _Divider(),
                    const _InfoRow(label: 'Signature mantra', value: 'Yoga Sutra I.12'),
                  ],
                ),

                const SizedBox(height: 16),

                // Stats summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0x148B5CF6), Color(0x0A1E1B4B)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      const Text('Your Practice', style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                      )),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _MiniStat('${state.mantras.length}', 'Mantras'),
                          _MiniStat('${state.progress.totalSessions}', 'Sessions'),
                          _MiniStat('${state.progress.currentStreak}', 'Streak'),
                          _MiniStat(
                            '${state.progress.unlockedAchievements.length}/$kAchievementCount',
                            'Badges',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

const int kAchievementCount = 14;

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 0, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x0A8B5CF6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _SettingRow({required this.icon, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.violet400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          ),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 46, color: Color(0x1A8B5CF6));
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  const _MiniStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.violet400)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}
