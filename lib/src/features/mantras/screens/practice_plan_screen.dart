import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/mantra.dart';
import '../../../core/providers/app_provider.dart';

enum PracticePlanMode { addFromLibrary, postCreate, edit }

/// Practice Plan (screen 3) — three contexts: addFromLibrary, postCreate, edit.
class PracticePlanScreen extends ConsumerStatefulWidget {
  final String mantraId;
  final PracticePlanMode mode;

  const PracticePlanScreen({
    super.key,
    required this.mantraId,
    this.mode = PracticePlanMode.addFromLibrary,
  });

  @override
  ConsumerState<PracticePlanScreen> createState() => _PracticePlanScreenState();
}

class _PracticePlanScreenState extends ConsumerState<PracticePlanScreen> {
  int? _selectedReps;
  RepetitionCycle? _selectedCycle;
  bool _userPickedReps = false;
  bool _userPickedCycle = false;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(appProvider.notifier);
    final mantra = notifier.getMantra(widget.mantraId);
    if (mantra == null) {
      return Scaffold(
        body: Center(
          child: Text('Mantra not found.',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final settings = ref.read(appProvider).settings;
    final reps = _selectedReps ?? mantra.targetRepetitions;
    final cycle = _selectedCycle ?? mantra.targetCycle;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.textSecondary, size: 20),
          onPressed: () => _handleBack(),
        ),
        title: Text(
          'Practice Plan',
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16, 8, 16, MediaQuery.of(context).padding.bottom + 100),
        children: [
          // ── Mantra details (read-only) ──────────────────────────────────
          const _SectionHeader('Mantra'),
          _Card(children: [
            _ReadOnlyField(
              label: 'Original text',
              value: mantra.text.split('\n').first,
              fontFamily: 'NotoSansDevanagari',
            ),
            if (mantra.transliteration != null) ...[
              _FieldDivider(),
              _ReadOnlyField(
                label: 'Transliteration',
                value: mantra.transliteration!,
              ),
            ],
            if (mantra.translation != null) ...[
              _FieldDivider(),
              _ReadOnlyField(
                label: 'Translation',
                value: mantra.translation!,
              ),
            ],
          ]),

          // ── Practice settings ───────────────────────────────────────────
          const _SectionHeader('Practice Settings'),
          _Card(children: [
            // Target reps
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.repeat, size: 18, color: AppColors.violet400),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Target repetitions',
                              style: TextStyle(
                                  fontSize: 14, color: AppColors.textPrimary)),
                          Text(
                            _repsSubtext(reps, settings.defaultRepetitions),
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '$reps',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.violet400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [27, 54, 108, 216].map((n) {
                      final selected = reps == n;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedReps = n;
                          _userPickedReps = true;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.violet600
                                : const Color(0x0A8B5CF6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppColors.violet600
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            '$n',
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            _FieldDivider(),

            // Cycle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.loop, size: 18, color: AppColors.violet400),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Count mode',
                              style: TextStyle(
                                  fontSize: 14, color: AppColors.textPrimary)),
                          Text(
                            _cycleSubtext(
                                cycle, settings.defaultRepetitionCycle),
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: RepetitionCycle.values.map((c) {
                      final selected = cycle == c;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedCycle = c;
                          _userPickedCycle = true;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.violet600
                                : const Color(0x0A8B5CF6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppColors.violet600
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            c.label,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            _FieldDivider(),

            // Practice mode
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.touch_app_outlined,
                          size: 18, color: AppColors.violet400),
                      const SizedBox(width: 12),
                      Text('Practice mode',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Wrap(
                    spacing: 8,
                    children: [
                      _ModeChip(label: 'Tap to count', available: true),
                      _ModeChip(label: 'Listen', available: false),
                      _ModeChip(label: 'AI listens', available: false),
                    ],
                  ),
                ],
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // ── Primary action ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handlePrimaryAction(reps, cycle),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.violet600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                _primaryLabel,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ),

          // ── Delete button (edit context only) ──────────────────────────
          if (widget.mode == PracticePlanMode.edit) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showDeleteOverlay(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[400],
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Delete Mantra',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String get _primaryLabel {
    switch (widget.mode) {
      case PracticePlanMode.addFromLibrary:
      case PracticePlanMode.postCreate:
        return 'Add to MyPractice';
      case PracticePlanMode.edit:
        return 'Save Changes';
    }
  }

  String _repsSubtext(int current, int defaultReps) {
    if (_userPickedReps) return '';
    if (current == defaultReps) return '(your default)';
    return '';
  }

  String _cycleSubtext(RepetitionCycle current, RepetitionCycle defaultCycle) {
    if (_userPickedCycle) return '';
    if (current == defaultCycle) return '(your default)';
    return '';
  }

  void _handleBack() {
    switch (widget.mode) {
      case PracticePlanMode.addFromLibrary:
      case PracticePlanMode.postCreate:
        context.go('/library');
      case PracticePlanMode.edit:
        context.pop();
    }
  }

  void _handlePrimaryAction(int reps, RepetitionCycle cycle) {
    final notifier = ref.read(appProvider.notifier);
    final mantra = notifier.getMantra(widget.mantraId);
    if (mantra == null) return;

    // Save settings changes
    if (reps != mantra.targetRepetitions || cycle != mantra.targetCycle) {
      notifier.updateMantra(
        widget.mantraId,
        title: mantra.title,
        text: mantra.text,
        transliteration: mantra.transliteration,
        translation: mantra.translation,
        targetRepetitions: reps,
        targetCycle: cycle,
        tradition: mantra.tradition,
      );
    }

    switch (widget.mode) {
      case PracticePlanMode.addFromLibrary:
      case PracticePlanMode.postCreate:
        context.go('/mypractice');
      case PracticePlanMode.edit:
        context.pop();
    }
  }

  void _showDeleteOverlay(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _DeleteMantraOverlay(
        onConfirm: () {
          ref.read(appProvider.notifier).deleteMantra(widget.mantraId);
          ctx.pop();
          context.go('/mypractice');
        },
        onCancel: () => ctx.pop(),
      ),
    );
  }
}

// ── Delete overlay (3b) ───────────────────────────────────────────────────────

class _DeleteMantraOverlay extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _DeleteMantraOverlay({
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: Icon(Icons.warning_amber_rounded,
          size: 48, color: Colors.red[400]),
      title: Text(
        'Are you sure?',
        style: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      ),
      content: Text(
        'This will remove the mantra and all its session history from your practice.',
        style: TextStyle(color: AppColors.textSecondary),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text('Cancel',
              style: TextStyle(color: AppColors.textMuted)),
        ),
        FilledButton(
          onPressed: onConfirm,
          style: FilledButton.styleFrom(backgroundColor: Colors.red[600]),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

// ── Mode chip ─────────────────────────────────────────────────────────────────

class _ModeChip extends StatelessWidget {
  final String label;
  final bool available;
  const _ModeChip({required this.label, required this.available});

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(available ? label : '$label (soon)'),
      isEnabled: available,
      selected: available,
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

// ── Shared layout widgets ─────────────────────────────────────────────────────

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

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

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

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final String? fontFamily;
  const _ReadOnlyField(
      {required this.label, required this.value, this.fontFamily});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 16, endIndent: 16,
        color: Color(0x1A8B5CF6));
  }
}
