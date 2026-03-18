import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/mantra.dart';
import '../../../core/providers/app_provider.dart';

class CreateMantraScreen extends ConsumerStatefulWidget {
  final String? editId;
  const CreateMantraScreen({super.key, this.editId});

  @override
  ConsumerState<CreateMantraScreen> createState() => _CreateMantraScreenState();
}

class _CreateMantraScreenState extends ConsumerState<CreateMantraScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _textCtrl = TextEditingController();
  final _translCtrl = TextEditingController();
  final _translationCtrl = TextEditingController();
  final _traditionCtrl = TextEditingController();

  bool get _isEditing => widget.editId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final mantra = ref.read(appProvider.notifier).getMantra(widget.editId!);
      if (mantra != null) {
        _titleCtrl.text = mantra.title;
        _textCtrl.text = mantra.text;
        _translCtrl.text = mantra.transliteration ?? '';
        _translationCtrl.text = mantra.translation ?? '';
        _traditionCtrl.text = mantra.tradition ?? '';
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _textCtrl.dispose();
    _translCtrl.dispose();
    _translationCtrl.dispose();
    _traditionCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(appProvider.notifier);
    if (_isEditing) {
      final existing = notifier.getMantra(widget.editId!);
      notifier.updateMantra(
        widget.editId!,
        title: _titleCtrl.text.trim(),
        text: _textCtrl.text.trim(),
        transliteration: _translCtrl.text.trim().isEmpty ? null : _translCtrl.text.trim(),
        translation: _translationCtrl.text.trim().isEmpty ? null : _translationCtrl.text.trim(),
        targetRepetitions: existing?.targetRepetitions ?? 108,
        targetCycle: existing?.targetCycle ?? RepetitionCycle.session,
        tradition: _traditionCtrl.text.trim().isEmpty ? null : _traditionCtrl.text.trim(),
      );
      context.pop();
    } else {
      final settings = ref.read(appProvider).settings;
      final mantra = notifier.createMantra(
        title: _titleCtrl.text.trim(),
        text: _textCtrl.text.trim(),
        transliteration: _translCtrl.text.trim().isEmpty ? null : _translCtrl.text.trim(),
        translation: _translationCtrl.text.trim().isEmpty ? null : _translationCtrl.text.trim(),
        targetRepetitions: settings.defaultRepetitions,
        targetCycle: settings.defaultRepetitionCycle,
        tradition: _traditionCtrl.text.trim().isEmpty ? null : _traditionCtrl.text.trim(),
      );
      context.push('/mantras/${mantra.id}/plan?mode=postCreate');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Mantra' : 'New Mantra'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _isEditing
              ? (context.canPop() ? context.pop() : context.go('/'))
              : context.go('/library'),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('Save', style: TextStyle(color: AppColors.violet400, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 40),
          children: [
            const _FieldLabel('Title *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'e.g. Om Namah Shivaya'),
              validator: (v) => (v?.trim().isEmpty ?? true) ? 'Title is required' : null,
            ),

            const SizedBox(height: 20),
            const _FieldLabel('Mantra text *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _textCtrl,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'NotoSansDevanagari',
                fontSize: 18,
              ),
              decoration: const InputDecoration(hintText: 'Sanskrit, Hebrew, or any script'),
              maxLines: 3,
              validator: (v) => (v?.trim().isEmpty ?? true) ? 'Mantra text is required' : null,
            ),

            const SizedBox(height: 20),
            const _FieldLabel('Transliteration (optional)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _translCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'e.g. oṃ namaḥ śivāya'),
            ),

            const SizedBox(height: 20),
            const _FieldLabel('Translation (optional)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _translationCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'English meaning'),
              maxLines: 2,
            ),

            const SizedBox(height: 20),
            const _FieldLabel('Tradition (optional)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _traditionCtrl,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'e.g. Shaivism, Tibetan Buddhism'),
            ),

            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violet600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _isEditing ? 'Save Changes' : 'Create Mantra',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 13, color: AppColors.textMuted));
  }
}
