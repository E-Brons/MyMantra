import 'package:flutter/material.dart';
import '../../../core/models/mantra.dart';
import '../../../core/services/icon_registry.dart';

/// Returns the [IconData] for a tag from icons.yml "Tags" section.
IconData? tagIcon(String tag) =>
    IconRegistry.instance.icon('Tags', tag);

/// A mantra entry from the curated library (assets/data/mantra_library.json).
///
/// Distinct from [BuiltInMantra] — this model is JSON-serialisable and carries
/// the richer set of fields needed by the full library (abstract, translations,
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

  /// 4–5 paragraph history-and-meaning essay.
  final String abstract;

  /// Plain tag names; pair with [tagIcon] for display.
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

  /// BCP-47 language codes supported for this mantra.
  final List<String> supportedLanguages;

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
    required this.abstract,
    required this.tags,
    required this.tradition,
    required this.category,
    required this.difficulty,
    this.recommendedRepetitions,
    this.recommendedCycle,
    required this.supportedLanguages,
    required this.translations,
    this.audioUrl,
  });

  factory LibraryMantra.fromJson(Map<String, dynamic> json) => LibraryMantra(
        id: json['id'] as String,
        name: json['name'] as String,
        english: json['english'] as String,
        original: json['original'] as String,
        transliteration: json['transliteration'] as String,
        abstract: json['abstract'] as String,
        tags: List<String>.from(json['tags'] as List),
        tradition: json['tradition'] as String,
        category: json['category'] as String,
        difficulty: json['difficulty'] as String,
        recommendedRepetitions: json['recommendedRepetitions'] as int?,
        recommendedCycle: json['recommendedCycle'] != null
            ? RepetitionCycle.values.firstWhere(
                (e) => e.name == json['recommendedCycle'],
                orElse: () => RepetitionCycle.session,
              )
            : null,
        supportedLanguages: List<String>.from(json['supportedLanguages'] as List),
        translations: Map<String, String>.from(json['translations'] as Map),
        audioUrl: json['audioUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'english': english,
        'original': original,
        'transliteration': transliteration,
        'abstract': abstract,
        'tags': tags,
        'tradition': tradition,
        'category': category,
        'difficulty': difficulty,
        'recommendedRepetitions': recommendedRepetitions,
        'recommendedCycle': recommendedCycle?.name,
        'supportedLanguages': supportedLanguages,
        'translations': translations,
        'audioUrl': audioUrl,
      };

  /// Returns the [IconData] for each tag that has one in icons.yml.
  Map<String, IconData> get tagIconMap => {
    for (final tag in tags)
      if (tagIcon(tag) != null) tag: tagIcon(tag)!,
  };
}
