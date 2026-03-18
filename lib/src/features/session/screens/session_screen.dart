import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/icon_registry.dart';
import '../../../core/models/achievement.dart';
import '../../../core/models/mantra.dart';
import '../../../core/models/progress.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/services/haptic_service.dart';

class SessionScreen extends ConsumerStatefulWidget {
  final String id;
  final bool resume;
  const SessionScreen({super.key, required this.id, this.resume = false});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen>
    with TickerProviderStateMixin {
  int _count = 0;
  bool _isComplete = false;
  int _duration = 0;
  List<UnlockedAchievement> _newAchievements = [];
  bool _showCelebration = false;

  // Target — initialized from mantra's practice plan in initState
  int _sessionTarget = 108;
  RepetitionCycle _sessionCycle = RepetitionCycle.session;
  int _alreadyDone = 0;

  // Tap rate limiter — last accepted tap timestamp
  DateTime? _lastTapTime;

  // Reps still needed from this session to reach the target.
  // For daily/weekly cycles this factors in reps already done earlier today/this week.
  int get _remaining {
    if (_sessionCycle == RepetitionCycle.session) return _sessionTarget;
    if (_alreadyDone >= _sessionTarget) {
      return _sessionTarget; // goal met → free bonus set
    }
    return _sessionTarget - _alreadyDone;
  }

  // Sub-text shown beneath the counter number.
  String get _targetSubtext {
    if (_sessionCycle == RepetitionCycle.session) return 'of $_sessionTarget';
    final period =
        _sessionCycle == RepetitionCycle.daily ? 'today' : 'this week';
    if (_alreadyDone >= _sessionTarget) return 'goal met · free practice';
    if (_alreadyDone > 0) {
      return '${_sessionTarget - _alreadyDone} more $period';
    }
    return 'of $_sessionTarget $period';
  }

  late final DateTime _startTime;
  Timer? _timer;

  // Ripple animation
  late final AnimationController _rippleCtrl;
  late final Animation<double> _rippleRadius;
  late final Animation<double> _rippleOpacity;
  Offset _ripplePos = Offset.zero;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    // Initialize target from mantra's practice plan
    final notifier = ref.read(appProvider.notifier);
    final mantra = notifier.getMantra(widget.id);
    if (mantra != null) {
      _sessionTarget = mantra.targetRepetitions;
      _sessionCycle = mantra.targetCycle;
      _alreadyDone = notifier.getAccumulatedReps(widget.id, mantra.targetCycle);
    }

    // Restore progress when resuming a suspended session
    if (widget.resume) {
      final suspended = notifier.suspendedSessionFor(widget.id);
      if (suspended != null) {
        _count = suspended.repsCompleted;
        _duration = suspended.duration;
      }
    }

    _startTimer();

    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _rippleRadius = Tween<double>(begin: 0, end: 150).animate(
      CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut),
    );
    _rippleOpacity = Tween<double>(begin: 0.5, end: 0).animate(
      CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isComplete) {
        setState(() => _duration++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rippleCtrl.dispose();
    super.dispose();
  }

  void _handleTap(TapDownDetails details) {
    if (_isComplete) return;

    // Tap rate limiter: drop taps within 1 second of the last accepted tap.
    final settings = ref.read(appProvider).settings;
    if (settings.limitClickRate) {
      final now = DateTime.now();
      if (_lastTapTime != null &&
          now.difference(_lastTapTime!) < const Duration(seconds: 1)) {
        return;
      }
      _lastTapTime = now;
    }

    final pos = details.localPosition;
    setState(() {
      _ripplePos = pos;
    });
    _rippleCtrl.forward(from: 0);

    if (ref.read(appProvider).settings.vibrationEnabled) {
      HapticService.instance.light();
    }

    setState(() {
      _count++;
      if (_count >= _remaining) {
        _isComplete = true;
        Future.delayed(const Duration(milliseconds: 300),
            () => _finishSession(_count, true));
      }
    });
  }

  void _finishSession(int finalCount, bool completed) {
    final mantra = ref.read(appProvider.notifier).getMantra(widget.id);
    if (mantra == null) return;
    final unlocked = ref.read(appProvider.notifier).completeSession(
          mantraId: mantra.id,
          mantraTitle: mantra.title,
          repsCompleted: finalCount,
          targetReps: _sessionTarget,
          targetCycle: _sessionCycle,
          duration: _duration,
          startTime: _startTime,
          completed: completed,
        );
    setState(() {
      _newAchievements = unlocked;
      _showCelebration = true;
    });
  }

  void _handleExit() {
    // Per spec: Back always suspends — no discard option.
    // If no reps counted yet, just navigate back without creating a session.
    if (_count > 0) {
      final mantra = ref.read(appProvider.notifier).getMantra(widget.id);
      if (mantra != null) {
        ref.read(appProvider.notifier).suspendSession(
              mantraId: mantra.id,
              mantraTitle: mantra.title,
              repsCompleted: _count,
              targetReps: _sessionTarget,
              targetCycle: _sessionCycle,
              duration: _duration,
              startTime: _startTime,
            );
      }
    }
    context.go('/mypractice');
  }

  void _reset() {
    setState(() {
      _count = 0;
      _isComplete = false;
      _duration = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mantra = ref.read(appProvider.notifier).getMantra(widget.id);
    if (mantra == null) {
      return Scaffold(
        body: Center(
            child: Text('Mantra not found.',
                style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    final progress =
        _sessionTarget > 0 ? (_count / _remaining).clamp(0.0, 1.0) : 0.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (_showCelebration) {
            context.pop();
          } else {
            _handleExit();
          }
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: const Color(0xFF0D0520),
          body: Stack(
            children: [
              // ── Main session UI ─────────────────────────────────────────
              Column(
                children: [
                  // Top bar
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _CircleButton(
                            onTap: _handleExit,
                            child: const Icon(Icons.arrow_back_ios_new,
                                size: 16, color: Colors.white70),
                          ),
                          Text(
                            mantra.title,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white38),
                            overflow: TextOverflow.ellipsis,
                          ),
                          _CircleButton(
                            onTap: () =>
                                context.push('/mantras/${widget.id}/plan/edit'),
                            child: const Icon(Icons.edit_outlined,
                                size: 16, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Mantra text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          mantra.text.split('\n').first,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'NotoSansDevanagari',
                            fontSize: 20,
                            color: Color(0xE6FFFFFF),
                            shadows: [
                              Shadow(color: Color(0x668B5CF6), blurRadius: 20)
                            ],
                          ),
                        ),
                        if (mantra.translation != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              mantra.translation!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.white38),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Tap area with progress ring
                  Expanded(
                    child: GestureDetector(
                      onTapDown: _handleTap,
                      behavior: HitTestBehavior.opaque,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ripple effect
                          AnimatedBuilder(
                            animation: _rippleCtrl,
                            builder: (_, __) {
                              if (_rippleCtrl.value == 0 ||
                                  _rippleCtrl.value == 1) {
                                return const SizedBox.shrink();
                              }
                              return Positioned(
                                left: _ripplePos.dx - _rippleRadius.value,
                                top: _ripplePos.dy - _rippleRadius.value,
                                child: Opacity(
                                  opacity: _rippleOpacity.value,
                                  child: Container(
                                    width: _rippleRadius.value * 2,
                                    height: _rippleRadius.value * 2,
                                    decoration: BoxDecoration(
                                      color: AppColors.violet500,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Progress ring + counter
                          CustomPaint(
                            size: const Size(220, 220),
                            painter: _RingPainter(progress: progress),
                            child: SizedBox(
                              width: 220,
                              height: 220,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 120),
                                    transitionBuilder: (child, anim) =>
                                        ScaleTransition(
                                      scale: Tween<double>(begin: 1.2, end: 1.0)
                                          .animate(anim),
                                      child: FadeTransition(
                                          opacity: anim, child: child),
                                    ),
                                    child: Text(
                                      '$_count',
                                      key: ValueKey(_count),
                                      style: const TextStyle(
                                        fontSize: 72,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                              color: Color(0x998B5CF6),
                                              blurRadius: 30)
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _targetSubtext,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white38),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Pause overlay removed — no pause per spec
                        ],
                      ),
                    ),
                  ),

                  // Bottom controls
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _BottomAction(
                            icon: Icons.refresh,
                            label: 'Reset',
                            onTap: _reset,
                          ),
                          Column(
                            children: [
                              const Text('Tap anywhere to count',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white30)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children:
                                    List.generate(min(_remaining, 20), (i) {
                                  final filled = i <
                                      ((_count / _remaining) *
                                              min(_remaining, 20))
                                          .round();
                                  return Container(
                                    width: 4,
                                    height: 4,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 1),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: filled
                                          ? AppColors.violet600
                                          : Colors.white12,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                          _BottomAction(
                            icon: Icons.check,
                            label: 'Done',
                            accentColor: AppColors.violet600,
                            onTap: () {
                              setState(() => _isComplete = true);
                              _finishSession(_count, _count >= _remaining);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ── Celebration overlay ─────────────────────────────────────
              if (_showCelebration)
                _CelebrationOverlay(
                  count: _count,
                  newAchievements: _newAchievements,
                  onDone: () => context.go('/mypractice'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Progress ring painter ────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;
    const strokeWidth = 10.0;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0x1F8B5CF6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    if (progress > 0) {
      final sweepAngle = 2 * pi * progress;
      final rect = Rect.fromCircle(center: center, radius: radius);
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [AppColors.violet600, AppColors.violet400],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -pi / 2, sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _CircleButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0x14FFFFFF),
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? accentColor;

  const _BottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color != null
                  ? color.withValues(alpha: 0.2)
                  : const Color(0x12FFFFFF),
              shape: BoxShape.circle,
              border: color != null
                  ? Border.all(color: color.withValues(alpha: 0.5))
                  : null,
            ),
            child: Icon(icon, size: 20, color: color ?? Colors.white60),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.white38)),
        ],
      ),
    );
  }
}
// ─── Celebration overlay ──────────────────────────────────────────────────────

class _CelebrationOverlay extends StatefulWidget {
  final int count;
  final List<UnlockedAchievement> newAchievements;
  final VoidCallback onDone;

  const _CelebrationOverlay({
    required this.count,
    required this.newAchievements,
    required this.onDone,
  });

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.5)),
    );
    _ctrl.forward();
    // Auto-dismiss after 4 seconds
    _autoDismissTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievementDefs = widget.newAchievements
        .map((ua) {
          try {
            return kAchievements.firstWhere((a) => a.id == ua.id);
          } catch (_) {
            return null;
          }
        })
        .whereType<Achievement>()
        .toList();

    return GestureDetector(
      onTap: widget.onDone, // tap-anywhere to dismiss
      child: Container(
        color: const Color(0xFF0D0520),
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      IconRegistry.instance.icon('Other', 'Session complete') ??
                          Icons.thumb_up,
                      size: 72,
                      color: AppColors.violet400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Session Complete',
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.count} repetitions',
                      style:
                          TextStyle(fontSize: 16, color: AppColors.violet300),
                    ),
                    if (achievementDefs.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Achievement${achievementDefs.length > 1 ? 's' : ''} Unlocked!',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.amber),
                      ),
                      const SizedBox(height: 12),
                      ...achievementDefs.map((ach) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0x1AF59E0B),
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: const Color(0x4DF59E0B)),
                            ),
                            child: Row(
                              children: [
                                Icon(ach.icon,
                                    size: 28, color: const Color(0xFFFBBF24)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(ach.title,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFFBBF24))),
                                      Text(ach.description,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0x99F59E0B))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                    const SizedBox(height: 32),
                    const Text(
                      'Tap anywhere to continue',
                      style: TextStyle(fontSize: 13, color: Colors.white38),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
