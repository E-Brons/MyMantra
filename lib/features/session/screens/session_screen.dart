import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/models/achievement.dart';
import '../../core/models/progress.dart';
import '../../core/providers/app_provider.dart';
import '../../core/services/haptic_service.dart';
import '../../core/utils/date_utils.dart';

class SessionScreen extends ConsumerStatefulWidget {
  final String id;
  const SessionScreen({super.key, required this.id});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen>
    with TickerProviderStateMixin {
  int _count = 0;
  bool _isPaused = false;
  bool _isComplete = false;
  int _duration = 0;
  bool _showConfirmExit = false;
  List<UnlockedAchievement> _newAchievements = [];
  bool _showCelebration = false;

  late final DateTime _startTime;
  Timer? _timer;

  // Ripple animation
  late final AnimationController _rippleCtrl;
  late final Animation<double> _rippleRadius;
  late final Animation<double> _rippleOpacity;
  Offset _ripplePos = Offset.zero;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
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
      if (!_isPaused && !_isComplete) {
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
    if (_isPaused || _isComplete) return;

    final pos = details.localPosition;
    setState(() {
      _ripplePos = pos;
      _tapCount++;
    });
    _rippleCtrl.forward(from: 0);

    if (ref.read(appProvider).settings.vibrationEnabled) {
      HapticService.instance.light();
    }

    setState(() {
      _count++;
      final mantra = ref.read(appProvider.notifier).getMantra(widget.id);
      final target = mantra?.targetRepetitions ?? 108;
      if (_count >= target) {
        _isComplete = true;
        Future.delayed(const Duration(milliseconds: 300), () => _finishSession(_count, true));
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
      targetReps: mantra.targetRepetitions,
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
    if (_count > 0) {
      setState(() => _showConfirmExit = true);
    } else {
      context.pop();
    }
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
      return const Scaffold(
        body: Center(child: Text('Mantra not found.', style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    final target = mantra.targetRepetitions;
    final progress = (_count / target).clamp(0.0, 1.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CircleButton(
                          onTap: _handleExit,
                          child: const Icon(Icons.close, size: 18, color: Colors.white70),
                        ),
                        Column(
                          children: [
                            Text(
                              mantra.title,
                              style: const TextStyle(fontSize: 12, color: Colors.white38),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              formatTime(_duration),
                              style: const TextStyle(fontSize: 11, color: Colors.white24),
                            ),
                          ],
                        ),
                        _CircleButton(
                          onTap: () => setState(() => _isPaused = !_isPaused),
                          child: Icon(
                            _isPaused ? Icons.play_arrow : Icons.pause,
                            size: 18,
                            color: Colors.white70,
                          ),
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
                          color: Colors.white90,
                          shadows: [Shadow(color: Color(0x668B5CF6), blurRadius: 20)],
                        ),
                      ),
                      if (mantra.translation != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            mantra.translation!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: Colors.white38),
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
                            if (_rippleCtrl.value == 0 || _rippleCtrl.value == 1) {
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
                                  transitionBuilder: (child, anim) => ScaleTransition(
                                    scale: Tween<double>(begin: 1.2, end: 1.0).animate(anim),
                                    child: FadeTransition(opacity: anim, child: child),
                                  ),
                                  child: Text(
                                    '$_count',
                                    key: ValueKey(_count),
                                    style: const TextStyle(
                                      fontSize: 72,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      shadows: [Shadow(color: Color(0x998B5CF6), blurRadius: 30)],
                                    ),
                                  ),
                                ),
                                Text(
                                  'of $target',
                                  style: const TextStyle(fontSize: 14, color: Colors.white38),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Pause overlay
                        if (_isPaused)
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: const Color(0xB20D0B1A),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.pause_circle_outline, size: 48, color: Colors.white38),
                                SizedBox(height: 12),
                                Text('Paused', style: TextStyle(fontSize: 16, color: Colors.white60)),
                                Text('Tap pause button to resume',
                                    style: TextStyle(fontSize: 13, color: Colors.white30)),
                              ],
                            ),
                          ),
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
                                style: TextStyle(fontSize: 12, color: Colors.white30)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(min(target, 20), (i) {
                                final filled = i < ((_count / target) * min(target, 20)).round();
                                return Container(
                                  width: 4, height: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
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
                            _finishSession(_count, _count >= target);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Exit confirm sheet ──────────────────────────────────────
            if (_showConfirmExit)
              _ExitSheet(
                count: _count,
                onSave: () {
                  setState(() => _showConfirmExit = false);
                  _finishSession(_count, false);
                },
                onDiscard: () {
                  setState(() => _showConfirmExit = false);
                  context.pop();
                },
                onContinue: () => setState(() => _showConfirmExit = false),
              ),

            // ── Celebration overlay ─────────────────────────────────────
            if (_showCelebration)
              _CelebrationOverlay(
                count: _count,
                duration: _duration,
                newAchievements: _newAchievements,
                onDone: () => context.pop(),
              ),
          ],
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
        ..shader = const LinearGradient(
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
        width: 40, height: 40,
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
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color != null
                  ? color.withValues(alpha: 0.2)
                  : const Color(0x12FFFFFF),
              shape: BoxShape.circle,
              border: color != null
                  ? Border.all(color: color.withValues(alpha: 0.5))
                  : null,
            ),
            child: Icon(icon, size: 20,
                color: color != null ? color : Colors.white60),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.white38)),
        ],
      ),
    );
  }
}

// ─── Exit confirm sheet ───────────────────────────────────────────────────────

class _ExitSheet extends StatelessWidget {
  final int count;
  final VoidCallback onSave;
  final VoidCallback onDiscard;
  final VoidCallback onContinue;

  const _ExitSheet({
    required this.count,
    required this.onSave,
    required this.onDiscard,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black70,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
          decoration: const BoxDecoration(
            color: Color(0xFF0D0B1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Exit Session?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text('You have $count repetitions. Save as partial session?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              _SheetButton(
                label: 'Save & Exit',
                color: const Color(0x4D8B5CF6),
                borderColor: AppColors.border,
                textColor: AppColors.textPrimary,
                onTap: onSave,
              ),
              const SizedBox(height: 10),
              _SheetButton(
                label: 'Discard & Exit',
                color: Colors.transparent,
                borderColor: const Color(0x33EF4444),
                textColor: AppColors.red,
                onTap: onDiscard,
              ),
              const SizedBox(height: 10),
              _SheetButton(
                label: 'Continue Session',
                color: Colors.transparent,
                borderColor: Colors.transparent,
                textColor: Colors.white60,
                onTap: onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  const _SheetButton({
    required this.label,
    required this.color,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(label, style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}

// ─── Celebration overlay ──────────────────────────────────────────────────────

class _CelebrationOverlay extends StatefulWidget {
  final int count;
  final int duration;
  final List<UnlockedAchievement> newAchievements;
  final VoidCallback onDone;

  const _CelebrationOverlay({
    required this.count,
    required this.duration,
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

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.5)),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
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

    return Container(
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
                  const Text('🙏', style: TextStyle(fontSize: 72)),
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
                    '${widget.count} repetitions · ${formatTime(widget.duration)}',
                    style: const TextStyle(fontSize: 16, color: AppColors.violet300),
                  ),
                  if (achievementDefs.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Achievement${achievementDefs.length > 1 ? 's' : ''} Unlocked!',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.amber),
                    ),
                    const SizedBox(height: 12),
                    ...achievementDefs.map((ach) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0x1AF59E0B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0x4DF59E0B)),
                          ),
                          child: Row(
                            children: [
                              Text(ach.emoji, style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ach.title,
                                        style: const TextStyle(
                                            fontSize: 15, fontWeight: FontWeight.w600,
                                            color: Color(0xFFFBBF24))),
                                    Text(ach.description,
                                        style: const TextStyle(fontSize: 12, color: Color(0x99F59E0B))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onDone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.violet600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Continue',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
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
