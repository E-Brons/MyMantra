import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';

/// User Feedback screen (screen 6b).
/// Opens an email compose intent via a copied mailto: link (no url_launcher needed).
class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  void _sendFeedback(BuildContext context, String category) {
    const email = 'support@mymantra.app';
    final subject = Uri.encodeComponent('[MyMantra] $category');
    final body = Uri.encodeComponent(
      'App: MyMantra\n'
      'Version: 1.0.0\n'
      '---\n'
      'Describe your feedback here:\n',
    );
    final mailto = 'mailto:$email?subject=$subject&body=$body';
    Clipboard.setData(ClipboardData(text: mailto));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Email link copied to clipboard — paste it in your mail app'),
        backgroundColor: AppColors.bgSurface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
        title: Text(
          'Feedback',
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          Text(
            'Help us improve MyMantra',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ..._categories.map((cat) => _FeedbackTile(
            icon: cat.icon,
            label: cat.label,
            description: cat.description,
            onTap: () => _sendFeedback(context, cat.label),
          )),
        ],
      ),
    );
  }
}

const _categories = [
  (icon: Icons.bug_report_outlined,   label: 'Bug Report',             description: 'Something is broken'),
  (icon: Icons.lightbulb_outlined,    label: 'Feature Request',        description: 'Suggest a new feature or improvement'),
  (icon: Icons.auto_stories_outlined, label: 'Mantra Info Request',    description: 'Request a correction or addition to library content'),
  (icon: Icons.chat_bubble_outline,   label: 'General Feedback',       description: 'Anything else'),
];

class _FeedbackTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _FeedbackTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x0A8B5CF6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(
                  color: Color(0x1A8B5CF6),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Icon(icon, size: 22, color: AppColors.violet400)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                    )),
                    const SizedBox(height: 2),
                    Text(description, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
