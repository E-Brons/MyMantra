import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/providers/app_provider.dart';
import '../data/built_in_mantras.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _selectedCategory = 'all';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = kBuiltInMantras.where((m) {
      final matchesCategory =
          _selectedCategory == 'all' || m.category == _selectedCategory;
      final matchesQuery = _query.isEmpty ||
          m.title.toLowerCase().contains(_query.toLowerCase()) ||
          m.shortTitle.toLowerCase().contains(_query.toLowerCase()) ||
          m.tradition.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20, right: 20, bottom: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mantra Library',
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sacred texts across traditions',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  // Search
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0x147C3AED),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0x267C3AED)),
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search library...',
                        prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textMuted),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Category chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: kCategories.map((cat) {
                        final selected = _selectedCategory == cat['id'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat['id']!),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.violet600 : const Color(0x0A8B5CF6),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected ? AppColors.violet600 : AppColors.border,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(cat['emoji']!, style: const TextStyle(fontSize: 13)),
                                const SizedBox(width: 6),
                                Text(
                                  cat['label']!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: selected ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Library list ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _LibraryCard(mantra: filtered[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryCard extends ConsumerWidget {
  final BuiltInMantra mantra;
  const _LibraryCard({required this.mantra});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: mantra.isSignature
              ? [const Color(0x267C3AED), const Color(0x402E1065)]
              : [const Color(0x147C3AED), const Color(0x331E1B4B)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mantra.isSignature
              ? const Color(0x667C3AED)
              : const Color(0x337C3AED),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (mantra.isSignature)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0x338B5CF6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('★ Signature',
                            style: TextStyle(fontSize: 11, color: AppColors.violet300)),
                      ),
                    Text(
                      mantra.shortTitle,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mantra.source,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0x1A8B5CF6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  mantra.difficulty,
                  style: const TextStyle(fontSize: 11, color: AppColors.violet400),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            mantra.primaryText.split('\n').first,
            style: const TextStyle(
              fontFamily: 'NotoSansDevanagari',
              fontSize: 18,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          if (mantra.englishTranslation != null) ...[
            const SizedBox(height: 4),
            Text(
              mantra.englishTranslation!,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  children: mantra.tags.take(3).map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x0A8B5CF6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('#$tag', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  )).toList(),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(appProvider.notifier).createMantra(
                    title: mantra.shortTitle,
                    text: mantra.primaryText,
                    transliteration: mantra.transliteration,
                    translation: mantra.englishTranslation,
                    targetRepetitions: mantra.targetRepetitions,
                    tradition: mantra.tradition,
                  );
                  context.go('/');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${mantra.shortTitle} added to your practice'),
                      backgroundColor: AppColors.bgSurface,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violet600,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add', style: TextStyle(fontSize: 13, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
