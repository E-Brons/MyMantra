import '../../../core/models/mantra.dart';

/// Tag names → display emoji. Used by UI to render tag chips.
const Map<String, String> kTagEmojis = {
  'vedic': '🕉️',
  'spiritual': '✨',
  'nature': '🌿',
  'health': '💚',
  'mental': '🧠',
  'hindu': '🪔',
  'buddhist': '☸️',
  'researched': '📚',
  'popular': '⭐',
  'inspiring': '💫',
  'peaceful': '☮️',
  'healing': '🌟',
  'love': '❤️',
  'protection': '🛡️',
  'abundance': '🌸',
  'wisdom': '🦉',
  'devotion': '🙏',
  'meditation': '🧘',
  'gratitude': '🙌',
  'courage': '🦁',
  'hebrew': '🕎',
  'chinese': '🐉',
  'tibetan': '🏔️',
  'sufi': '🌙',
  'universal': '🌍',
  'transformative': '🔥',
  'flow': '🌊',
  'energy': '⚡',
  'beauty': '🌺',
  'growth': '🌱',
  'sound': '🎵',
  'joy': '🌈',
  'purity': '🤍',
  'awareness': '👁️',
  'kabbalistic': '✡️',
  'taoist': '☯️',
  'christian': '✝️',
  'jain': '🌀',
  'sikh': '🪯',
  'zoroastrian': '🔆',
  'indigenous': '🌎',
  'affirmation': '💭',
  'ancient': '📜',
  'yoga': '🧘',
  'prayer': '🙏',
  'chant': '🎶',
  'scripture': '📖',
  'philosophy': '🔮',
  'upanishadic': '📿',
  'ganesha': '🐘',
  'shiva': '🔱',
  'vishnu': '🪷',
  'shakti': '🌺',
  'islamic': '☪️',
  'sikh_tradition': '🪯',
  'compassion': '💗',
  'liberation': '🕊️',
  'non-dual': '∞',
  'breath': '💨',
  'sun': '☀️',
  'moon': '🌙',
  'fire': '🔥',
  'water': '💧',
  'earth': '🌍',
  'primordial': '🌌',
};

/// Returns [tag] with its emoji prefix, e.g. "🕉️ vedic".
/// Falls back to the tag name alone if no emoji is defined.
String tagWithEmoji(String tag) {
  final emoji = kTagEmojis[tag];
  return emoji != null ? '$emoji $tag' : tag;
}

/// A mantra entry from the curated library (assets/data/mantra_library.json).
///
/// Distinct from [BuiltInMantra] — this model is JSON-serialisable and carries
/// the richer set of fields needed by the full library (background, benefits, translations,
/// audio, etc.).
class LibraryMantra {
  final String id;

  /// Display title (e.g. "Gayatri Mantra").
  final String name;

  /// English meaning / translation of the mantra.
  final String english;

  /// Text in the original script (e.g. Devanagari, Hebrew, Arabic).
  final String original;

  /// How to pronounce the original in romanised English.
  final String transliteration;

  /// Origin, tradition, and literal meaning of the mantra.
  final String background;

  /// Spiritual or psychological benefits of practising the mantra.
  final String benefits;

  /// Plain tag names; pair with [kTagEmojis] for display.
  final List<String> tags;

  /// Spiritual tradition the mantra belongs to.
  final String tradition;

  /// Broad category used for library filtering.
  final String category;

  /// 'beginner' | 'intermediate' | 'advanced'
  final String difficulty;

  /// Optional recommended repetition count (e.g. 108). `null` = no recommendation.
  final int? recommendedRepetitions;

  /// Optional recommended cycle for the repetition count.
  final RepetitionCycle? recommendedCycle;

  /// Language-code → translated text (en, zh, es always present where possible).
  final Map<String, String> translations;

  /// Optional URL to a recorded audio clip (original language only).
  final String? audioUrl;

  const LibraryMantra({
    required this.id,
    required this.name,
    required this.english,
    required this.original,
    required this.transliteration,
    required this.background,
    required this.benefits,
    required this.tags,
    required this.tradition,
    required this.category,
    required this.difficulty,
    this.recommendedRepetitions,
    this.recommendedCycle,
    required this.translations,
    this.audioUrl,
  });

  factory LibraryMantra.fromJson(Map<String, dynamic> json) => LibraryMantra(
        id: json['id'] as String,
        name: json['name'] as String,
        english: json['english'] as String,
        original: json['original'] as String,
        transliteration: json['transliteration'] as String,
        background: json['background'] as String,
        benefits: json['benefits'] as String,
        tags: List<String>.from(json['tags'] as List),
        tradition: json['tradition'] as String,
        category: json['category'] as String,
        difficulty: json['difficulty'] as String,
        recommendedRepetitions: (json['recommendedRepetitions'] ?? json['targetRepetitions']) as int?,
        recommendedCycle: json['recommendedCycle'] != null
            ? RepetitionCycle.values.firstWhere(
                (e) => e.name == json['recommendedCycle'],
                orElse: () => RepetitionCycle.session,
              )
            : null,
        translations: Map<String, String>.from(json['translations'] as Map),
        audioUrl: json['audioUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'english': english,
        'original': original,
        'transliteration': transliteration,
        'background': background,
        'benefits': benefits,
        'tags': tags,
        'tradition': tradition,
        'category': category,
        'difficulty': difficulty,
        'recommendedRepetitions': recommendedRepetitions,
        'recommendedCycle': recommendedCycle?.name,
        'translations': translations,
        'audioUrl': audioUrl,
      };

  /// All tags with their emoji prefix for display.
  List<String> get tagsWithEmojis => tags.map(tagWithEmoji).toList();
}
