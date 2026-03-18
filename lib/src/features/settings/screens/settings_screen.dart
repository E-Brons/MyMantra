import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/mantra.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textSecondary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [

          // ── Account ────────────────────────────────────────────────────
          const _SectionHeader('Account'),
          _SettingCard(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.cloud_off_outlined, size: 18, color: AppColors.textMuted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Offline mode', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                          Text('Sign in to sync your data across devices (coming soon)',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: OutlinedButton(
                  onPressed: null, // Phase 2.0
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.borderSubtle),
                  ),
                  child: const Text('Sign In (coming soon)'),
                ),
              ),
            ],
          ),

          // ── Language ───────────────────────────────────────────────────
          const _SectionHeader('Language'),
          _SettingCard(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.language, size: 18, color: AppColors.violet400),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('UI Language', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                          Text('Language selection coming soon',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Appearance ─────────────────────────────────────────────────
          const _SectionHeader('Appearance'),
          _SettingCard(
            children: [
              _ChipRow<AppThemeMode>(
                icon: Icons.palette_outlined,
                label: 'Theme',
                value: settings.theme,
                items: const [
                  (AppThemeMode.dark, 'Dark'),
                  (AppThemeMode.light, 'Light'),
                  (AppThemeMode.system, 'System'),
                ],
                onChanged: (v) => notifier.updateSettings(settings.copyWith(theme: v)),
              ),
              _Divider(),
              _ChipRow<String>(
                icon: Icons.text_fields,
                label: 'Font size',
                subtitle: 'Persisted — visual adjustment coming soon',
                value: settings.fontSize,
                items: const [
                  ('small', 'Small'),
                  ('medium', 'Medium'),
                  ('large', 'Large'),
                ],
                onChanged: (v) => notifier.updateSettings(settings.copyWith(fontSize: v)),
              ),
            ],
          ),

          // ── Practice Defaults ──────────────────────────────────────────
          const _SectionHeader('Practice Defaults'),
          _SettingCard(
            children: [
              _ChipRow<int>(
                icon: Icons.repeat,
                label: 'Default repetitions',
                value: settings.defaultRepetitions,
                items: const [(27, '27'), (54, '54'), (108, '108'), (216, '216')],
                onChanged: (v) => notifier.updateSettings(settings.copyWith(defaultRepetitions: v)),
              ),
              _Divider(),
              _ChipRow<RepetitionCycle>(
                icon: Icons.loop,
                label: 'Default cycle',
                value: settings.defaultRepetitionCycle,
                items: RepetitionCycle.values.map((c) => (c, c.label)).toList(),
                onChanged: (v) => notifier.updateSettings(settings.copyWith(defaultRepetitionCycle: v)),
              ),
              _Divider(),
              // Default practice mode — Tap to count available; others future
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.touch_app_outlined, size: 18, color: AppColors.violet400),
                        const SizedBox(width: 12),
                        Text('Default practice mode',
                            style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Wrap(
                      spacing: 8, runSpacing: 6,
                      children: [
                        _ModeChip(label: 'Tap to count', available: true),
                        _ModeChip(label: 'Listen', available: false),
                        _ModeChip(label: 'AI listens', available: false),
                      ],
                    ),
                  ],
                ),
              ),
              _Divider(),
              if (!kIsWeb &&
                  (defaultTargetPlatform == TargetPlatform.iOS ||
                      defaultTargetPlatform == TargetPlatform.android)) ...[
                _SettingRow(
                  icon: Icons.vibration,
                  label: 'Haptic feedback',
                  child: Switch(
                    value: settings.vibrationEnabled,
                    onChanged: (v) =>
                        notifier.updateSettings(settings.copyWith(vibrationEnabled: v)),
                    activeTrackColor: AppColors.violet500,
                  ),
                ),
                _Divider(),
              ],
              _SettingRow(
                icon: Icons.speed,
                label: 'Limit tap rate',
                subtitle: 'Prevents double-counts (1 s min)',
                child: Switch(
                  value: settings.limitClickRate,
                  onChanged: (v) =>
                      notifier.updateSettings(settings.copyWith(limitClickRate: v)),
                  activeTrackColor: AppColors.violet500,
                ),
              ),
            ],
          ),

          // ── Notifications ──────────────────────────────────────────────
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
                  activeTrackColor: AppColors.violet500,
                ),
              ),
            ],
          ),

          // ── About ──────────────────────────────────────────────────────
          const _SectionHeader('About'),
          _SettingCard(
            children: [
              const _InfoRow(label: 'App', value: 'MyMantra'),
              _Divider(),
              const _InfoRow(label: 'Version', value: '0.2.0'),
              _Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'abhyāsa-vairāgya-ābhyāṃ tat-nirodhaḥ',
                      style: TextStyle(
                        fontFamily: 'TiroSanskrit',
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By practice and non-attachment the mind is still — Yoga Sutras 1.12',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Feedback button
          OutlinedButton.icon(
            onPressed: () => context.push('/feedback'),
            icon: Icon(Icons.feedback_outlined, color: AppColors.violet400),
            label: Text('Feedback', style: TextStyle(color: AppColors.violet400)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: BorderSide(color: AppColors.borderSubtle),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}

const int kAchievementCount = 14;

// ── Chip row ──────────────────────────────────────────────────────────────────

class _ChipRow<T> extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final T value;
  final List<(T, String)> items;
  final ValueChanged<T> onChanged;

  const _ChipRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.violet400),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                  if (subtitle != null)
                    Text(subtitle!, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 6,
            children: items.map(((T, String) item) {
              final selected = item.$1 == value;
              return ChoiceChip(
                label: Text(item.$2),
                selected: selected,
                onSelected: (_) => onChanged(item.$1),
                selectedColor: AppColors.violet600,
                backgroundColor: const Color(0x0A8B5CF6),
                labelStyle: TextStyle(
                  fontSize: 13,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
                side: BorderSide(
                  color: selected ? AppColors.violet500 : AppColors.borderSubtle,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Practice mode chip (with available/future distinction) ───────────────────

class _ModeChip extends StatelessWidget {
  final String label;
  final bool available;
  const _ModeChip({required this.label, required this.available});

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(available ? label : '$label (soon)'),
      isEnabled: available,
      selected: available, // only one available so it's "selected" by default
      onSelected: available ? (_) {} : null,
      selectedColor: AppColors.violet600,
      backgroundColor: const Color(0x0A8B5CF6),
      disabledColor: const Color(0x0A8B5CF6),
      labelStyle: TextStyle(
        fontSize: 13,
        color: available ? Colors.white : AppColors.textMuted,
      ),
      side: BorderSide(
        color: available ? AppColors.violet500 : AppColors.borderSubtle,
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 0, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
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
  final String? subtitle;
  final Widget child;

  const _SettingRow({required this.icon, required this.label, required this.child, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.violet400),
          const SizedBox(width: 12),
          Expanded(
            child: subtitle != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      Text(subtitle!, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  )
                : Text(label, style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
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
          Text(label, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
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
