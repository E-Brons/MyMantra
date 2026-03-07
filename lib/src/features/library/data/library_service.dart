import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'library_mantra.dart';

/// Loads and indexes the curated mantra library from
/// individual per-tradition JSON files in `assets/data/mantras/`.
///
/// Call [load] once (e.g. in a FutureProvider) and then use the synchronous
/// helpers for search and filtering.
class MantraLibraryService {
  MantraLibraryService._();
  static final MantraLibraryService instance = MantraLibraryService._();

  /// All per-tradition asset paths.
  static const _files = [
    'assets/data/mantras/hindu.json',
    'assets/data/mantras/buddhist.json',
    'assets/data/mantras/christian.json',
    'assets/data/mantras/islamic.json',
    'assets/data/mantras/jewish.json',
    'assets/data/mantras/taoist.json',
    'assets/data/mantras/sikh.json',
    'assets/data/mantras/jain.json',
    'assets/data/mantras/affirmations.json',
    'assets/data/mantras/growth_mindset.json',
  ];

  List<LibraryMantra>? _mantras;

  bool get isLoaded => _mantras != null;

  /// Loads all tradition files. Idempotent — subsequent calls return the cache.
  Future<List<LibraryMantra>> load() async {
    if (_mantras != null) return _mantras!;

    final all = <LibraryMantra>[];
    for (final path in _files) {
      final raw = await rootBundle.loadString(path);
      final list = json.decode(raw) as List;
      all.addAll(list.map((m) => LibraryMantra.fromJson(m as Map<String, dynamic>)));
    }

    _mantras = all;
    return _mantras!;
  }

  /// All mantras (throws if [load] has not been awaited yet).
  List<LibraryMantra> get all {
    assert(_mantras != null, 'MantraLibraryService.load() must be awaited first.');
    return _mantras!;
  }

  /// Tag name → emoji map (sourced from [kTagEmojis]).
  Map<String, String> get tagEmojis => kTagEmojis;

  /// Full-text + metadata search. All filters are optional.
  List<LibraryMantra> search({
    String query = '',
    List<String> tags = const [],
    String? tradition,
    String? category,
    String? difficulty,
  }) {
    final src = _mantras ?? [];
    final q = query.trim().toLowerCase();

    return src.where((m) {
      if (q.isNotEmpty) {
        final hit = m.name.toLowerCase().contains(q) ||
            m.english.toLowerCase().contains(q) ||
            m.transliteration.toLowerCase().contains(q) ||
            m.tradition.toLowerCase().contains(q) ||
            m.tags.any((t) => t.toLowerCase().contains(q));
        if (!hit) return false;
      }
      if (tags.isNotEmpty && !tags.any(m.tags.contains)) return false;
      if (tradition != null && m.tradition != tradition) return false;
      if (category != null && m.category != category) return false;
      if (difficulty != null && m.difficulty != difficulty) return false;
      return true;
    }).toList();
  }

  /// Returns a mantra by [id], or null if not found.
  LibraryMantra? byId(String id) =>
      _mantras?.where((m) => m.id == id).firstOrNull;

  /// Distinct traditions present in the library.
  List<String> get traditions =>
      (_mantras ?? []).map((m) => m.tradition).toSet().toList()..sort();

  /// Distinct categories present in the library.
  List<String> get categories =>
      (_mantras ?? []).map((m) => m.category).toSet().toList()..sort();

  /// All distinct tags, sorted alphabetically.
  List<String> get allTags {
    final set = <String>{};
    for (final m in _mantras ?? []) {
      set.addAll(m.tags);
    }
    return set.toList()..sort();
  }
}
