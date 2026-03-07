import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/mantra.dart';
import '../../../core/providers/app_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final filtered = _query.isEmpty
        ? state.mantras
        : state.mantras.where((m) {
            final q = _query.toLowerCase();
            return m.title.toLowerCase().contains(q) ||
                m.text.toLowerCase().contains(q) ||
                (m.translation?.toLowerCase().contains(q) ?? false);
          }).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x1F7C3AED), Colors.transparent],
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20, right: 20, bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MyMantra',
                            style: TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Your daily practice',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (state.progress.currentStreak > 0)
                        _StreakBadge(streak: state.progress.currentStreak),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0x147C3AED),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x267C3AED)),
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search mantras...',
                        prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                                onPressed: () => setState(() => _query = ''),
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Mantra list ────────────────────────────────────────────────────
          if (filtered.isEmpty)
            SliverFillRemaining(
              child: _EmptyState(
                hasQuery: _query.isNotEmpty,
                query: _query,
                onClear: () => setState(() => _query = ''),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _MantraCard(
                  mantra: filtered[i],
                  lastSession: ref
                      .read(appProvider.notifier)
                      .getRecentSessions(mantraId: filtered[i].id, limit: 1)
                      .firstOrNull,
                  onTap: () => context.push('/mantras/${filtered[i].id}'),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/mantras/new'),
        backgroundColor: AppColors.violet600,
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;
  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x33F97316), Color(0x1AF97316)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x4DF97316)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, size: 16, color: Color(0xFFFB923C)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: const TextStyle(
              color: Color(0xFFFDA974),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            streak == 1 ? 'day' : 'days',
            style: const TextStyle(color: Color(0x99F97316), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _MantraCard extends StatelessWidget {
  final Mantra mantra;
  final dynamic lastSession;
  final VoidCallback onTap;

  const _MantraCard({
    required this.mantra,
    required this.lastSession,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x147C3AED), Color(0x661E1B4B)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x337C3AED)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mantra.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mantra.text.split('\n').first,
                    style: const TextStyle(
                      fontFamily: 'NotoSansDevanagari',
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (mantra.translation != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      mantra.translation!,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (mantra.reminders.isNotEmpty) ...[
                        const Icon(Icons.notifications_outlined, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Text(
                          '${mantra.reminders.length} reminder${mantra.reminders.length != 1 ? 's' : ''}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (mantra.tradition != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0x1A8B5CF6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            mantra.tradition!,
                            style: const TextStyle(fontSize: 11, color: AppColors.violet400),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x337C3AED),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${mantra.targetRepetitions}×',
                style: const TextStyle(fontSize: 12, color: AppColors.violet300),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasQuery;
  final String query;
  final VoidCallback onClear;

  const _EmptyState({
    required this.hasQuery,
    required this.query,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (hasQuery) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No mantras found for "$query"',
              style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onClear,
              child: const Text('Clear search', style: TextStyle(color: AppColors.violet400)),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0x1A8B5CF6),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x338B5CF6)),
              ),
              child: const Center(child: Text('🙏', style: TextStyle(fontSize: 28))),
            ),
            const SizedBox(height: 16),
            const Text(
              'Start your journey',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first mantra or explore the library',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.push('/mantras/new'),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Create'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/library'),
                  icon: const Icon(Icons.menu_book_outlined, size: 16),
                  label: const Text('Library'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.violet300,
                    side: const BorderSide(color: Color(0x338B5CF6)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
