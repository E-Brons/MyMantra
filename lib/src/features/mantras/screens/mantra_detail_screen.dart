import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/mantra.dart';
import '../../../core/models/session.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/utils/date_utils.dart';

class MantraDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const MantraDetailScreen({super.key, required this.id});

  @override
  ConsumerState<MantraDetailScreen> createState() => _MantraDetailScreenState();
}

class _MantraDetailScreenState extends ConsumerState<MantraDetailScreen> {
  int _activeLanguage = 0;
  bool _showAddReminder = false;
  bool _showDelete = false;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(appProvider.notifier);
    final mantra = notifier.getMantra(widget.id);
    if (mantra == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Mantra not found.', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              TextButton(onPressed: () => context.go('/'), child: const Text('Go home')),
            ],
          ),
        ),
      );
    }

    final recentSessions = notifier.getRecentSessions(mantraId: widget.id, limit: 5);
    final languages = [
      (label: 'Original', text: mantra.text, isDevanagari: true),
      if (mantra.transliteration != null)
        (label: 'IAST', text: mantra.transliteration!, isDevanagari: false),
      if (mantra.translation != null)
        (label: 'English', text: mantra.translation!, isDevanagari: false),
    ];

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── App bar ──────────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.bgBase,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0x1A8B5CF6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, size: 18, color: AppColors.textPrimary),
                  ),
                  onPressed: () => context.canPop() ? context.pop() : context.go('/'),
                ),
                title: Text(
                  mantra.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') context.push('/mantras/${mantra.id}/edit');
                      if (v == 'delete') setState(() => _showDelete = true);
                    },
                    color: const Color(0xFF1A1535),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 16, color: AppColors.violet400),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      )),
                      const PopupMenuItem(value: 'delete', child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 16, color: AppColors.red),
                          SizedBox(width: 10),
                          Text('Delete', style: TextStyle(color: AppColors.red)),
                        ],
                      )),
                    ],
                  ),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Mantra text card ─────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0x1F8B5CF6), Color(0x801E1B4B)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (languages.length > 1)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(languages.length, (i) {
                                final active = _activeLanguage == i;
                                return GestureDetector(
                                  onTap: () => setState(() => _activeLanguage = i),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: active ? AppColors.violet600 : const Color(0x0F8B5CF6),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Text(
                                      languages[i].label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: active ? Colors.white : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            languages[_activeLanguage].text,
                            style: TextStyle(
                              fontFamily: languages[_activeLanguage].isDevanagari
                                  ? 'NotoSansDevanagari'
                                  : null,
                              fontSize: languages[_activeLanguage].isDevanagari ? 22 : 16,
                              color: AppColors.textPrimary,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.tag, size: 13, color: AppColors.violet400),
                              const SizedBox(width: 4),
                              Text(
                                '${mantra.targetRepetitions} repetitions',
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                              if (mantra.tradition != null) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0x268B5CF6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    mantra.tradition!,
                                    style: const TextStyle(fontSize: 11, color: AppColors.violet300),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Start session button ──────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/mantras/${mantra.id}/session'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.violet600,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          shadowColor: const Color(0x667C3AED),
                        ),
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: const Text(
                          'Start Session',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Reminders ────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Reminders',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        TextButton.icon(
                          onPressed: () => setState(() => _showAddReminder = true),
                          icon: const Icon(Icons.add, size: 15, color: AppColors.violet400),
                          label: const Text('Add', style: TextStyle(color: AppColors.violet400, fontSize: 13)),
                          style: TextButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (mantra.reminders.isEmpty)
                      GestureDetector(
                        onTap: () => setState(() => _showAddReminder = true),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0x088B5CF6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.notifications_off_outlined, size: 16, color: AppColors.violet400),
                              SizedBox(width: 10),
                              Text('No reminders yet — tap to add',
                                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      )
                    else
                      ...mantra.reminders.map((r) => _ReminderTile(
                        reminder: r,
                        mantraId: mantra.id,
                      )),

                    const SizedBox(height: 24),

                    // ── Recent sessions ───────────────────────────────────
                    const Text('Recent Sessions',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    if (recentSessions.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderSubtle),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('No sessions yet. Start practicing!',
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        ),
                      )
                    else
                      ...recentSessions.map((s) => _SessionTile(session: s)),
                  ]),
                ),
              ),
            ],
          ),

          // ── Delete dialog ────────────────────────────────────────────────
          if (_showDelete)
            _DeleteDialog(
              title: mantra.title,
              onConfirm: () {
                ref.read(appProvider.notifier).deleteMantra(mantra.id);
                context.go('/');
              },
              onCancel: () => setState(() => _showDelete = false),
            ),

          // ── Add reminder sheet ───────────────────────────────────────────
          if (_showAddReminder)
            _AddReminderSheet(
              mantraId: mantra.id,
              onClose: () => setState(() => _showAddReminder = false),
            ),
        ],
      ),
    );
  }
}

// ─── Reminder tile ────────────────────────────────────────────────────────────

class _ReminderTile extends ConsumerWidget {
  final Reminder reminder;
  final String mantraId;
  const _ReminderTile({required this.reminder, required this.mantraId});

  static const _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x0F8B5CF6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_outlined, size: 16, color: AppColors.violet400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reminder.time,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text(
                  reminder.days.length == 7
                      ? 'Every day'
                      : reminder.days.map((d) => _days[d]).join(', '),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: reminder.enabled,
            onChanged: (v) => ref
                .read(appProvider.notifier)
                .updateReminder(mantraId, reminder.id, enabled: v),
            activeThumbColor: AppColors.violet500,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.textMuted),
            onPressed: () =>
                ref.read(appProvider.notifier).deleteReminder(mantraId, reminder.id),
          ),
        ],
      ),
    );
  }
}

// ─── Session tile ─────────────────────────────────────────────────────────────

class _SessionTile extends StatelessWidget {
  final Session session;
  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x0A8B5CF6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.violet400),
                    const SizedBox(width: 6),
                    Text(
                      '${session.startTime.month}/${session.startTime.day}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${session.repsCompleted}/${session.targetReps} reps',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, size: 11, color: AppColors.textMuted),
                    const SizedBox(width: 3),
                    Text(
                      formatDuration(session.duration),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (session.completed)
            const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF10B981))
          else
            const Text('partial', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ─── Add reminder sheet ───────────────────────────────────────────────────────

class _AddReminderSheet extends ConsumerStatefulWidget {
  final String mantraId;
  final VoidCallback onClose;
  const _AddReminderSheet({required this.mantraId, required this.onClose});

  @override
  ConsumerState<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends ConsumerState<_AddReminderSheet> {
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 0);
  final List<int> _selectedDays = List.generate(7, (i) => i);
  static const _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black54,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
              decoration: const BoxDecoration(
                color: Color(0xFF0D0B1A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Add Reminder',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Time', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(context: context, initialTime: _time);
                      if (picked != null) setState(() => _time = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0x148B5CF6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 18, color: AppColors.violet400),
                          const SizedBox(width: 12),
                          Text(
                            _time.format(context),
                            style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Repeat on', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(7, (i) {
                      final selected = _selectedDays.contains(i);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            selected ? _selectedDays.remove(i) : _selectedDays.add(i);
                          }),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.violet600 : const Color(0x0A8B5CF6),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Center(
                              child: Text(
                                _days[i],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: selected ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedDays.isEmpty
                          ? null
                          : () {
                              final h = _time.hour.toString().padLeft(2, '0');
                              final m = _time.minute.toString().padLeft(2, '0');
                              ref.read(appProvider.notifier).addReminder(
                                    widget.mantraId,
                                    time: '$h:$m',
                                    days: List<int>.from(_selectedDays)..sort(),
                                  );
                              widget.onClose();
                            },
                      child: const Text('Save Reminder'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Delete dialog ────────────────────────────────────────────────────────────

class _DeleteDialog extends StatelessWidget {
  final String title;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _DeleteDialog({required this.title, required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0B1A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x4DEF4444)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 12),
              const Text('Delete Mantra',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete "$title"? This cannot be undone.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
