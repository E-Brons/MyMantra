import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: Stack(
        children: [
          // ── Radial glow ─────────────────────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.25),
                  radius: 0.75,
                  colors: [
                    AppColors.violet700.withValues(alpha: 0.28),
                    AppColors.bgBase.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 3),

                  // ── Logo mark ───────────────────────────────────────────
                  Center(
                    child: _LogoMark(),
                  ),
                  const SizedBox(height: 22),

                  // ── App name ────────────────────────────────────────────
                  Text(
                    'MyMantra',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Practice. No attachment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Sanskrit quote ──────────────────────────────────────
                  _QuoteBlock(),

                  const Spacer(flex: 3),

                  // ── CTA buttons (equal weight) ──────────────────────────
                  OutlinedButton(
                    onPressed: () => context.push('/sign-in'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.violet300,
                      side: BorderSide(color: AppColors.violet500, width: 1.5),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Sign In',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => context.go('/mypractice'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.borderSubtle),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Continue Offline',
                        style: TextStyle(fontSize: 15)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You can always sign in later in Settings',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Layered logo mark ─────────────────────────────────────────────────────────

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const size = 112.0;
    const dotSize = 4.0;
    const center = size / 2;
    const r = 45.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer halo
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.violet600.withValues(alpha: 0.12), width: 1),
              color: AppColors.violet700.withValues(alpha: 0.06),
            ),
          ),
          // Mid ring
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.violet500.withValues(alpha: 0.22), width: 1),
              color: AppColors.violet700.withValues(alpha: 0.10),
            ),
          ),
          // Cardinal petal dots
          for (final pos in [
            const Offset(center - dotSize / 2, center - r - dotSize / 2), // top
            const Offset(center + r - dotSize / 2, center - dotSize / 2), // right
            const Offset(center - dotSize / 2, center + r - dotSize / 2), // bottom
            const Offset(center - r - dotSize / 2, center - dotSize / 2), // left
          ])
            Positioned(
              left: pos.dx,
              top: pos.dy,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.violet400.withValues(alpha: 0.5),
                ),
              ),
            ),
          // Core
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.violet400, AppColors.violet700],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.violet600.withValues(alpha: 0.55),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'M',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sanskrit quote ────────────────────────────────────────────────────────────

class _QuoteBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Decorative line
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.borderSubtle, thickness: 0.5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.violet500.withValues(alpha: 0.6),
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.borderSubtle, thickness: 0.5)),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'abhyāsa-vairāgya-ābhyāṃ tat-nirodhaḥ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'TiroSanskrit',
            fontSize: 15,
            fontStyle: FontStyle.italic,
            color: AppColors.violet300,
            height: 1.6,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'By practice and non-attachment, the mind is still',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '— Yoga Sutras 1.12',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textMuted.withValues(alpha: 0.6),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.borderSubtle, thickness: 0.5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.violet500.withValues(alpha: 0.6),
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.borderSubtle, thickness: 0.5)),
          ],
        ),
      ],
    );
  }
}

