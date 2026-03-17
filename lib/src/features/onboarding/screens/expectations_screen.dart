import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/launch_notifier.dart';

/// Expectations / onboarding intro (screen 1b).
/// Marks the app as launched when the user taps either CTA.
class ExpectationsScreen extends StatelessWidget {
  const ExpectationsScreen({super.key});

  Future<void> _finish(BuildContext context, String destination) async {
    await launchNotifier.markLaunched();
    if (!context.mounted) return;
    context.go(destination);
  }

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
              const SizedBox(height: 40),
              Text(
                'What to Expect',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 28),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Developing the habit of Practicing Mantra, one step at a time.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This app was made to help you improve your life through practicing the ancient traditions of Mantras.',
                        style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.6),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'You will be able to:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      ..._bullets.map((b) => _Bullet(text: b)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _finish(context, '/library'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.violet600,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Start with a mantra from our library',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _finish(context, '/mantras/new'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(color: AppColors.borderSubtle),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Create your own', style: TextStyle(fontSize: 15)),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

const _bullets = [
  'Practice traditional Mantras',
  'Get reminders on when to practice',
  'Count your practice at your own pace',
  'Create your personal mantras, goals and habits',
  'Get motivated, empowered, healthier and happier',
];

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6, height: 6,
              decoration: BoxDecoration(color: AppColors.violet400, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
