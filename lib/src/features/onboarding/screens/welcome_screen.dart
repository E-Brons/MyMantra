import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),

              // ── Logo ──────────────────────────────────────────────────────
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.violet500, AppColors.violet700],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.violet600.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2)],
                      ),
                      child: const Center(
                        child: Text(
                          'M',
                          style: TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'MyMantra',
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Philosophy quote ──────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'abhyāsa-vairāgya-ābhyāṃ tat-nirodhaḥ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'TiroSanskrit',
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'By practice and non-attachment the mind is still\n— Yoga Sutras 1.12',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Action buttons ────────────────────────────────────────────
              FilledButton(
                onPressed: () => context.push('/sign-in'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.violet600,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/expectations'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(color: AppColors.borderSubtle),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Continue Offline', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              Text(
                'You can always change this later in Settings',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
