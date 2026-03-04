class BuiltInLanguage {
  final String code;
  final String name;
  final String text;
  final bool isPrimary;
  const BuiltInLanguage({required this.code, required this.name, required this.text, required this.isPrimary});
}

class BuiltInMantra {
  final String id;
  final String title;
  final String shortTitle;
  final String category;
  final String tradition;
  final String source;
  final bool isSignature;
  final int targetRepetitions;
  final List<BuiltInLanguage> languages;
  final String culturalContext;
  final List<String> tags;
  final String difficulty; // 'beginner' | 'intermediate' | 'advanced'
  final String? pronunciationGuide;

  const BuiltInMantra({
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.category,
    required this.tradition,
    required this.source,
    this.isSignature = false,
    required this.targetRepetitions,
    required this.languages,
    required this.culturalContext,
    required this.tags,
    required this.difficulty,
    this.pronunciationGuide,
  });

  String get primaryText =>
      languages.firstWhere((l) => l.isPrimary, orElse: () => languages.first).text;

  String? get transliteration {
    try {
      return languages.firstWhere((l) => l.code == 'sa-Latn').text;
    } catch (_) {
      return null;
    }
  }

  String? get englishTranslation {
    try {
      return languages.firstWhere((l) => l.code == 'en').text;
    } catch (_) {
      return null;
    }
  }
}

const List<BuiltInMantra> kBuiltInMantras = [
  BuiltInMantra(
    id: 'YS-1-12',
    title: 'Yoga Sutra I.12 – The Path of Practice',
    shortTitle: 'Abhyāsa-Vairāgya',
    category: 'Yogic Philosophy',
    tradition: 'Classical Yoga',
    source: "Patañjali's Yoga Sūtra, Book I, Verse 12",
    isSignature: true,
    targetRepetitions: 108,
    languages: [
      BuiltInLanguage(code: 'sa', name: 'Sanskrit (Devanagari)',
        text: 'अभ्यासवैराग्याभ्यां तन्निरोधः॥', isPrimary: true),
      BuiltInLanguage(code: 'sa-Latn', name: 'Sanskrit (IAST)',
        text: 'abhyāsa-vairāgya-ābhyāṃ tat-nirodhaḥ', isPrimary: false),
      BuiltInLanguage(code: 'en', name: 'English',
        text: 'Through steady practice and dispassion, the mind is stilled.', isPrimary: false),
      BuiltInLanguage(code: 'he', name: 'Hebrew',
        text: 'בהתמדה ובאי-היקשרות — הנפש שקטה', isPrimary: false),
    ],
    culturalContext:
        "This sutra from Patañjali's Yoga Sūtra explains the dual path to mental stillness: consistent practice (abhyāsa) and non-attachment (vairāgya). It embodies the philosophy of MyMantra — dedicated practice without obsessive attachment to results.",
    tags: ['foundational', 'yoga', 'philosophy', 'mind', 'practice', 'discipline'],
    difficulty: 'beginner',
    pronunciationGuide: 'ahb-YAH-sah VAI-rah-gyah AHB-yahm taht nee-ROH-dah',
  ),
  BuiltInMantra(
    id: 'OM-001',
    title: 'Om – The Primordial Sound',
    shortTitle: 'Om (ॐ)',
    category: 'Universal',
    tradition: 'Hindu / Buddhist / Jain',
    source: 'Ancient Vedic tradition',
    targetRepetitions: 108,
    languages: [
      BuiltInLanguage(code: 'sa', name: 'Sanskrit (Devanagari)', text: 'ॐ', isPrimary: true),
      BuiltInLanguage(code: 'sa-Latn', name: 'Sanskrit (IAST)', text: 'Oṃ', isPrimary: false),
      BuiltInLanguage(code: 'en', name: 'English',
        text: 'Om – the primordial vibration of the universe.', isPrimary: false),
    ],
    culturalContext:
        'Om (ॐ) is considered the most sacred syllable in Hinduism, Buddhism, and Jainism. It represents the sound of the universe — the vibration underlying all existence.',
    tags: ['universal', 'vedic', 'primordial', 'sound', 'meditation'],
    difficulty: 'beginner',
    pronunciationGuide: 'A-U-M (three sounds merging into one)',
  ),
  BuiltInMantra(
    id: 'OMMP-001',
    title: 'Om Mani Padme Hum',
    shortTitle: 'Om Mani Padme Hum',
    category: 'Buddhist',
    tradition: 'Tibetan Buddhism',
    source: 'Karandavyuha Sutra',
    targetRepetitions: 108,
    languages: [
      BuiltInLanguage(code: 'sa', name: 'Sanskrit (Devanagari)',
        text: 'ॐ मणिपद्मे हूँ', isPrimary: true),
      BuiltInLanguage(code: 'sa-Latn', name: 'Sanskrit (IAST)',
        text: 'oṃ maṇipadme hūṃ', isPrimary: false),
      BuiltInLanguage(code: 'en', name: 'English',
        text: 'Praise to the Jewel in the Lotus.', isPrimary: false),
    ],
    culturalContext:
        'The most widely recited mantra in Tibetan Buddhism, associated with Avalokiteśvara, the bodhisattva of compassion.',
    tags: ['buddhist', 'tibetan', 'compassion', 'jewel', 'lotus'],
    difficulty: 'beginner',
    pronunciationGuide: 'ohm mah-nee pahd-may hoom',
  ),
  BuiltInMantra(
    id: 'GAY-001',
    title: 'Gayatri Mantra',
    shortTitle: 'Gāyatrī Mantra',
    category: 'Vedic',
    tradition: 'Hindu Vedic',
    source: 'Rigveda (3.62.10)',
    targetRepetitions: 108,
    languages: [
      BuiltInLanguage(code: 'sa', name: 'Sanskrit (Devanagari)',
        text: 'ॐ भूर्भुवः स्वः\nतत्सवितुर्वरेण्यं\nभर्गो देवस्य धीमहि\nधियो यो नः प्रचोदयात्॥',
        isPrimary: true),
      BuiltInLanguage(code: 'sa-Latn', name: 'Sanskrit (IAST)',
        text: 'oṃ bhūr bhuvaḥ svaḥ\ntat savitur vareṇyaṃ\nbhargo devasya dhīmahi\ndhiyo yo naḥ pracodayāt',
        isPrimary: false),
      BuiltInLanguage(code: 'en', name: 'English',
        text: 'Om. We meditate on the glorious radiance of the divine sun. May it illuminate our minds.',
        isPrimary: false),
    ],
    culturalContext:
        'One of the most revered Vedic mantras, the Gayatri Mantra is dedicated to Savitṛ, the solar deity. It is a prayer for enlightenment and illumination of the intellect.',
    tags: ['vedic', 'gayatri', 'sun', 'illumination', 'prayer'],
    difficulty: 'intermediate',
    pronunciationGuide: 'ohm bhoor bhu-vah svah | tat sah-vi-tur vah-ren-yam | bhar-go day-vas-ya dhee-mah-hee | dhi-yo yo nah pra-cho-da-yaat',
  ),
  BuiltInMantra(
    id: 'MRY-001',
    title: 'Mahamrityunjaya Mantra',
    shortTitle: 'Mahāmṛtyuñjaya',
    category: 'Vedic',
    tradition: 'Hindu (Rigveda)',
    source: 'Rigveda 7.59.12',
    targetRepetitions: 108,
    languages: [
      BuiltInLanguage(code: 'sa', name: 'Sanskrit (Devanagari)',
        text: 'ॐ त्र्यम्बकं यजामहे\nसुगन्धिं पुष्टिवर्धनम्\nउर्वारुकमिव बन्धनान्\nमृत्योर्मुक्षीय माऽमृतात्॥',
        isPrimary: true),
      BuiltInLanguage(code: 'en', name: 'English',
        text: 'We worship the three-eyed one who nurtures and sustains. May we be liberated from death as a ripened fruit falls from the vine.',
        isPrimary: false),
    ],
    culturalContext:
        'This mantra to Lord Shiva is said to conquer death and grant liberation. Used for healing, protection, and overcoming obstacles.',
    tags: ['shiva', 'healing', 'protection', 'liberation', 'vedic'],
    difficulty: 'intermediate',
  ),
  BuiltInMantra(
    id: 'SOH-001',
    title: 'So Hum – I Am That',
    shortTitle: 'So Hum (सो ऽहम्)',
    category: 'Advaita Vedanta',
    tradition: 'Hindu Advaita Vedanta',
    source: 'Upanishadic tradition',
    targetRepetitions: 108,
    languages: [
      BuiltInLanguage(code: 'sa', name: 'Sanskrit (Devanagari)',
        text: 'सो ऽहम्', isPrimary: true),
      BuiltInLanguage(code: 'sa-Latn', name: 'Sanskrit (IAST)',
        text: "so 'haṃ", isPrimary: false),
      BuiltInLanguage(code: 'en', name: 'English',
        text: 'I am That. (I am the universe / I am Brahman)', isPrimary: false),
    ],
    culturalContext:
        'So Hum mirrors the natural sound of the breath. It is the mantra of self-inquiry, pointing to the non-dual nature of consciousness.',
    tags: ['advaita', 'breath', 'self', 'non-dual', 'consciousness'],
    difficulty: 'beginner',
    pronunciationGuide: 'Inhale: "soh" — Exhale: "hum"',
  ),
  BuiltInMantra(
    id: 'LOK-001',
    title: 'Lokah Samastah',
    shortTitle: 'Lokah Samastah',
    category: 'Universal',
    tradition: 'Hindu (modern)',
    source: 'Yoga tradition',
    targetRepetitions: 108,
    languages: [
      BuiltInLanguage(code: 'sa', name: 'Sanskrit (Devanagari)',
        text: 'लोकाः समस्ताः सुखिनो भवन्तु', isPrimary: true),
      BuiltInLanguage(code: 'sa-Latn', name: 'Sanskrit (IAST)',
        text: 'lokāḥ samastāḥ sukhino bhavantu', isPrimary: false),
      BuiltInLanguage(code: 'en', name: 'English',
        text: 'May all beings everywhere be happy and free.', isPrimary: false),
    ],
    culturalContext:
        'A loving-kindness mantra that expresses the wish for universal happiness and freedom.',
    tags: ['universal', 'compassion', 'loving-kindness', 'happiness', 'freedom'],
    difficulty: 'beginner',
    pronunciationGuide: 'lo-kaah sa-mas-taah su-khi-no bha-van-tu',
  ),
];

const List<Map<String, String>> kCategories = [
  {'id': 'all', 'label': 'All', 'emoji': '✨'},
  {'id': 'Yogic Philosophy', 'label': 'Yogic', 'emoji': '🧘'},
  {'id': 'Buddhist', 'label': 'Buddhist', 'emoji': '☸️'},
  {'id': 'Vedic', 'label': 'Vedic', 'emoji': '🔥'},
  {'id': 'Universal', 'label': 'Universal', 'emoji': '🌍'},
  {'id': 'Advaita Vedanta', 'label': 'Advaita', 'emoji': '∞'},
];
