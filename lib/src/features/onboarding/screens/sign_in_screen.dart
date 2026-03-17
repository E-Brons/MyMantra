import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';

/// Sign In (screen 1a) — OAuth stubs for Phase 2.0.
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textSecondary, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Sign In',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 48),

              // ── OAuth stubs ───────────────────────────────────────────────
              const _OAuthButton(
                icon: Icons.g_mobiledata,
                label: 'Continue with Google',
                onTap: null, // Phase 2.0
              ),
              const SizedBox(height: 12),
              const _OAuthButton(
                icon: Icons.apple,
                label: 'Continue with Apple',
                onTap: null, // Phase 2.0
              ),
              const SizedBox(height: 12),
              const _OAuthButton(
                icon: Icons.email_outlined,
                label: 'Sign in with Email',
                onTap: null, // Phase 2.0
              ),

              const Spacer(),
              Text(
                'Sign-in with third-party accounts is coming soon.',
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

class _OAuthButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _OAuthButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 22),
      label: Text(label, style: const TextStyle(fontSize: 15)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: BorderSide(color: AppColors.borderSubtle),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
