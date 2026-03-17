import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/mantra.dart';
import '../../../core/models/session.dart';
import '../../../core/providers/app_provider.dart';

class MyPracticeScreen extends ConsumerStatefulWidget {
  const MyPracticeScreen({super.key});

  @override
  ConsumerState<MyPracticeScreen> createState() => _MyPracticeScreenState();
}

class _MyPracticeScreenState extends ConsumerState<MyPracticeScreen> {
  bool _limitWarningDismissed = false;

  void _onMantraTap(Mantra mantra) {
    final notifier = ref.read(appProvider.notifier);
    final suspended = notifier.suspendedSessionFor(mantra.id);
    if (suspended != null) {
      showDialog<void>(
        context: context,
        builder: (ctx) => _ResumeDialog(
          repsCompleted: suspended.repsCompleted,
          targetReps: mantra.targetRepetitions,
          onResume: () {
            ctx.pop();
            context.push('/mantras/${mantra.id}/session?resume=true');
          },
          onNewSession: () {
            ctx.pop();
            notifier.discardSuspendedSession(mantra.id);
            context.push('/mantras/${mantra.id}/session');
          },
        ),
      );
    } else {
      context.push('/mantras/${mantra.id}/session');
    }
  }

  Future<void> _onAddMantra() async {
    final mantras = ref.read(appProvider).mantras;
    if (mantras.length >= 5 && !_limitWarningDismissed) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('A lot of mantras?',
              style: TextStyle(color: AppColors.textPrimary)),
          content: Text(
            'Practicing more than 5 mantras may dilute your focus. Are you sure?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          backgroundColor: AppColors.bgSurface,
          actions: [
            TextButton(
              onPressed: () => ctx.pop(false),
              child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            FilledButton(
              onPressed: () {
                setState(() => _limitWarningDismissed = true);
                ctx.pop(true);
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.violet600),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }
    if (!mounted) return;
    context.push('/mantras/new');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final mantras = state.mantras;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x1F7C3AED), Colors.transparent],
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20, right: 20, bottom: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MyPractice',
                        style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Your daily practice',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.settings_outlined, color: AppColors.textSecondary),
                    onPressed: () => context.push('/settings'),
                    tooltip: 'Settings',
                  ),
                ],
              ),
            ),
          ),

          // ── Mantra list or empty state ─────────────────────────────────
          if (mantras.isEmpty)
            SliverFillRemaining(child: _EmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList.separated(
                itemCount: mantras.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final m = mantras[i];
                  final notifier = ref.read(appProvider.notifier);
                  final suspended = notifier.suspendedSessionFor(m.id);
                  final streak = state.progress.currentStreak;
                  return _MantraPracticeCard(
                    mantra: m,
                    suspended: suspended,
                    streak: streak,
                    onTap: () => _onMantraTap(m),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddMantra,
        backgroundColor: AppColors.violet600,
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

// ── Resume dialog ─────────────────────────────────────────────────────────────

class _ResumeDialog extends StatelessWidget {
  final int repsCompleted;
  final int targetReps;
  final VoidCallback onResume;
  final VoidCallback onNewSession;
  const _ResumeDialog({
    required this.repsCompleted,
    required this.targetReps,
    required this.onResume,
    required this.onNewSession,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Session in progress',
          style: TextStyle(color: AppColors.textPrimary)),
      content: Text(
        '$repsCompleted of $targetReps repetitions completed.',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      backgroundColor: AppColors.bgSurface,
      actions: [
        OutlinedButton(
          onPressed: onNewSession,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: BorderSide(color: AppColors.borderSubtle),
          ),
          child: const Text('New Session'),
        ),
        OutlinedButton(
          onPressed: onResume,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: BorderSide(color: AppColors.borderSubtle),
          ),
          child: const Text('Resume'),
        ),
      ],
    );
  }
}

// ── Mantra card ──────────────────────────────────────────────────────────────

class _MantraPracticeCard extends StatelessWidget {
  final Mantra mantra;
  final Session? suspended;
  final int streak;
  final VoidCallback onTap;

  const _MantraPracticeCard({
    required this.mantra,
    required this.suspended,
    required this.streak,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x147C3AED), Color(0x661E1B4B)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x337C3AED)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mantra.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mantra.text.split('\n').first,
                    style: TextStyle(
                      fontFamily: 'NotoSansDevanagari',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (mantra.tradition != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0x1A8B5CF6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        mantra.tradition!,
                        style: TextStyle(fontSize: 11, color: AppColors.violet400),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _DynamicBadge(
              suspended: suspended,
              streak: streak,
              targetReps: mantra.targetRepetitions,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dynamic badge ─────────────────────────────────────────────────────────────

class _DynamicBadge extends StatelessWidget {
  final Session? suspended;
  final int streak;
  final int targetReps;
  const _DynamicBadge({required this.suspended, required this.streak, required this.targetReps});

  @override
  Widget build(BuildContext context) {
    if (suspended != null) {
      // Ongoing state — mini progress ring
      final progress = targetReps > 0
          ? (suspended!.repsCompleted / targetReps).clamp(0.0, 1.0)
          : 0.0;
      return SizedBox(
        width: 44, height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 44, height: 44,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                backgroundColor: const Color(0x337C3AED),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.violet400),
              ),
            ),
            Text(
              '${suspended!.repsCompleted}',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.violet300),
            ),
          ],
        ),
      );
    }

    if (streak > 0) {
      // Streak state — weightlifting
      return Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: const Color(0x1AF97316),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x33F97316)),
        ),
        child: Center(
          child: Icon(Icons.fitness_center, size: 20, color: AppColors.orange),
        ),
      );
    }

    // Idle state — invite to practice
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: const Color(0x1A8B5CF6),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x338B5CF6)),
      ),
      child: Center(
        child: Icon(Icons.self_improvement, size: 22, color: AppColors.violet400),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: const Color(0x1A8B5CF6),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x338B5CF6)),
              ),
              child: Center(child: Icon(Icons.self_improvement, size: 28, color: AppColors.violet400)),
            ),
            const SizedBox(height: 16),
            Text(
              'No mantras to practice yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Select one from the Library or create your own.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.push('/mantras/new'),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Create'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/library'),
                  icon: const Icon(Icons.menu_book_outlined, size: 16),
                  label: const Text('Library'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.violet300,
                    side: const BorderSide(color: Color(0x338B5CF6)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

